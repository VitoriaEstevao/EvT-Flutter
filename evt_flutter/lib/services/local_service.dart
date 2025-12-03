import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LocalService {
  static const String baseUrl = "http://localhost:8080/locais";

  /// Gera o cabeçalho de autenticação com Bearer Token.
  static Future<Map<String, String>> authHeader() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final headers = {"Content-Type": "application/json"};

    if (token != null) {
      headers["Authorization"] = "Bearer $token";
    }

    return headers;
  }

  /// Trata a resposta HTTP, lançando exceção em caso de erro.
  static dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      try {
        return jsonDecode(response.body);
      } catch (_) {
        return null;
      }
    } else {
      String errorMessage = 'Erro na requisição (Status: ${response.statusCode})';
      try {
        final errorData = jsonDecode(response.body);
        if (errorData is Map && errorData.containsKey('mensagem')) {
          errorMessage = errorData['mensagem'];
        } else if (errorData is Map && errorData.containsKey('erros')) {
          if (errorData['erros'] is Map) {
            errorMessage = errorData['erros'].values.first.toString();
          } else {
            errorMessage = errorData['erros'].toString();
          }
        }
      } catch (_) {}
      throw Exception(errorMessage);
    }
  }

  /// Busca o endereço completo a partir de um CEP usando ViaCEP.
  static Future<Map<String, dynamic>> buscarCepViaCep(String cep) async {
    final cleanCep = cep.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanCep.length != 8) {
      throw Exception("CEP inválido");
    }

    final url = Uri.parse('https://viacep.com.br/ws/$cleanCep/json/');
    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception("Erro ao buscar CEP: ${response.statusCode}");
    }

    final data = jsonDecode(response.body);

    if (data['erro'] == true) {
      throw Exception("CEP não encontrado.");
    }

    return data;
  }

  /// Busca um local específico pelo ID.
  static Future<Map<String, dynamic>> getLocalById(int id) async {
    final headers = await authHeader();
    final url = Uri.parse('$baseUrl/$id');

    final response = await http.get(url, headers: headers);
    
    final data = _handleResponse(response);
    
    if (data is Map<String, dynamic>) {
      return data;
    }
    throw Exception('Local com ID $id não encontrado ou resposta inválida.');
  }

  /// Lista todos os locais.
  static Future<List<dynamic>> getLocais() async {
    final headers = await authHeader();
    final r = await http.get(Uri.parse(baseUrl), headers: headers);
    final data = _handleResponse(r);
    return data ?? [];
  }

  /// Cria um novo local.
  static Future<void> criarLocal(Map<String, dynamic> body) async {
    final headers = await authHeader();
    final r = await http.post(
      Uri.parse(baseUrl),
      headers: headers,
      body: jsonEncode(body),
    );
    _handleResponse(r);
  }

  /// Atualiza um local existente.
  static Future<void> atualizarLocal(String id, Map<String, dynamic> body) async {
    final headers = await authHeader();
    final r = await http.put(
      Uri.parse("$baseUrl/$id"),
      headers: headers,
      body: jsonEncode(body),
    );
    _handleResponse(r);
  }

  /// Deleta um local.
  static Future<void> deletarLocal(String id) async {
    final headers = await authHeader();
    final r = await http.delete(Uri.parse("$baseUrl/$id"), headers: headers);
    _handleResponse(r);
  }
}
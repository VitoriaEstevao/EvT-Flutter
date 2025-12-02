import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LocalService {
  // Ajuste o endereço base se necessário (ex: 10.0.2.2 para Android Emulator)
  static const String baseUrl = "http://localhost:8080/locais";

  // 1. Função para buscar o token
  static Future<Map<String, String>> authHeader() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    // Cabeçalho base
    final headers = {"Content-Type": "application/json"};

    // Adiciona o token se existir
    if (token != null) {
      headers["Authorization"] = "Bearer $token";
    }

    return headers;
  }

  // 2. Helper para tratar erros da API
  static dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      // Tenta decodificar o corpo, mas permite que seja vazio (No Content)
      try {
        return jsonDecode(response.body);
      } catch (_) {
        return null;
      }
    } else {
      String errorMessage = 'Erro na requisição (Status: ${response.statusCode})';
      try {
        final errorData = jsonDecode(response.body);
        // Tenta extrair a mensagem de erro detalhada do Spring Boot/Backend
        if (errorData is Map && errorData.containsKey('mensagem')) {
          errorMessage = errorData['mensagem'];
        } else if (errorData is Map && errorData.containsKey('erros')) {
          // Trata erros de validação
          if (errorData['erros'] is Map) {
            errorMessage = errorData['erros'].values.first.toString();
          } else {
            errorMessage = errorData['erros'].toString();
          }
        }
      } catch (_) {
        // Ignora se o corpo for vazio ou inválido
      }
      throw Exception(errorMessage);
    }
  }

  // 3. Integração com ViaCEP
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

  // ======================================
  // MÉTODO ADICIONADO PARA CORRIGIR O ERRO
  // ======================================

  /// 🔹 Buscar um local pelo ID (Método ausente que causava o erro)
  static Future<Map<String, dynamic>> getLocalById(int id) async {
    final headers = await authHeader();
    // Note que o endpoint é '$baseUrl/ID_DO_LOCAL'
    final url = Uri.parse('$baseUrl/$id');

    final response = await http.get(url, headers: headers);
    
    final data = _handleResponse(response);
    
    if (data is Map<String, dynamic>) {
      return data;
    }
    // Lança exceção se o backend retornar null ou uma lista inesperadamente.
    throw Exception('Local com ID $id não encontrado ou resposta inválida.');
  }


  // Métodos CRUD de Local
  static Future<List<dynamic>> getLocais() async {
    final headers = await authHeader();
    final r = await http.get(Uri.parse(baseUrl), headers: headers);
    final data = _handleResponse(r);
    return data ?? []; // Garante retorno de lista vazia se não houver dados
  }

  static Future<void> criarLocal(Map<String, dynamic> body) async {
    final headers = await authHeader();
    final r = await http.post(
      Uri.parse(baseUrl),
      headers: headers,
      body: jsonEncode(body),
    );
    _handleResponse(r);
  }

  static Future<void> atualizarLocal(String id, Map<String, dynamic> body) async {
    final headers = await authHeader();
    final r = await http.put(
      Uri.parse("$baseUrl/$id"),
      headers: headers,
      body: jsonEncode(body),
    );
    _handleResponse(r);
  }

  static Future<void> deletarLocal(String id) async {
    final headers = await authHeader();
    final r = await http.delete(Uri.parse("$baseUrl/$id"), headers: headers);
    _handleResponse(r); // Trata possíveis erros, como 404
  }
}
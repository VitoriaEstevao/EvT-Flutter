import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class UsuarioService { 
  static const String baseUrl = 'http://localhost:8080/usuarios';

  /// Gera o cabeçalho de autenticação com Bearer Token.
  static Future<Map<String, String>> _authHeader() async {
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
        
        if (errorData is Map && errorData.containsKey('erros')) {
          if (errorData['erros'] is Map) {
            errorMessage = errorData['erros'].values.first.toString();
          }
        } else if (errorData is Map && errorData.containsKey('mensagem')) {
          errorMessage = errorData['mensagem'];
        }
      } catch (_) {}
      throw Exception(errorMessage);
    }
  }

  /// Busca todos os usuários.
  static Future<List<dynamic>> getUsuarios() async {
    final headers = await _authHeader();
    final url = Uri.parse(baseUrl);

    final response = await http.get(url, headers: headers);

    final data = _handleResponse(response);
    return data ?? [];
  }

  /// Cria um novo usuário.
  static Future<void> criarUsuario(Map<String, dynamic> body) async {
    final headers = await _authHeader();
    final url = Uri.parse(baseUrl);

    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(body),
    );
    _handleResponse(response);
  }

  /// Edita um usuário existente pelo ID.
  static Future<void> editarUsuario(int id, Map<String, dynamic> body) async {
    final headers = await _authHeader();
    final url = Uri.parse('$baseUrl/$id');

    final response = await http.put(
      url,
      headers: headers,
      body: jsonEncode(body),
    );
    _handleResponse(response);
  }

  /// Deleta um usuário pelo ID.
  static Future<void> deletarUsuario(int id) async {
    final headers = await _authHeader();
    final url = Uri.parse('$baseUrl/$id');

    final response = await http.delete(url, headers: headers);
    _handleResponse(response);
  }
}
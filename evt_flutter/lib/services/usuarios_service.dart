import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// RENOMEADO DE UsuariosService PARA UsuarioService (singular)
class UsuarioService { 
  // Ajuste o endereço base se necessário (ex: 10.0.2.2 para Android Emulator)
  static const String baseUrl = 'http://localhost:8080/usuarios';

  /// 🔹 Gera o cabeçalho de autenticação (Bearer Token)
  static Future<Map<String, String>> _authHeader() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final headers = {"Content-Type": "application/json"};

    if (token != null) {
      headers["Authorization"] = "Bearer $token";
    }

    return headers;
  }

  /// 🔹 Helper para tratar a resposta da API (incluindo erros e validação)
  static dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      try {
        // Tenta decodificar o corpo (se houver)
        return jsonDecode(response.body);
      } catch (_) {
        return null; // Retorna null para 204 No Content
      }
    } else {
      String errorMessage = 'Erro na requisição (Status: ${response.statusCode})';
      try {
        final errorData = jsonDecode(response.body);
        
        // Trata erros de validação
        if (errorData is Map && errorData.containsKey('erros')) {
          if (errorData['erros'] is Map) {
            // Pega o primeiro erro de validação (seja nome, email, etc.)
            errorMessage = errorData['erros'].values.first.toString();
          }
        } else if (errorData is Map && errorData.containsKey('mensagem')) {
          // Mensagem de erro geral do Spring (ex: usuário não encontrado)
          errorMessage = errorData['mensagem'];
        }
      } catch (_) {
        // Ignora se o corpo for vazio ou inválido
      }
      throw Exception(errorMessage);
    }
  }

  /// 🔹 Buscar todos os usuários
  static Future<List<dynamic>> getUsuarios() async {
    final headers = await _authHeader();
    final url = Uri.parse(baseUrl);

    final response = await http.get(url, headers: headers);

    final data = _handleResponse(response);
    return data ?? [];
  }

  /// 🔹 Criar novo usuário
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

  /// 🔹 Editar usuário existente
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

  /// 🔹 Deletar usuário
  static Future<void> deletarUsuario(int id) async {
    final headers = await _authHeader();
    final url = Uri.parse('$baseUrl/$id');

    final response = await http.delete(url, headers: headers);
    _handleResponse(response);
  }
}
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http/http.dart'; 
import 'package:shared_preferences/shared_preferences.dart';

class FuncionarioService {
  static const String baseUrl = 'http://localhost:8080/funcionarios';
  
  static Future<String?> _getAuthToken() async {
    // Busca o token real salvo no login.
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("token"); 
  }

  static Future<Map<String, String>> _authHeader() async {
    final token = await _getAuthToken();
    
    if (token == null) {
      return { 'Content-Type': 'application/json' }; 
    }
    
    return { 
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  /// Lança a resposta como exceção se o status for de erro (>= 400).
  static void _handleResponseError(Response response) {
    if (response.statusCode >= 400) {
      throw response;
    }
  }

  /// Busca todos os funcionários.
  static Future<List<dynamic>> getFuncionarios() async {
    final url = Uri.parse(baseUrl);
    final headers = await _authHeader();
    headers.remove('Content-Type'); 

    final response = await http.get(url, headers: headers);
    
    _handleResponseError(response);

    return jsonDecode(response.body);
  }
  
  /// Cria um novo funcionário.
  static Future<Map<String, dynamic>> criarFuncionario(Map<String, dynamic> funcionario) async {
    final url = Uri.parse(baseUrl);
    final response = await http.post(
      url,
      headers: await _authHeader(),
      body: jsonEncode(funcionario),
    );

    _handleResponseError(response);
    return jsonDecode(response.body);
  }

  /// Edita um funcionário existente.
  static Future<Map<String, dynamic>> editarFuncionario(String id, Map<String, dynamic> funcionario) async {
    final url = Uri.parse('$baseUrl/$id');
    final response = await http.put(
      url,
      headers: await _authHeader(),
      body: jsonEncode(funcionario),
    );

    _handleResponseError(response);
    return jsonDecode(response.body);
  }

  /// Deleta um funcionário.
  static Future<bool> deletarFuncionario(String id) async {
    final url = Uri.parse('$baseUrl/$id');
    final response = await http.delete(url, headers: await _authHeader());

    _handleResponseError(response);
    return true;
  }
}
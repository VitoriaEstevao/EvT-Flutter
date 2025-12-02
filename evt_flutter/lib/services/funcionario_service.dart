
// lib/services/funcionario_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http/http.dart'; 
import 'package:shared_preferences/shared_preferences.dart'; // 🎯 Novo Import

class FuncionarioService {
  // OBS: Adapte a porta ou o endereço conforme necessário.
  static const String baseUrl = 'http://localhost:8080/funcionarios';
  
  // === OBTENDO O TOKEN REAL DO DISPOSITIVO ===
  static Future<String?> _getAuthToken() async {
    // 🎯 Busca o token real salvo no login
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("token"); 
  }

  static Future<Map<String, String>> _authHeader() async {
    final token = await _getAuthToken();
    
    // Se o token não existir (usuário deslogado), a requisição falhará no backend,
    // o que é esperado para rotas @PreAuthorize.
    if (token == null) {
      // Retorna apenas o Content-Type para evitar exceções de null
      return { 'Content-Type': 'application/json' }; 
    }
    
    return { 
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  /// 🔹 Tratamento de Erro Unificado (Similar ao if (!res.ok) throw res;)
  static void _handleResponseError(Response response) {
    if (response.statusCode >= 400) {
      // Lançamos a resposta como uma exceção para que a tela trate os detalhes (erros, mensagem).
      throw response;
    }
  }

  /// 🔹 Buscar todos os funcionários
  static Future<List<dynamic>> getFuncionarios() async {
    final url = Uri.parse(baseUrl);
    final headers = await _authHeader();
    // Remove o Content-Type para requisição GET (opcional, mas boa prática)
    headers.remove('Content-Type'); 

    final response = await http.get(url, headers: headers);
    
    _handleResponseError(response);

    return jsonDecode(response.body);
  }
  
  /// 🔹 Criar funcionário
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

  /// 🔹 Editar funcionário
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

  /// 🔹 Deletar funcionário
  static Future<bool> deletarFuncionario(String id) async {
    final url = Uri.parse('$baseUrl/$id');
    final response = await http.delete(url, headers: await _authHeader());

    _handleResponseError(response);
    return true;
  }
}
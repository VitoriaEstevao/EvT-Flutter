import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CadastroService {
  // Ajustado para o endpoint base (http://localhost:8080)
  // pois a rota /usuarios não está aninhada sob /auth
  static const String baseUrl = 'http://localhost:8080';

  // --- Funções Auxiliares ---

  /// 🔹 Recuperar token salvo
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // --- Métodos de Autenticação ---

  /// 🔹 Login de usuário
  static Future<Map<String, dynamic>> loginUsuario(
      String email, String senha) async {
    // Endpoint: /auth/login
    final url = Uri.parse('$baseUrl/auth/login');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'senha': senha}),
    );

    if (response.statusCode != 200) {
      String errorMessage = 'E-mail ou senha inválidos.';
      try {
        final errorData = jsonDecode(response.body);
        errorMessage = errorData['mensagem'] ?? errorMessage;
      } catch (_) {
        // Ignora se não conseguir decodificar o erro
      }
      throw Exception(errorMessage);
    }

    final data = jsonDecode(response.body);

    // Armazena o token localmente (SharedPreferences)
    if (data['token'] != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', data['token']);
    }

    return data;
  }

  /// 🔹 Cadastro de usuário (CHAMA A ROTA /usuarios)
  static Future<Map<String, dynamic>> cadastrarUsuario({
    required String nome,
    required String email,
    required String senha,
    required String cpf,
  }) async {
    // 🎯 ROTA ALTERADA PARA /usuarios
    final url = Uri.parse('$baseUrl/usuarios');
    
    // Obter Token para enviar (como o React faz)
    final token = await getToken(); 
    
    final headers = {
      'Content-Type': 'application/json',
      // Inclui o Header de Autorização, se o token estiver presente
      if (token != null) 'Authorization': 'Bearer $token',
    };
    
    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode({
        'nome': nome,
        'email': email,
        'senha': senha,
        'cpf': cpf,
      }),
    );

    // Trata códigos de status de erro
    if (response.statusCode < 200 || response.statusCode >= 300) {
      String errorMessage = 'Erro ao criar conta (status ${response.statusCode})';
      try {
        final errorData = jsonDecode(response.body);
        errorMessage = errorData['mensagem'] ?? errorMessage;
      } catch (_) {}
      
      throw Exception(errorMessage);
    }

    try {
      // Tenta retornar o corpo da resposta
      return jsonDecode(response.body);
    } catch (_) {
      // Se retornar 201 Created sem corpo, assume sucesso
      return {'success': true};
    }
  }

  /// 🔹 Logout do usuário
  static Future<bool> logoutUsuario() async {
    // Remove o token localmente.
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    return true;
  }
}
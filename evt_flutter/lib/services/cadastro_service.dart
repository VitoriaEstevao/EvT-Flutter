import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CadastroService {
  static const String baseUrl = 'http://localhost:8080';

  // --- Funções Auxiliares ---

  /// Recupera o token salvo localmente.
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // --- Métodos de Autenticação ---

  /// Realiza o login do usuário na rota /auth/login.
  static Future<Map<String, dynamic>> loginUsuario(
      String email, String senha) async {
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
      } catch (_) {}
      throw Exception(errorMessage);
    }

    final data = jsonDecode(response.body);

    /// Armazena o token JWT localmente após o sucesso.
    if (data['token'] != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', data['token']);
    }

    return data;
  }

  /// Cadastra um novo usuário na rota /usuarios.
  static Future<Map<String, dynamic>> cadastrarUsuario({
    required String nome,
    required String email,
    required String senha,
    required String cpf,
  }) async {
    final url = Uri.parse('$baseUrl/usuarios');
    
    final token = await getToken(); 
    
    final headers = {
      'Content-Type': 'application/json',
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

    if (response.statusCode < 200 || response.statusCode >= 300) {
      String errorMessage = 'Erro ao criar conta (status ${response.statusCode})';
      try {
        final errorData = jsonDecode(response.body);
        errorMessage = errorData['mensagem'] ?? errorMessage;
      } catch (_) {}
      
      throw Exception(errorMessage);
    }

    try {
      return jsonDecode(response.body);
    } catch (_) {
      return {'success': true};
    }
  }

  /// Remove o token do armazenamento local.
  static Future<bool> logoutUsuario() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    return true;
  }
}
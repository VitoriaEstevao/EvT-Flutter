import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CadastroService {
  static const String baseUrl = 'http://localhost:8080/auth';

  /// 🔹 Login de usuário
  static Future<Map<String, dynamic>> loginUsuario(String email, String senha) async {
    final url = Uri.parse('$baseUrl/login');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'senha': senha}),
    );

    if (response.statusCode != 200) {
      throw Exception('E-mail ou senha inválidos.');
    }

    final data = jsonDecode(response.body);

    // Armazena o token localmente (como o localStorage no React)
    if (data['token'] != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', data['token']);
    }

    return data;
  }

  /// 🔹 Cadastro de usuário
  static Future<Map<String, dynamic>> cadastrarUsuario({
    required String nome,
    required String email,
    required String senha,
    required String cpf,
  }) async {
    final url = Uri.parse('$baseUrl/cadastro');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'nome': nome,
        'email': email,
        'senha': senha,
        'cpf': cpf,
      }),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Erro ao criar conta (status ${response.statusCode})');
    }

    try {
      return jsonDecode(response.body);
    } catch (_) {
      return {'success': true};
    }
  }

  /// 🔹 Cadastro de funcionário
  static Future<bool> cadastrarFuncionario({
    required String nome,
    required String email,
    required String cpf,
    required String senha,
    required String cargo,
    required String departamento,
  }) async {
    final url = Uri.parse('$baseUrl/funcionarios');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'nome': nome,
        'email': email,
        'cpf': cpf,
        'senha': senha,
        'cargo': cargo,
        'departamento': departamento,
      }),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Erro ao cadastrar funcionário: ${response.body}');
    }

    return true;
  }

  /// 🔹 Logout do usuário
  static Future<bool> logoutUsuario() async {
    final url = Uri.parse('$baseUrl/logout');
    final response = await http.post(url);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Erro ao fazer logout');
    }

    // Remove token salvo
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');

    return true;
  }

  /// 🔹 Recuperar token salvo (equivalente ao localStorage.getItem)
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;


class FuncionarioService {
  static const String baseUrl = 'http://localhost:8080/funcionarios';

  /// 🔹 Buscar todos os funcionários
  static Future<List<dynamic>> getFuncionarios() async {
    final url = Uri.parse(baseUrl);
    final response = await http.get(url);

    if (response.statusCode >= 400) {
      throw Exception('Erro ao buscar funcionários.');
    }

    return jsonDecode(response.body);
  }

  /// 🔹 Buscar um funcionário por ID
  static Future<Map<String, dynamic>> getFuncionario(String id) async {
    final url = Uri.parse('$baseUrl/$id');
    final response = await http.get(url);

    if (response.statusCode >= 400) {
      throw Exception('Erro ao buscar funcionário.');
    }

    return jsonDecode(response.body);
  }

  /// 🔹 Criar funcionário
  static Future<Map<String, dynamic>> criarFuncionario(Map<String, dynamic> funcionario) async {
    final url = Uri.parse(baseUrl);
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(funcionario),
    );

    if (response.statusCode >= 400) {
      throw Exception(response.body);
    }

    return jsonDecode(response.body);
  }

  /// 🔹 Editar funcionário
  static Future<Map<String, dynamic>> editarFuncionario(String id, Map<String, dynamic> funcionario) async {
    final url = Uri.parse('$baseUrl/$id');
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(funcionario),
    );

    if (response.statusCode >= 400) {
      throw Exception(response.body);
    }

    return jsonDecode(response.body);
  }

  /// 🔹 Deletar funcionário
  static Future<bool> deletarFuncionario(String id) async {
    final url = Uri.parse('$baseUrl/$id');
    final response = await http.delete(url);

    if (response.statusCode >= 400) {
      throw Exception("Erro ao deletar funcionário.");
    }

    return true;
  }
}

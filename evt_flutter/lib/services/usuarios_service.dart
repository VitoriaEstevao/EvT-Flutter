import 'dart:convert';
import 'package:http/http.dart' as http;

class UsuariosService {
  static const String baseUrl = 'http://localhost:8080';

  /// 🔹 Buscar todos os usuários
  static Future<List<dynamic>> getUsuarios() async {
    final url = Uri.parse('$baseUrl/usuarios');

    final response = await http.get(
      url,
      // headers: {}, // se precisar de headers adicionais
    );

    if (response.statusCode != 200) {
      throw Exception('Erro ao buscar usuários');
    }

    return jsonDecode(response.body);
  }
}

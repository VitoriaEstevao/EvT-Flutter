import 'dart:convert';
import 'package:http/http.dart' as http;

class EventoService {
  static const String baseUrl = 'http://localhost:8080';

  /// 🔹 Listar todos os eventos
  static Future<List<dynamic>> getEventos() async {
    final url = Uri.parse('$baseUrl/eventos');
    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception('Erro ao buscar eventos');
    }

    return jsonDecode(response.body);
  }

  /// 🔹 Buscar evento por ID
  static Future<Map<String, dynamic>> getEvento(int id) async {
    final url = Uri.parse('$baseUrl/eventos/$id');
    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception('Evento não encontrado');
    }

    return jsonDecode(response.body);
  }

  /// 🔹 Criar um novo evento
  static Future<Map<String, dynamic>> criarEvento(Map<String, dynamic> evento) async {
    final url = Uri.parse('$baseUrl/eventos');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(evento),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Erro ao criar evento: ${response.body}');
    }

    return jsonDecode(response.body);
  }

  /// 🔹 Editar evento existente
  static Future<Map<String, dynamic>> editarEvento(int id, Map<String, dynamic> evento) async {
    final url = Uri.parse('$baseUrl/eventos/$id');
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(evento),
    );

    if (response.statusCode != 200) {
      throw Exception('Erro ao atualizar evento: ${response.body}');
    }

    return jsonDecode(response.body);
  }

  /// 🔹 Deletar evento
  static Future<bool> deletarEvento(int id) async {
    final url = Uri.parse('$baseUrl/eventos/$id');
    final response = await http.delete(url);

    if (response.statusCode != 204) {
      throw Exception('Erro ao deletar evento');
    }

    return true;
  }
}

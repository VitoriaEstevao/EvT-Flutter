import 'dart:convert';
import 'package:http/http.dart' as http;


class ParticipacaoService {
  static const String baseUrl = 'http://localhost:8080/participacoes';

  static Future<dynamic> _parseResponse(http.Response res) async {
    if (res.statusCode >= 400) throw Exception(res.body);

    if (res.body.isEmpty) return null;

    try {
      return jsonDecode(res.body);
    } catch (_) {
      return null;
    }
  }

  /// 🔹 Participar do evento
  static Future<dynamic> participar(String tituloEvento) async {
    final url = Uri.parse(baseUrl);
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({"tituloEvento": tituloEvento}),
    );

    return _parseResponse(response);
  }

  /// 🔹 Listar eventos do usuário
  static Future<List<dynamic>> getMeusEventos() async {
    final url = Uri.parse('$baseUrl/meus-eventos');
    final res = await http.get(url);
    return await _parseResponse(res);
  }

  /// 🔹 Listar participantes de um evento
  static Future<List<dynamic>> getUsuariosPorEvento(String eventoId) async {
    final url = Uri.parse('$baseUrl/evento/$eventoId/usuarios');
    final res = await http.get(url);

    final data = await _parseResponse(res);
    return data is List ? data : [];
  }
}

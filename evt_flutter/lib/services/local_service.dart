import 'dart:convert';
import 'package:http/http.dart' as http;

class LocalService {
  static const String baseUrl = "http://localhost:8080/locais";

  static Future<List<dynamic>> getLocais() async {
    final r = await http.get(Uri.parse(baseUrl));
    return jsonDecode(r.body);
  }

  // Novo método para buscar local por ID
  static Future<Map<String, dynamic>?> getLocalById(int id) async {
    final locais = await getLocais();
    try {
      return locais.firstWhere((l) => l["id"] == id);
    } catch (e) {
      return null; // retorna null se não encontrar
    }
  }

  static Future<void> criarLocal(Map<String, dynamic> body) async {
    await http.post(
      Uri.parse(baseUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );
  }

  static Future<void> atualizarLocal(String id, Map<String, dynamic> body) async {
    await http.put(
      Uri.parse("$baseUrl/$id"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );
  }

  static Future<void> deletarLocal(String id) async {
    await http.delete(Uri.parse("$baseUrl/$id"));
  }
}

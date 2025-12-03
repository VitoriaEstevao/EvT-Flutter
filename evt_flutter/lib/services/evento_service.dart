import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class EventoService {
  static const String baseUrl = 'http://localhost:8080/eventos';

  /// Gera o cabeçalho de autenticação com Bearer Token.
  static Future<Map<String, String>> _authHeader({bool jsonContent = false}) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final Map<String, String> headers = {};
    if (jsonContent) {
      headers["Content-Type"] = "application/json";
    }

    if (token != null) {
      headers["Authorization"] = "Bearer $token";
    }

    return headers;
  }

  /// Trata a resposta HTTP, lançando exceção em caso de erro.
  static dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty && response.statusCode == 204) {
        return null; 
      }
      try {
        return jsonDecode(response.body);
      } catch (_) {
        return null;
      }
    } else {
      String errorMessage = 'Erro na requisição (Status: ${response.statusCode})';
      try {
        final errorData = jsonDecode(response.body);
        
        if (errorData is Map) {
          if (errorData.containsKey('erros') && errorData['erros'] is Map) {
            errorMessage = errorData['erros'].values.first.toString();
          } 
          else if (errorData.containsKey('mensagem')) {
            errorMessage = errorData['mensagem'];
          }
        }
      } catch (_) {}
      throw Exception(errorMessage);
    }
  }

  /// Lista todos os eventos.
  static Future<List<dynamic>> getEventos() async {
    final headers = await _authHeader();
    final url = Uri.parse(baseUrl);
    final response = await http.get(url, headers: headers);

    final data = _handleResponse(response);
    return data ?? [];
  }

  /// Busca um evento específico pelo ID.
  static Future<Map<String, dynamic>> getEvento(int id) async {
    final headers = await _authHeader();
    final url = Uri.parse('$baseUrl/$id');
    final response = await http.get(url, headers: headers);

    return _handleResponse(response);
  }

  /// Cria um novo evento.
  static Future<void> criarEvento(Map<String, dynamic> evento) async {
    final headers = await _authHeader(jsonContent: true);
    final url = Uri.parse(baseUrl);
    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(evento),
    );
    _handleResponse(response);
  }

  /// Edita um evento existente.
  static Future<void> editarEvento(int id, Map<String, dynamic> evento) async {
    final headers = await _authHeader(jsonContent: true);
    final url = Uri.parse('$baseUrl/$id');
    final response = await http.put(
      url,
      headers: headers,
      body: jsonEncode(evento),
    );
    _handleResponse(response);
  }

  /// Deleta um evento pelo ID.
  static Future<void> deletarEvento(int id) async {
    final headers = await _authHeader();
    final url = Uri.parse('$baseUrl/$id');
    final response = await http.delete(url, headers: headers);

    _handleResponse(response);
  }
}
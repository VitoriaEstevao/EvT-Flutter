import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart'; // NECESSÁRIO!

class EventoService {
  // Ajuste o endereço base se necessário (ex: 10.0.2.2 para Android Emulator)
  static const String baseUrl = 'http://localhost:8080/eventos';

  /// 🔹 Gera o cabeçalho de autenticação (Bearer Token)
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

  /// 🔹 Helper para tratar a resposta da API (incluindo erros e validação)
  static dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      // 204 No Content para DELETE retorna null
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
          // Trata erros de validação (array de 'erros')
          if (errorData.containsKey('erros') && errorData['erros'] is Map) {
            errorMessage = errorData['erros'].values.first.toString();
          } 
          // Trata mensagens de erro gerais
          else if (errorData.containsKey('mensagem')) {
            errorMessage = errorData['mensagem'];
          }
        }
      } catch (_) {
        // Ignora se o corpo for vazio ou inválido
      }
      throw Exception(errorMessage);
    }
  }

  /// 🔹 Listar todos os eventos
  static Future<List<dynamic>> getEventos() async {
    final headers = await _authHeader();
    final url = Uri.parse(baseUrl);
    final response = await http.get(url, headers: headers);

    final data = _handleResponse(response);
    return data ?? [];
  }

  /// 🔹 Buscar evento por ID
  static Future<Map<String, dynamic>> getEvento(int id) async {
    final headers = await _authHeader();
    final url = Uri.parse('$baseUrl/$id');
    final response = await http.get(url, headers: headers);

    return _handleResponse(response);
  }

  /// 🔹 Criar um novo evento
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

  /// 🔹 Editar evento existente
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

  /// 🔹 Deletar evento
  static Future<void> deletarEvento(int id) async {
    final headers = await _authHeader();
    final url = Uri.parse('$baseUrl/$id');
    final response = await http.delete(url, headers: headers);

    _handleResponse(response); // O 204 No Content é tratado
  }
}
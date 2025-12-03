import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ParticipacaoService {
  static const String baseUrl = 'http://localhost:8080/participacoes';
  
  // ===========================================
  // === FUNÇÕES DE INFRAESTRUTURA ===
  // ===========================================

  /// Obtém os headers de autenticação, lendo o token.
  static Future<Map<String, String>> _getAuthHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    final headers = {
      'Content-Type': 'application/json',
    };

    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }
  
  /// Processa a resposta HTTP, lançando uma exceção para status de erro.
  static void _handleResponseError(http.Response res, String defaultError) {
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return;
    }

    String errorMessage = defaultError;
    try {
      final jsonBody = jsonDecode(res.body);
      if (jsonBody is Map && jsonBody.containsKey('mensagem')) {
        errorMessage = jsonBody['mensagem'].toString();
      } else if (jsonBody is Map && jsonBody.containsKey('error')) {
        errorMessage = jsonBody['error'].toString();
      }
    } catch (_) {
      errorMessage = '$defaultError (Status: ${res.statusCode})';
    }

    throw http.Response(errorMessage, res.statusCode);
  }

  /// Processa a resposta e o corpo (JSON), tratando erros.
  static Future<dynamic> _handleResponse(http.Response res, String defaultError) async {
    _handleResponseError(res, defaultError);
    
    if (res.body.isEmpty) return null;

    try {
      return jsonDecode(res.body);
    } catch (_) {
      throw Exception('Erro ao processar o corpo da resposta da API.');
    }
  }


  // ===========================================
  // === MÉTODOS DE SERVIÇO ===
  // ===========================================

  /// Registra a participação do usuário no evento.
  static Future<dynamic> participar(String tituloEvento) async {
    final url = Uri.parse(baseUrl);
    final headers = await _getAuthHeaders();

    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode({"tituloEvento": tituloEvento}),
    );

    return _handleResponse(response, 'Erro ao registrar participação.');
  }

  /// Lista os eventos em que o usuário está participando.
  static Future<List<dynamic>> getMeusEventos() async {
    final url = Uri.parse('$baseUrl/meus-eventos');
    final headers = await _getAuthHeaders();
    
    final res = await http.get(url, headers: headers);
    
    final data = await _handleResponse(res, 'Erro ao buscar seus eventos.');
    return data is List ? data : [];
  }

  /// Lista os usuários que estão participando de um evento específico.
  static Future<List<dynamic>> getUsuariosPorEvento(String eventoId) async {
    final url = Uri.parse('$baseUrl/evento/$eventoId/usuarios');
    final headers = await _getAuthHeaders();

    final res = await http.get(url, headers: headers);

    final data = await _handleResponse(res, 'Erro ao buscar participantes.');
    return data is List ? data : [];
  }
}
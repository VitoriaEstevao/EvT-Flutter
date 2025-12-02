// lib/services/participacao_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart'; // Necessário para o token

class ParticipacaoService {
  static const String baseUrl = 'http://localhost:8080/participacoes';
  
  // ===========================================
  // === SUBST. BaseService - AUTORIZAÇÃO E ERROS ===
  // ===========================================

  /// Obtém os headers de autenticação, lendo o token do SharedPreferences.
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
      return; // Sucesso
    }

    String errorMessage = defaultError;
    try {
      final jsonBody = jsonDecode(res.body);
      // Tentativa de obter mensagem de erro padrão do backend (comumente 'mensagem')
      if (jsonBody is Map && jsonBody.containsKey('mensagem')) {
        errorMessage = jsonBody['mensagem'].toString();
      } else if (jsonBody is Map && jsonBody.containsKey('error')) {
        // Tentativa para outros formatos comuns
        errorMessage = jsonBody['error'].toString();
      }
    } catch (_) {
      // O body não era JSON ou estava vazio; usa o erro padrão com status
      errorMessage = '$defaultError (Status: ${res.statusCode})';
    }

    throw http.Response(errorMessage, res.statusCode); // Lança uma Response Exception
  }

  // Método auxiliar para processar a resposta e o corpo
  static Future<dynamic> _handleResponse(http.Response res, String defaultError) async {
    _handleResponseError(res, defaultError); // Lança Exception se houver erro
    
    if (res.body.isEmpty) return null;

    try {
      return jsonDecode(res.body);
    } catch (_) {
      // Se a resposta for de sucesso (status 2xx) mas o parsing falhar
      throw Exception('Erro ao processar o corpo da resposta da API.');
    }
  }


  // ===========================================
  // === MÉTODOS ORIGINAIS DA CLASSE ===
  // ===========================================

  /// 🔹 Participar do evento
  static Future<dynamic> participar(String tituloEvento) async {
    final url = Uri.parse(baseUrl);
    final headers = await _getAuthHeaders(); // Usa o novo método interno

    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode({"tituloEvento": tituloEvento}),
    );

    return _handleResponse(response, 'Erro ao registrar participação.');
  }

  /// 🔹 Listar eventos do usuário
  static Future<List<dynamic>> getMeusEventos() async {
    final url = Uri.parse('$baseUrl/meus-eventos');
    final headers = await _getAuthHeaders(); // Usa o novo método interno
    
    // GET não precisa de Content-Type, mas o _getAuthHeaders o adiciona por padrão. 
    // Podemos removê-lo se o backend for rigoroso, mas geralmente não é necessário remover.
    // headers.remove('Content-Type'); 

    final res = await http.get(url, headers: headers);
    
    final data = await _handleResponse(res, 'Erro ao buscar seus eventos.');
    return data is List ? data : [];
  }

  /// 🔹 Listar participantes de um evento
  static Future<List<dynamic>> getUsuariosPorEvento(String eventoId) async {
    final url = Uri.parse('$baseUrl/evento/$eventoId/usuarios');
    final headers = await _getAuthHeaders(); // Usa o novo método interno
    // headers.remove('Content-Type');

    final res = await http.get(url, headers: headers);

    final data = await _handleResponse(res, 'Erro ao buscar participantes.');
    return data is List ? data : [];
  }
}
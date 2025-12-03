import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../screens/participacao_screen.dart'; 
import '../screens/local_screen.dart'; 
import '../screens/evento_screen.dart'; 
import '../screens/funcionario_screen.dart'; 
import '../screens/usuario_screen.dart'; 

class AppHeader extends StatefulWidget implements PreferredSizeWidget {
  const AppHeader({super.key});

  @override
  State<AppHeader> createState() => _AppHeaderState();

  @override
  Size get preferredSize => const Size.fromHeight(70); 
}

class _AppHeaderState extends State<AppHeader> {
  Map<String, dynamic>? userData;
  final Color headerBgColor = const Color(0xFF051127);
  final Color headerTextColor = Colors.white;
  final Color logoutButtonColor = const Color(0xFFe74c3c);

  @override
  void initState() {
    super.initState();
    carregarUsuario();
  }

  /// Normaliza a string base64url para base64 padrão (para decodificação).
  String normalizeBase64(String str) {
    str = str.replaceAll('-', '+').replaceAll('_', '/');
    while (str.length % 4 != 0) {
      str += '=';
    }
    return str;
  }

  /// Carrega o token JWT e decodifica o payload para obter dados do usuário e role.
  Future<void> carregarUsuario() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    if (token == null) return;

    final parts = token.split('.');
    if (parts.length != 3) {
      print("Erro: Token JWT inválido. Não possui 3 partes.");
      return;
    }

    try {
      final payloadEncoded = parts[1];
      
      // Usa a função de normalização no payload
      final normalizedPayload = normalizeBase64(payloadEncoded); 

      final payload = jsonDecode(
        utf8.decode(base64.decode(normalizedPayload))
      );

      setState(() => userData = payload);
    } catch (e) {
      print("Erro ao decodificar token JWT (Payload): $e");
    }
  }

  /// Remove o token e navega para a tela de autenticação.
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("token");

    Navigator.pushReplacementNamed(context, '/auth'); 
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool showFullMenu = screenWidth > 800; 

    final role = userData?["role"] ?? "VISITANTE";
    final isFuncionario = role != "VISITANTE";
    final isGerente = role == "GERENTE";

    return AppBar(
      automaticallyImplyLeading: false, 
      leading: showFullMenu 
        ? null // Se for tela grande, o leading é nulo.
        : IconButton(
            icon: const Icon(Icons.menu),
            color: headerTextColor,
            onPressed: () {
              // Abre o Drawer. O Scaffold.of(context) é usado para acessar o Scaffold pai.
              Scaffold.of(context).openDrawer(); 
            },
          ),
      backgroundColor: headerBgColor, 
      elevation: 4,
      iconTheme: IconThemeData(color: headerTextColor), 
      
      title: Container(
        constraints: const BoxConstraints(maxWidth: 1200),
        alignment: Alignment.center, 
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween, 
          children: [
            // LOGO E MENU
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // LOGO
                SvgPicture.asset(
                  "assets/EventosTech_20251104_074448_0000.svg",
                  height: 40,
                  colorFilter: ColorFilter.mode(headerTextColor, BlendMode.srcIn), 
                ),
                const SizedBox(width: 20),
                
                // MENU DE NAVEGAÇÃO
                if (showFullMenu)
                  Row(
                    children: [
                      _link("Participe", "/participacoes"),
                      if (isFuncionario) ...[
                        _link("Locais", "/locais"),
                        _link("Eventos", "/eventos"),
                      ],
                      if (isGerente) ...[
                        _link("Funcionários", "/funcionarios"),
                        _link("Usuários", "/usuarios"), 
                      ],
                    ],
                  ),
              ],
            ),
            
            // INFO DO USUÁRIO E LOGOUT
            if (userData != null)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Texto de boas-vindas aparece apenas em telas maiores
                  if (showFullMenu)
                    Text(
                      "Bem-vindo, ${userData!["sub"]} (${userData!["role"]})",
                      style: TextStyle(color: headerTextColor.withOpacity(0.9), fontSize: 15),
                    ),
                  if (showFullMenu) const SizedBox(width: 12),
                  
                  TextButton(
                    onPressed: logout,
                    style: TextButton.styleFrom(
                      backgroundColor: logoutButtonColor,
                      foregroundColor: headerTextColor,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    ),
                    child: const Text("Sair", style: TextStyle(fontWeight: FontWeight.w500)),
                  ),
                ],
              )
          ],
        ),
      ),
    );
  }

  /// Cria um link de navegação instantânea.
  Widget _link(String text, String route) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            PageRouteBuilder(
              pageBuilder: (context, animation1, animation2) => _getWidgetForRoute(route),
              // Transição instantânea
              transitionDuration: Duration.zero, 
              reverseTransitionDuration: Duration.zero, 
            ),
          );
        },
        child: Text(
          text,
          style: TextStyle(
            color: headerTextColor,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  /// Mapeia o nome da rota para o widget da tela correspondente.
  Widget _getWidgetForRoute(String routeName) {
    switch (routeName) {
      case "/participacoes":
        return const ParticipacaoPage();
      case "/locais":
        return const LocalScreen(); 
      case "/eventos":
        return const EventosPage();
      case "/funcionarios":
        return const FuncionariosScreen(); 
      case "/usuarios":
        return const UsuarioScreen(); 
      default:
        return Scaffold(
          body: Center(
            child: Text("Erro: Rota '$routeName' não encontrada no AppHeader."),
          ),
        );
    }
  }
}
// lib/widgets/app_header.dart (CORRIGIDO PARA MOBILE E JWT ROBUSTO)

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_svg/flutter_svg.dart';

// ⚠️ IMPORTAÇÕES NECESSÁRIAS PARA A NAVEGAÇÃO INSTANTÂNEA:
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

  // ✅ FUNÇÃO CORRETA PARA NORMALIZAÇÃO
  String normalizeBase64(String str) {
    str = str.replaceAll('-', '+').replaceAll('_', '/');
    while (str.length % 4 != 0) {
      str += '=';
    }
    return str;
  }

  Future<void> carregarUsuario() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    if (token == null) return;

    // 1. Verificar se o token tem 3 partes (Header.Payload.Signature)
    final parts = token.split('.');
    if (parts.length != 3) {
      print("Erro: Token JWT inválido. Não possui 3 partes.");
      return;
    }

    try {
      final payloadEncoded = parts[1];
      
      // 2. 🎯 USAR A NORMALIZAÇÃO NO PAYLOAD ANTES DE DECODIFICAR
      final normalizedPayload = normalizeBase64(payloadEncoded); 

      final payload = jsonDecode(
        utf8.decode(base64.decode(normalizedPayload))
      );

      setState(() => userData = payload);
    } catch (e) {
      print("Erro ao decodificar token JWT (Payload): $e");
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("token");

    Navigator.pushReplacementNamed(context, '/auth'); 
  }

  @override
  Widget build(BuildContext context) {
    // 💡 LÓGICA DE RESPONSIVIDADE: Obtém a largura da tela
    final screenWidth = MediaQuery.of(context).size.width;
    // Define o breakpoint para o menu completo
    final bool showFullMenu = screenWidth > 800; 

    final role = userData?["role"] ?? "VISITANTE";
    final isFuncionario = role != "VISITANTE";
    final isGerente = role == "GERENTE";

    return AppBar(
      // ⚠️ REMOVIDA LÓGICA MANUAL: Deixe o Flutter decidir se deve mostrar o botão de voltar.
      // Se tiver um Drawer, ele será substituído pelo ícone de menu.
      automaticallyImplyLeading: true, 
      
      backgroundColor: headerBgColor, 
      elevation: 4,
      iconTheme: IconThemeData(color: headerTextColor), 
      
      title: Container(
        constraints: const BoxConstraints(maxWidth: 1200),
        alignment: Alignment.center, 
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween, // 🎯 Corrigido para espaçamento horizontal
          children: [
            // LOGO
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // LOGO SVG
                SvgPicture.asset(
                  "assets/EventosTech_20251104_074448_0000.svg",
                  height: 40,
                  colorFilter: ColorFilter.mode(headerTextColor, BlendMode.srcIn), 
                ),
                const SizedBox(width: 20),
                
                // MENU DE NAVEGAÇÃO (Aparece apenas se houver largura suficiente)
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
            
            // ⚠️ REMOVIDO: const Spacer(), // O Spacer causa o overflow em telas pequenas
            
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
            // ⚠️ REMOVIDO: O ÍCONE DE MENU MANUAL FOI REMOVIDO.
            // O Flutter irá adicionar o ícone de menu se o Scaffold tiver um Drawer.
          ],
        ),
      ),
    );
  }

  // ✅ WIDGET AUXILIAR PARA NAVEGAÇÃO INSTANTÂNEA
  // ... (função _link e _getWidgetForRoute permanecem inalteradas) ...
  Widget _link(String text, String route) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: InkWell(
        onTap: () {
          // Usa PageRouteBuilder para transição instantânea (sem animação)
          Navigator.of(context).push(
            PageRouteBuilder(
              // Retorna o Widget mapeado pela rota
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

  // ✅ MAPEA O NOME DA ROTA PARA O WIDGET DA TELA
  Widget _getWidgetForRoute(String routeName) {
    switch (routeName) {
      case "/participacoes":
        return const ParticipacaoPage();
      case "/locais":
        // Corrigido para LocalScreen
        return const LocalScreen(); 
      case "/eventos":
        return const EventosPage();
      case "/funcionarios":
        // Corrigido para FuncionariosScreen
        return const FuncionariosScreen(); 
      case "/usuarios":
        // Corrigido para UsuarioScreen
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
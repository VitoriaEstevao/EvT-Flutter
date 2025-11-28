import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AppHeader extends StatefulWidget implements PreferredSizeWidget {
  const AppHeader({super.key});

  @override
  State<AppHeader> createState() => _AppHeaderState();

  @override
  Size get preferredSize => const Size.fromHeight(70);
}

class _AppHeaderState extends State<AppHeader> {
  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();
    carregarUsuario();
  }

  // Normaliza o Base64 do JWT para evitar erros de padding
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

    try {
      final payload = jsonDecode(
        utf8.decode(base64.decode(normalizeBase64(token.split('.')[1])))
      );

      setState(() => userData = payload);
    } catch (e) {
      print("Erro ao decodificar token: $e");
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("token");

    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    final role = userData?["role"] ?? "VISITANTE";
    final isFuncionario = role != "VISITANTE";
    final isGerente = role == "GERENTE";

    return AppBar(
      backgroundColor: Colors.white,
      elevation: 4,
      title: Row(
        children: [
          SvgPicture.asset(
            "assets/EventosTech_20251104_074448_0000.svg",
            height: 40,
          ),
          const SizedBox(width: 20),

          // MENU
          Row(
            children: [
              _link("Participe", "/participacoes"),
              if (isFuncionario) ...[
                _link("Locais", "/locais"),
                _link("Eventos", "/eventos"),
              ],
              if (isGerente) ...[
                _link("Funcionários", "/funcionarios"),
              ],
            ],
          ),
          const Spacer(),

          // INFO DO USUÁRIO
          if (userData != null)
            Row(
              children: [
                Text(
                  "Bem-vindo, ${userData!["sub"]} (${userData!["role"]})",
                  style: const TextStyle(color: Colors.black87),
                ),
                const SizedBox(width: 12),
                TextButton(
                  onPressed: logout,
                  child: const Text("Sair"),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _link(String text, String route) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: InkWell(
        onTap: () => Navigator.pushNamed(context, route),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}

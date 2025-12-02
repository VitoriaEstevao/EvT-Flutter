// lib/widgets/app_layout.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_header.dart';

// Imports limpos e sem espaços invisíveis
import '../screens/participacao_screen.dart'; 
import '../screens/local_screen.dart'; 
import '../screens/evento_screen.dart'; 
import '../screens/funcionario_screen.dart'; 
import '../screens/usuario_screen.dart'; 

// ----------------------------------------------------
// 🎯 DADOS DE MAPEAMENTO (Cargos mapeados para Níveis)
// ----------------------------------------------------

// 🎯 APENAS CARGOS COM PERMISSÕES DE GERENTE
const List<String> _gerenteCargos = [
  'GERENTE', 
];

// 🎯 CARGOS COM PERMISSÕES DE FUNCIONARIO (nível intermediário)
const List<String> _funcionarioCargos = [
  'ANALISTA', 
  'ESTAGIARIO', 
  'APRENDIZ',
  'COORDENADOR', // AGORA É FUNCIONÁRIO
];

// ----------------------------------------------------

class AppLayout extends StatelessWidget {
  final Widget body;
  final String userRole; // Para filtrar os links do Drawer

  const AppLayout({
    super.key,
    required this.body,
    required this.userRole,
  });

  // 1. Normaliza o papel para ser fácil de comparar (Remove espaços e usa MAIÚSCULAS)
  String get _normalizedRole {
    return userRole.trim().toUpperCase();
  }

  // 2. isGerente verifica se o cargo está na lista de GERENTE
  bool get isGerente => _gerenteCargos.contains(_normalizedRole);

  // 3. isFuncionario verifica se o cargo está na lista de FUNCIONARIO OU se é GERENTE
  bool get isFuncionario {
    return _funcionarioCargos.contains(_normalizedRole) || isGerente;
  }

  // --- MÉTODOS AUXILIARES ---

  // 1. Mapeia a Rota para o Widget
  Widget _getWidgetForRoute(String routeName) {
    switch (routeName) {
      case "/participacoes": return const ParticipacaoPage();
      case "/locais": return const LocalScreen(); 
      case "/eventos": return const EventosPage();
      case "/funcionarios": return const FuncionariosScreen(); 
      case "/usuarios": return const UsuarioScreen(); 
      default: 
        return Scaffold(
          body: Center(child: Text("Erro: Rota '$routeName' não encontrada no Layout.")),
        );
    }
  }

  // 2. Constrói o Item do Drawer
  Widget _buildDrawerItem(BuildContext context, String title, String route, IconData icon, {required bool requiredPermission}) {
    if (!requiredPermission) return const SizedBox.shrink();

    return ListTile(
      leading: Icon(icon, color: const Color(0xFF051127)),
      title: Text(title, style: const TextStyle(fontSize: 16)),
      onTap: () {
        Navigator.pop(context); // 1. Fecha o Drawer
        
        // 2. Navegação instantânea (sem animação)
        Navigator.of(context).push(
          PageRouteBuilder(
            pageBuilder: (context, animation1, animation2) => _getWidgetForRoute(route),
            transitionDuration: Duration.zero, 
            reverseTransitionDuration: Duration.zero, 
          ),
        );
      },
    );
  }

  // --- BUILD PRINCIPAL ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeader(), 
      
      // 🎯 DRAWER CENTRALIZADO
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            // Cabeçalho do Drawer
            const DrawerHeader(
              decoration: BoxDecoration(color: Color(0xFF051127)),
              child: Text(
                'Menu de Navegação',
                style: TextStyle(color: Colors.white, fontSize: 22),
              ),
            ),
            
            // Links de Navegação com Permissão
            _buildDrawerItem(context, "Participe", "/participacoes", Icons.event_available, requiredPermission: true),
            
            // FUNCIONARIOS e GERENTES (Nível Intermediário)
            if (isFuncionario) ...[
              _buildDrawerItem(context, "Locais", "/locais", Icons.location_on, requiredPermission: true),
              _buildDrawerItem(context, "Eventos", "/eventos", Icons.calendar_month, requiredPermission: true),
            ],
            
            // APENAS GERENTES (Nível Mais Alto)
            if (isGerente) ...[
              _buildDrawerItem(context, "Funcionários", "/funcionarios", Icons.people_alt, requiredPermission: true),
              _buildDrawerItem(context, "Usuários", "/usuarios", Icons.person_search, requiredPermission: true),
            ],
            
            const Divider(),

            // Opção Sair (Logout)
            ListTile(
              leading: const Icon(Icons.exit_to_app),
              title: const Text('Sair'),
              onTap: () async {
                Navigator.pop(context); // Fecha o drawer
                final prefs = await SharedPreferences.getInstance();
                await prefs.remove("token");
                Navigator.pushReplacementNamed(context, '/auth'); 
              },
            ),
          ],
        ),
      ),
      
      // Conteúdo da Tela (O que for passado para o Layout)
      body: body,
    );
  }
}
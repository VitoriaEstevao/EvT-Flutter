import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_header.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../screens/participacao_screen.dart'; 
import '../screens/local_screen.dart'; 
import '../screens/evento_screen.dart'; 
import '../screens/funcionario_screen.dart'; 
import '../screens/usuario_screen.dart'; 

// Cargos com permissão de Gerente
const List<String> _gerenteCargos = [
  'GERENTE', 
];

// Cargos com permissão de Funcionário (incluindo Gerente)
const List<String> _funcionarioCargos = [
  'ANALISTA', 
  'ESTAGIARIO', 
  'APRENDIZ',
  'COORDENADOR',
];

class AppLayout extends StatelessWidget {
  final Widget body;
  final String userRole; 

  const AppLayout({
    super.key,
    required this.body,
    required this.userRole,
  });

  String get _normalizedRole {
    return userRole.trim().toUpperCase();
  }

  // Verifica se o usuário tem permissão de Gerente.
  bool get isGerente => _gerenteCargos.contains(_normalizedRole);

  // Verifica se o usuário tem permissão de Funcionário ou superior.
  bool get isFuncionario {
    return _funcionarioCargos.contains(_normalizedRole) || isGerente;
  }

  // Mapeia a string da rota para o widget da tela correspondente.
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

  // Constrói um item de menu para o Drawer com navegação instantânea.
  Widget _buildDrawerItem(BuildContext context, String title, String route, IconData icon, {required bool requiredPermission}) {
    if (!requiredPermission) return const SizedBox.shrink();

    return ListTile(
      leading: Icon(icon, color: const Color(0xFF051127)),
      title: Text(title, style: const TextStyle(fontSize: 16)),
      onTap: () {
        Navigator.pop(context); 
        
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

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isLargeScreen = screenWidth > 800;

    return Scaffold(
      appBar: const AppHeader(), 
      
      // Menu lateral (Drawer)
      drawer: isLargeScreen
        ? null 
        : Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              const DrawerHeader(
                decoration: BoxDecoration(color: Color(0xFF051127)),
                child: Text(
                  'Menu de Navegação',
                  style: TextStyle(color: Colors.white, fontSize: 22),
                ),
              ),
              
              // Link Participação (Todos)
              _buildDrawerItem(context, "Participe", "/participacoes", Icons.event_available, requiredPermission: true),
              
              // Links para Funcionários e Gerentes
              if (isFuncionario) ...[
                _buildDrawerItem(context, "Locais", "/locais", Icons.location_on, requiredPermission: true),
                _buildDrawerItem(context, "Eventos", "/eventos", Icons.calendar_month, requiredPermission: true),
              ],
              
              // Links exclusivos para Gerentes
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
                  Navigator.pop(context); 
                  final prefs = await SharedPreferences.getInstance();
                  // Remove o token de autenticação
                  await prefs.remove("token");
                  Navigator.pushReplacementNamed(context, '/auth'); 
                },
              ),
            ],
          ),
        ),
      
      // Conteúdo principal da tela
      body: body,
    );
  }
}
import 'package:flutter/material.dart';

import 'screens/auth_screen.dart';
import 'screens/evento_screen.dart';
import 'screens/local_screen.dart';
import 'screens/participacao_screen.dart';
import 'screens/funcionario_screen.dart';
import 'screens/usuario_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sistema de Gestão de Eventos',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2563EB)),
        useMaterial3: true,
      ),
      
      // Define a tela de autenticação como a inicial.
      initialRoute: '/auth', 
      
      routes: {
        // Rota de Autenticação
        '/auth': (context) => const AuthScreen(),
        
        // Rotas de Funcionalidade
        '/participacoes': (context) => const ParticipacaoPage(),
        '/eventos': (context) => const EventosPage(), 
        '/locais': (context) => const LocalScreen(), 
        '/funcionarios': (context) => const FuncionariosScreen(), 
        '/usuarios': (context) => const UsuarioScreen(), 
      },
    );
  }
}
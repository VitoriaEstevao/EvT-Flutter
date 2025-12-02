// lib/main.dart

import 'package:flutter/material.dart';

// === Importações ===
// Assumindo que AuthScreen lida com Login e Cadastro
import 'screens/auth_screen.dart'; // Tela de Autenticação Unificada
import 'screens/evento_screen.dart';
import 'screens/local_screen.dart';
import 'screens/participacao_screen.dart';
import 'screens/funcionario_screen.dart';
import 'screens/usuario_screen.dart';

// Nomes das classes de tela (ajuste se necessário, usei as mais prováveis)
// AuthScreen, EventosPage, LocalScreen, ParticipacaoPage, FuncionariosPage, UsuariosScreen

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
        // Mantendo o tema que você definiu (ou parecido com o anterior)
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2563EB)),
        useMaterial3: true,
      ),
      
      // Defina a tela de autenticação (AuthScreen) como tela inicial
      initialRoute: '/auth', 
      
      routes: {
        // === 1. Rota de Autenticação ===
        '/auth': (context) => const AuthScreen(),
        
        // === 2. Rotas de Funcionalidade (Gestão) ===
        '/participacoes': (context) => const ParticipacaoPage(),
        '/eventos': (context) => const EventosPage(), 
        '/locais': (context) => const LocalScreen(), 
        '/funcionarios': (context) => const FuncionariosScreen(), 
        '/usuarios': (context) => const UsuarioScreen(), 
        
        // Exemplo: Rota de Dashboard (caso exista uma tela após o login)
        // '/dashboard': (context) => const DashboardScreen(), 
      },
    );
  }
}
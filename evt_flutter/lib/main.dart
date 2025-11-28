import 'package:flutter/material.dart';
import 'screens/login_screen.dart'; // importe sua tela de login
import 'screens/evento_screen.dart';
import 'screens/local_screen.dart';
import 'screens/participacao_screen.dart';
import 'screens/funcionario_screen.dart';
import 'screens/cadastro_screen.dart';
import 'screens/usuarios_screen.dart';

void main() {
  runApp(MaterialApp(
    initialRoute: "/login",
    routes: {
      "/login": (_) => LoginScreen(),
      "/auth": (_) => AuthPage(),
      "/participacoes": (_) => ParticipacaoPage(),
      "/eventos": (_) => EventoScreen(),
      "/locais": (_) => LocalScreen(),
      "/funcionarios": (_) => FuncionariosPage(),
      '/usuarios': (context) => UsuariosScreen(),
    },
  ));
}


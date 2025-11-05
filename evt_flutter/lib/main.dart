import 'package:flutter/material.dart';
import 'screens/login_screen.dart'; // importe sua tela de login

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Eventos Tech',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const LoginScreen(), // inicia pela tela de login
    );
  }
}

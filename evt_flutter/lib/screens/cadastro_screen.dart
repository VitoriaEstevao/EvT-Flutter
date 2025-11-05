import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthPage extends StatefulWidget {
  const AuthPage({Key? key}) : super(key: key);

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool isLogin = true;
  bool loading = false;

  final TextEditingController nomeController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController senhaController = TextEditingController();
  final TextEditingController cpfController = TextEditingController();

  Future<void> handleSubmit() async {
    setState(() => loading = true);

    final String nome = nomeController.text;
    final String email = emailController.text;
    final String senha = senhaController.text;
    final String cpf = cpfController.text;

    try {
      if (isLogin) {
        // Login
        final response = await http.post(
          Uri.parse('http://localhost:8080/login'), // ajuste a URL
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'email': email, 'senha': senha}),
        );

        if (response.statusCode == 200) {
          // Redirecionar ou mostrar mensagem
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Login realizado com sucesso!')),
          );
        } else {
          throw Exception('Erro no login');
        }
      } else {
        // Cadastro
        final response = await http.post(
          Uri.parse('http://localhost:8080/cadastro'), // ajuste a URL
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'nome': nome,
            'email': email,
            'senha': senha,
            'cpf': cpf,
          }),
        );

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Cadastro realizado com sucesso!')),
          );
          setState(() => isLogin = true);
        } else {
          throw Exception('Erro no cadastro');
        }
      }

      // Limpar campos
      nomeController.clear();
      emailController.clear();
      senhaController.clear();
      cpfController.clear();

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      setState(() => loading = false);
    }
  }

  void toggleMode() {
    setState(() => isLogin = !isLogin);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!isLogin)
                TextField(
                  controller: nomeController,
                  decoration: const InputDecoration(labelText: 'Nome'),
                ),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              TextField(
                controller: senhaController,
                decoration: const InputDecoration(labelText: 'Senha'),
                obscureText: true,
              ),
              if (!isLogin)
                TextField(
                  controller: cpfController,
                  decoration: const InputDecoration(labelText: 'CPF'),
                ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: loading ? null : handleSubmit,
                child: Text(loading ? 'Carregando...' : isLogin ? 'Entrar' : 'Cadastrar'),
              ),
              TextButton(
                onPressed: toggleMode,
                child: Text(isLogin ? 'Criar conta' : 'Já tenho conta'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../services/cadastro_service.dart';
import 'cadastro_screen.dart'; // Importa a tela de cadastro

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final senhaController = TextEditingController();
  bool loading = false;

  Future<void> fazerLogin() async {
    setState(() => loading = true);
    try {
      final data = await CadastroService.loginUsuario(
        emailController.text,
        senhaController.text,
      );
      print('Login bem-sucedido: $data');

      // Exemplo: navegar para a tela principal
      // Navigator.pushReplacementNamed(context, '/locais');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'E-mail'),
            ),
            TextField(
              controller: senhaController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Senha'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: loading ? null : fazerLogin,
              child: loading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Entrar'),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AuthPage()),
                );
              },
              child: const Text('Não tem cadastro? Criar conta'),
            ),
          ],
        ),
      ),
    );
  }
}

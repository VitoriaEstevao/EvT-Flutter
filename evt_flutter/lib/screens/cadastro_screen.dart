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
        final response = await http.post(
          Uri.parse('http://localhost:8080/login'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'email': email, 'senha': senha}),
        );

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Login realizado com sucesso!')),
          );
        } else {
          throw Exception('Erro no login');
        }
      } else {
        final response = await http.post(
          Uri.parse('http://localhost:8080/auth'),
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
      backgroundColor: const Color(0xFFF3F4F6), // cor leve de fundo
      body: Center(
        child: Container(
          width: 420,
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE5E7EB)),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isLogin ? "Entrar" : "Criar Conta",
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF111827),
                ),
              ),

              const SizedBox(height: 20),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isLogin) ...[
                    const Text(
                      "Nome",
                      style: TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: nomeController,
                      decoration: inputStyle("Digite seu nome"),
                    ),
                    const SizedBox(height: 14),
                  ],

                  const Text(
                    "Email",
                    style:
                        TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: emailController,
                    decoration: inputStyle("Digite seu email"),
                  ),
                  const SizedBox(height: 14),

                  const Text(
                    "Senha",
                    style:
                        TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: senhaController,
                    decoration: inputStyle("Digite sua senha"),
                    obscureText: true,
                  ),
                  const SizedBox(height: 14),

                  if (!isLogin) ...[
                    const Text(
                      "CPF",
                      style: TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: cpfController,
                      decoration: inputStyle("Digite seu CPF"),
                    ),
                  ],
                ],
              ),

              const SizedBox(height: 22),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: loading ? null : handleSubmit,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    backgroundColor: const Color(0xFF10B981),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    loading
                        ? "Carregando..."
                        : isLogin
                            ? "Entrar"
                            : "Cadastrar",
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              TextButton(
                onPressed: toggleMode,
                child: Text(
                  isLogin ? "Criar conta" : "Já tenho conta",
                  style: const TextStyle(
                    color: Color(0xFF2563EB),
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration inputStyle(String placeholder) {
    return InputDecoration(
      hintText: placeholder,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}

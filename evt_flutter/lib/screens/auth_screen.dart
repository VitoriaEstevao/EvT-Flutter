import 'package:flutter/material.dart';
import '../services/cadastro_service.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  // Inicialmente no modo login, para refletir a AuthPage do React
  bool isLogin = true; 
  bool loading = false;

  final TextEditingController nomeController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController senhaController = TextEditingController();
  final TextEditingController cpfController = TextEditingController();

  // Função central para Login ou Cadastro
  Future<void> handleSubmit() async {
    setState(() => loading = true);

    try {
      if (isLogin) {
        // --- LÓGICA DE LOGIN ---
        await CadastroService.loginUsuario(
          emailController.text,
          senhaController.text,
        );

        // Limpa os campos após sucesso
        emailController.clear();
        senhaController.clear();

        // Navega para a tela principal (ajuste a rota se necessário)
        Navigator.pushReplacementNamed(context, '/participacoes');
        
      } else {
        // --- LÓGICA DE CADASTRO ---
        await CadastroService.cadastrarUsuario(
          nome: nomeController.text,
          email: emailController.text,
          senha: senhaController.text,
          cpf: cpfController.text,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cadastro realizado com sucesso! Faça seu login.'),
            backgroundColor: Color(0xFF10B981), // Cor de sucesso
          ),
        );
        
        // Retorna para o modo Login após o cadastro bem-sucedido
        toggleMode(forceLogin: true); 
      }
    } catch (e) {
      // Exibe o erro retornado pelo serviço (Spring Boot)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      setState(() => loading = false);
    }
  }

  void toggleMode({bool forceLogin = false}) {
    // Limpa todos os campos ao trocar o modo
    nomeController.clear();
    emailController.clear();
    senhaController.clear();
    cpfController.clear();
    
    setState(() {
      isLogin = forceLogin ? true : !isLogin;
    });
  }

  // Estilo de input unificado (pode ser movido para um arquivo de tema)
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

  // Helper para criar o campo de texto completo
  Widget buildTextField(
      String label, TextEditingController controller, String placeholder,
      {bool obscureText = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          decoration: inputStyle(placeholder),
          obscureText: obscureText,
        ),
        const SizedBox(height: 14),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6), 
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
          child: SingleChildScrollView( // Para evitar overflow em telas menores
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

                // Campos para Cadastro (só aparecem quando !isLogin)
                if (!isLogin) ...[
                  buildTextField("Nome", nomeController, "Digite seu nome"),
                  buildTextField("CPF", cpfController, "Digite seu CPF"),
                ],
                
                // Campos comuns (Email e Senha)
                buildTextField("Email", emailController, "Digite seu email"),
                buildTextField("Senha", senhaController, "Digite sua senha", obscureText: true),

                const SizedBox(height: 8),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: loading ? null : handleSubmit,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      backgroundColor: isLogin ? const Color(0xFF2563EB) : const Color(0xFF10B981),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: loading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            isLogin ? "Entrar" : "Cadastrar",
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 12),

                TextButton(
                  onPressed: toggleMode,
                  child: Text(
                    isLogin ? "Ainda não tem conta? Criar conta" : "Já tem conta? Entrar",
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
      ),
    );
  }
}
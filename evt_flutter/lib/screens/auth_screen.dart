import 'package:flutter/material.dart';
import '../services/cadastro_service.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isLogin = true; // Define se o modo atual é Login ou Cadastro
  bool loading = false;

  final TextEditingController nomeController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController senhaController = TextEditingController();
  final TextEditingController cpfController = TextEditingController();

  /// Realiza a operação de Login ou Cadastro.
  Future<void> handleSubmit() async {
    setState(() => loading = true);

    try {
      if (isLogin) {
        // Lógica de Login
        await CadastroService.loginUsuario(
          emailController.text,
          senhaController.text,
        );

        emailController.clear();
        senhaController.clear();

        // Navega para a tela principal
        Navigator.pushReplacementNamed(context, '/participacoes');
        
      } else {
        // Lógica de Cadastro
        await CadastroService.cadastrarUsuario(
          nome: nomeController.text,
          email: emailController.text,
          senha: senhaController.text,
          cpf: cpfController.text,
        );

        // Exibe mensagem de sucesso e volta para o modo Login
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cadastro realizado com sucesso! Faça seu login.'),
            backgroundColor: Color(0xFF10B981),
          ),
        );
        
        toggleMode(forceLogin: true); 
      }
    } catch (e) {
      // Exibe erro
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

  /// Alterna entre os modos Login e Cadastro e limpa os campos.
  void toggleMode({bool forceLogin = false}) {
    nomeController.clear();
    emailController.clear();
    senhaController.clear();
    cpfController.clear();
    
    setState(() {
      isLogin = forceLogin ? true : !isLogin;
    });
  }

  // Estilo de input padrao
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

  // Componente para criar o campo de texto
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
          child: SingleChildScrollView( 
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

                // Campos de Cadastro (apenas se for modo Cadastro)
                if (!isLogin) ...[
                  buildTextField("Nome", nomeController, "Digite seu nome"),
                  buildTextField("CPF", cpfController, "Digite seu CPF"),
                ],
                
                // Campos Email e Senha
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
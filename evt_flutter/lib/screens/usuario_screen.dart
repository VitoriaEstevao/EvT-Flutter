import 'package:flutter/material.dart';
import '../services/usuarios_service.dart'; // Importação: UsuarioService
import 'package:evt_flutter/widgets/app_layout.dart';
import '../widgets/app_header.dart';
import 'dart:convert'; // 🎯 Adicionar para jsonDecode, utf8 e base64
import 'package:shared_preferences/shared_preferences.dart';

class UsuarioScreen extends StatefulWidget {
  const UsuarioScreen({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _UsuarioScreenState createState() => _UsuarioScreenState();
}

class _UsuarioScreenState extends State<UsuarioScreen> {
  // Estado
  List<dynamic> usuarios = [];
  Map<String, dynamic>? usuarioEditando;
  bool mostrarForm = false;
  String mensagemAlerta = "";
  bool isError = false;
  bool loading = false;
  String? userRole;


  // Controladores de Formulário
  final nomeCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final cpfCtrl = TextEditingController();
  final senhaCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    carregarTokenRole();
    carregarUsuarios();
  }

  @override
  void dispose() {
    nomeCtrl.dispose();
    emailCtrl.dispose();
    cpfCtrl.dispose();
    senhaCtrl.dispose();
    super.dispose();
  }

  // --- LÓGICA DE DADOS ---

  Future<void> carregarTokenRole() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    if (token != null) {
      final parts = token.split('.');
      if (parts.length == 3) {
        final payload = jsonDecode(
          utf8.decode(base64.decode(base64.normalize(parts[1]))),
        );
        // ⚠️ Use setState para atualizar o userRole e reconstruir o widget
        setState(() => userRole = payload["role"]);
      }
    }
  }

  Future<void> carregarUsuarios() async {
    setState(() {
      mensagemAlerta = "";
      isError = false;
    });
    try {
      // CORREÇÃO: Usando UsuarioService (singular)
      final data = await UsuarioService.getUsuarios();
      setState(() => usuarios = data);
    } catch (e) {
      setState(() {
        mensagemAlerta = e.toString().replaceFirst('Exception: ', '');
        isError = true;
      });
    }
  }

  void preencherForm(Map<String, dynamic> usuario) {
    limparFormulario(manterVisibilidade: true);
    
    usuarioEditando = usuario;

    nomeCtrl.text = usuario["nome"] ?? "";
    emailCtrl.text = usuario["email"] ?? "";
    cpfCtrl.text = usuario["cpf"] ?? "";
    senhaCtrl.text = ""; // Nunca preencha a senha existente

    setState(() => mostrarForm = true);
  }

  Future<void> salvar() async {
    setState(() {
      loading = true;
      mensagemAlerta = "";
      isError = false;
    });

    final body = {
      "nome": nomeCtrl.text,
      "email": emailCtrl.text,
      "cpf": cpfCtrl.text,
      // Só envia a senha se estiver no modo Cadastro ou se for digitada na Edição
      if (senhaCtrl.text.isNotEmpty) "senha": senhaCtrl.text,
    };

    try {
      if (usuarioEditando != null) {
        // ID é necessário para edição
        final id = usuarioEditando!["id"]; 
        if (id == null) throw Exception("ID do usuário não encontrado para edição.");
        
        // CORREÇÃO: Usando UsuarioService (singular)
        await UsuarioService.editarUsuario(id, body);
        setState(() {
          mensagemAlerta = "Usuário atualizado com sucesso!";
          isError = false;
        });
      } else {
        // A senha é obrigatória no cadastro
        if (senhaCtrl.text.isEmpty) {
            throw Exception("A senha é obrigatória para o cadastro.");
        }
        // CORREÇÃO: Usando UsuarioService (singular)
        await UsuarioService.criarUsuario(body);
        setState(() {
          mensagemAlerta = "Usuário cadastrado com sucesso!";
          isError = false;
        });
      }

      await carregarUsuarios();

      limparFormulario();
      setState(() => mostrarForm = false);
    } catch (e) {
      setState(() {
        mensagemAlerta = e.toString().replaceFirst('Exception: ', '');
        isError = true;
      });
    } finally {
      setState(() => loading = false);
    }
  }

  Future<void> deletar(int id) async {
    setState(() {
      mensagemAlerta = "";
      isError = false;
    });
    try {
      // CORREÇÃO: Usando UsuarioService (singular)
      await UsuarioService.deletarUsuario(id);
      await carregarUsuarios();
      setState(() {
        mensagemAlerta = "Usuário deletado com sucesso!";
        isError = false;
      });
    } catch (e) {
      setState(() {
        mensagemAlerta = e.toString().replaceFirst('Exception: ', '');
        isError = true;
      });
    }
  }

  void limparFormulario({bool manterVisibilidade = false}) {
    usuarioEditando = null;
    nomeCtrl.clear();
    emailCtrl.clear();
    cpfCtrl.clear();
    senhaCtrl.clear();
    if(!manterVisibilidade) {
      setState(() => mostrarForm = false);
    }
  }

  // --- WIDGETS ---

  InputDecoration inputStyle(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
      ),
    );
  }

  Widget buildForm() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 12,
            offset: Offset(0, 4),
          )
        ],
      ),
      child: Column(
        children: [
          // Mensagem de Alerta (Sucesso ou Erro)
          if (mensagemAlerta.isNotEmpty && (mostrarForm || isError))
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 15),
              decoration: BoxDecoration(
                color: isError ? Colors.red.shade100 : Colors.green.shade100,
                border: Border.all(color: isError ? Colors.red.shade300 : Colors.green.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                mensagemAlerta,
                style: TextStyle(color: isError ? Colors.red.shade900 : Colors.green.shade900),
                textAlign: TextAlign.center,
              ),
            ),
            
          TextField(controller: nomeCtrl, decoration: inputStyle("Nome")),
          const SizedBox(height: 10),
          TextField(controller: emailCtrl, decoration: inputStyle("Email")),
          const SizedBox(height: 10),
          TextField(controller: cpfCtrl, decoration: inputStyle("CPF")),
          const SizedBox(height: 10),
          TextField(
            controller: senhaCtrl,
            decoration: inputStyle(usuarioEditando != null ? "Nova Senha (Opcional)" : "Senha"),
            obscureText: true,
          ),
          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: loading ? null : salvar,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                backgroundColor: usuarioEditando != null ? const Color(0xFF2563EB) : Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: loading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                    )
                  : Text(
                      usuarioEditando != null ? "Atualizar" : "Cadastrar",
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16),
                    ),
            ),
          )
        ],
      ),
    );
  }

  Widget buildCard(dynamic usuario) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        title: Text(
          usuario["nome"],
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Email: ${usuario["email"]}"),
            Text("CPF: ${usuario["cpf"]}"),
          ],
        ),
        isThreeLine: true,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Color(0xFF2563EB)),
              onPressed: () => preencherForm(usuario),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              // O ID do usuário geralmente é um inteiro no Spring
              onPressed: () => deletar(usuario["id"] as int), 
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      userRole: userRole ?? "VISITANTE",
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Header + botão expandir
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  usuarioEditando != null ? "Editar Usuário" : "Cadastrar Usuário",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: mostrarForm ? Colors.grey : const Color(0xFF2563EB),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    if (mostrarForm) {
                      limparFormulario();
                    }else {
                      limparFormulario(manterVisibilidade: true);
                      setState(() => mostrarForm = !mostrarForm);
                    }
                  },
                  icon: Icon(
                    mostrarForm ? Icons.close : Icons.add,
                    color: Colors.white,
                  ),
                  label: Text(
                    mostrarForm ? "Fechar" : "Novo Usuário",
                    style: const TextStyle(color: Colors.white),
                  ),
                )
              ],
            ),

            const SizedBox(height: 20),

            if (mostrarForm) buildForm(),

            const SizedBox(height: 30),

            // Mensagem de Alerta (para operações de delete ou falha geral)
            if (mensagemAlerta.isNotEmpty && !mostrarForm)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 15),
                decoration: BoxDecoration(
                  color: isError ? Colors.red.shade100 : Colors.green.shade100,
                  border: Border.all(color: isError ? Colors.red.shade300 : Colors.green.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  mensagemAlerta,
                  style: TextStyle(color: isError ? Colors.red.shade900 : Colors.green.shade900),
                  textAlign: TextAlign.center,
                ),
              ),

            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Usuários Cadastrados",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 14),

            if (usuarios.isEmpty)
              const Text("Nenhum usuário cadastrado", style: TextStyle(color: Colors.grey)),

            ...usuarios.map(buildCard).toList(),
          ],
        ),
      ),
    );
  }
}
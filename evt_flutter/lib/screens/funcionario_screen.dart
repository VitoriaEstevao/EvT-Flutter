// funcionarios_screen.dart (Design Atualizado)

import 'dart:convert';
import 'package:evt_flutter/widgets/app_layout.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart'; // Para usar o objeto Response
import '../services/funcionario_service.dart';
// Note: 'AppHeader' foi mantido, mas 'AppTheme' foi removido para usar os estilos inline da UsuarioScreen
import '../widgets/app_header.dart'; // Mantido, assumindo que você ainda quer usar

class FuncionariosScreen extends StatefulWidget {
  // Renomeado para seguir o padrão 'Screen'
  const FuncionariosScreen({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _FuncionariosScreenState createState() => _FuncionariosScreenState();
}

class _FuncionariosScreenState extends State<FuncionariosScreen> {
  // === ESTADO DA TELA ===
  List<dynamic> funcionarios = [];
  Map<String, dynamic>? funcionarioEditando; // Funcionário atualmente em edição
  bool mostrarForm = false; // Estado para mostrar/esconder o formulário
  bool loading = false; // Estado de carregamento
  String? userRole;
  // Controladores de Formulário
  final TextEditingController nomeCtrl = TextEditingController();
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController cpfCtrl = TextEditingController();
  final TextEditingController senhaCtrl = TextEditingController();

  String cargo = "";
  String departamento = "";

  // Estado de Mensagens de Alerta (Sucesso ou Erro - Unificado como em UsuarioScreen)
  String mensagemAlerta = "";
  bool isError = false; // Indica se mensagemAlerta é um erro

  // Dados Fixos
  final cargos = [
    'GERENTE', 'ANALISTA', 'ESTAGIARIO', 'COORDENADOR', 'APRENDIZ', 'VISITANTE'
  ];
  final departamentos = [
    'FINANCEIRO', 'TI', 'RH', 'JURIDICO', 'MARKETING'
  ];

  @override
  void initState() {
    super.initState();
    carregarTokenRole();
    carregarFuncionarios();
  }

  @override
  void dispose() {
    nomeCtrl.dispose();
    emailCtrl.dispose();
    cpfCtrl.dispose();
    senhaCtrl.dispose();
    super.dispose();
  }

  // Função auxiliar para processar e exibir erros do backend
  Future<void> _processarErros(Object error) async {
    String errorMessage = "Erro de conexão com o servidor.";

    if (error is Response) {
      try {
        final errorData = jsonDecode(error.body);
        
        // Verifica se há uma mensagem principal ou erros detalhados de campo
        if (errorData['mensagem'] != null) {
          errorMessage = errorData['mensagem'].toString();
        } else if (errorData['erros'] is Map) {
           // Pega o primeiro erro detalhado de campo
           final fieldErrors = errorData['erros'] as Map<String, dynamic>;
           if (fieldErrors.isNotEmpty) {
             errorMessage = fieldErrors.values.first.toString();
           }
        } else {
           errorMessage = "Ocorreu um erro (${error.statusCode}). Consulte o console.";
        }
      } catch (_) {
        // Se o body não for JSON, usa a mensagem genérica
        errorMessage = "Ocorreu um erro (${error.statusCode}). Consulte o console.";
      }
    } else if (error is Exception) {
      errorMessage = error.toString().replaceFirst('Exception: ', '');
    }

    setState(() {
      mensagemAlerta = errorMessage;
      isError = true;
    });
  }

  // Limpar formulário e estado de edição
  void limparFormulario({bool manterVisibilidade = false}) {
    funcionarioEditando = null;
    nomeCtrl.clear();
    emailCtrl.clear();
    cpfCtrl.clear();
    senhaCtrl.clear();
    cargo = "";
    departamento = "";
    // Limpa apenas o erro se o form for fechado
    if(!manterVisibilidade) {
      setState(() {
        mostrarForm = false;
        mensagemAlerta = "";
        isError = false;
      });
    }
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

  Future<void> carregarFuncionarios() async {
    setState(() {
      mensagemAlerta = "";
      isError = false;
      loading = true; // Adicionado loading na lista também
    });
    try {
      final data = await FuncionarioService.getFuncionarios();
      setState(() => funcionarios = data);
    } catch (e) {
      await _processarErros(e);
    } finally {
      setState(() => loading = false);
    }
  }

  void preencherForm(Map<String, dynamic> f) {
    limparFormulario(manterVisibilidade: true);
    
    funcionarioEditando = f;
    nomeCtrl.text = f['nome'] ?? "";
    emailCtrl.text = f['email'] ?? "";
    cpfCtrl.text = f['cpf'] ?? "";
    senhaCtrl.text = ""; // Senha nunca deve ser preenchida
    cargo = f['cargo'] ?? "";
    departamento = f['departamento'] ?? "";

    setState(() => mostrarForm = true);
  }

  Future<void> salvarFuncionario() async {
    setState(() {
      loading = true;
      mensagemAlerta = "";
      isError = false;
    });
    
    // Apenas envia a senha se estiver no modo de criação OU se o campo não estiver vazio na edição.
    String? senhaParaEnviar = senhaCtrl.text.isNotEmpty ? senhaCtrl.text : null;
    if (funcionarioEditando != null && senhaCtrl.text.isEmpty) {
        senhaParaEnviar = null; // Não envia a senha se for edição e o campo estiver vazio
    }
    
    // Validação básica de campos obrigatórios no cadastro
    if (funcionarioEditando == null) {
        if (nomeCtrl.text.isEmpty || emailCtrl.text.isEmpty || cpfCtrl.text.isEmpty || senhaParaEnviar == null || cargo.isEmpty || departamento.isEmpty) {
            setState(() {
                mensagemAlerta = "Todos os campos são obrigatórios para o cadastro.";
                isError = true;
                loading = false;
            });
            return;
        }
    }


    final body = {
      "nome": nomeCtrl.text,
      "email": emailCtrl.text,
      "cpf": cpfCtrl.text,
      "senha": senhaParaEnviar,
      "cargo": cargo.isEmpty ? null : cargo,
      "departamento": departamento.isEmpty ? null : departamento,
    };
    
    // Remove chaves nulas do body (especialmente a senha)
    body.removeWhere((key, value) => value == null);

    try {
      if (funcionarioEditando != null) {
        final id = funcionarioEditando!["id"]; 
        if (id == null) throw Exception("ID do funcionário não encontrado para edição.");
        
        await FuncionarioService.editarFuncionario(
          id.toString(),
          body,
        );
        setState(() {
          mensagemAlerta = "Funcionário atualizado com sucesso!";
          isError = false;
        });
      } else {
        await FuncionarioService.criarFuncionario(body);
        setState(() {
          mensagemAlerta = "Funcionário cadastrado com sucesso!";
          isError = false;
        });
      }

      await carregarFuncionarios();
      limparFormulario();
      setState(() => mostrarForm = false);

    } catch (e) {
      await _processarErros(e);
    } finally {
      setState(() => loading = false);
    }
  }

  Future<void> deletarFuncionario(int id) async {
    setState(() {
      mensagemAlerta = "";
      isError = false;
    });
    try {
      await FuncionarioService.deletarFuncionario(id.toString());
      await carregarFuncionarios();
      setState(() {
        mensagemAlerta = "Funcionário deletado com sucesso!";
        isError = false;
      });
    } catch (e) {
      await _processarErros(e);
    }
  }

  // --- WIDGETS DE ESTILO ---

  // Função para padronizar o estilo do Input (replicado da UsuarioScreen)
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

  // Formulário de Cadastro/Edição (Replicado e Adaptado para Funcionário)
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
            decoration: inputStyle(funcionarioEditando != null ? "Nova Senha (Opcional)" : "Senha"),
            obscureText: true,
          ),
          const SizedBox(height: 10),
          
          // Campos Adicionais de Funcionário
          DropdownButtonFormField<String>(
            value: cargo.isEmpty ? null : cargo,
            decoration: inputStyle("Cargo"),
            items: cargos.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
            onChanged: (v) => setState(() => cargo = v.toString()),
          ),
          const SizedBox(height: 10),

          DropdownButtonFormField<String>(
            value: departamento.isEmpty ? null : departamento,
            decoration: inputStyle("Departamento"),
            items: departamentos.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
            onChanged: (v) => setState(() => departamento = v.toString()),
          ),
          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: loading ? null : salvarFuncionario,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                backgroundColor: funcionarioEditando != null ? const Color(0xFF2563EB) : Colors.green,
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
                      funcionarioEditando != null ? "Atualizar" : "Cadastrar",
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16),
                    ),
            ),
          )
        ],
      ),
    );
  }

  // Card de Listagem (Replicado e Adaptado para Funcionário)
  Widget buildCard(dynamic funcionario) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        title: Text(
          funcionario["nome"] ?? "N/A",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Email: ${funcionario["email"] ?? 'N/A'}"),
            Text("CPF: ${funcionario["cpf"] ?? 'N/A'}"),
            Text("Cargo: ${funcionario["cargo"] ?? 'N/A'}"),
            Text("Departamento: ${funcionario["departamento"] ?? 'N/A'}"),
          ],
        ),
        isThreeLine: true,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Color(0xFF2563EB)),
              onPressed: () => preencherForm(funcionario),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              // O ID do funcionário deve ser convertido para int, se for o caso
              onPressed: () => deletarFuncionario(funcionario["id"] as int), 
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
            // Header + botão expandir (Replicado da UsuarioScreen)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  funcionarioEditando != null ? "Editar Funcionário" : "Cadastrar Funcionário",
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
                    mostrarForm ? "Fechar" : "Novo Funcionário",
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
                "Funcionários Cadastrados",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 14),

            if (loading)
                const Center(child: CircularProgressIndicator()),
            
            if (!loading && funcionarios.isEmpty)
              const Text("Nenhum funcionário cadastrado", style: TextStyle(color: Colors.grey)),

            if (!loading)
              ...funcionarios.map(buildCard).toList(),
          ],
        ),
      ),
    );
  }
}
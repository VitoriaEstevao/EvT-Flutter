import 'package:flutter/material.dart';
import '../services/funcionario_service.dart';


class FuncionariosPage extends StatefulWidget {
  const FuncionariosPage({Key? key}) : super(key: key);

  @override
  _FuncionariosPageState createState() => _FuncionariosPageState();
}

class _FuncionariosPageState extends State<FuncionariosPage> {
  List<dynamic> funcionarios = [];
  Map<String, dynamic>? funcionarioEditando;

  final TextEditingController nomeCtrl = TextEditingController();
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController cpfCtrl = TextEditingController();
  final TextEditingController senhaCtrl = TextEditingController();

  String cargo = "";
  String departamento = "";

  String mensagemErro = "";
  Map<String, dynamic> erros = {};
  bool mostrarForm = false;

  final cargos = [
    'GERENTE',
    'ANALISTA',
    'ESTAGIARIO',
    'COORDENADOR',
    'APRENDIZ',
    'VISITANTE'
  ];

  final departamentos = [
    'FINANCEIRO',
    'TI',
    'RH',
    'JURIDICO',
    'MARKETING'
  ];

  @override
  void initState() {
    super.initState();
    carregarFuncionarios();
  }

  Future<void> carregarFuncionarios() async {
    try {
      final data = await FuncionarioService.getFuncionarios();
      setState(() => funcionarios = data);
    } catch (e) {
      setState(() => mensagemErro = "Erro ao carregar funcionários");
    }
  }

  void preencherForm(Map<String, dynamic> f) {
    funcionarioEditando = f;
    nomeCtrl.text = f['nome'] ?? "";
    emailCtrl.text = f['email'] ?? "";
    cpfCtrl.text = f['cpf'] ?? "";
    senhaCtrl.text = "";
    cargo = f['cargo'] ?? "";
    departamento = f['departamento'] ?? "";
    setState(() => mostrarForm = true);
  }

  Future<void> salvarFuncionario() async {
    setState(() {
      mensagemErro = "";
      erros = {};
    });

    final body = {
      "nome": nomeCtrl.text,
      "email": emailCtrl.text,
      "cpf": cpfCtrl.text,
      "senha": senhaCtrl.text,
      "cargo": cargo,
      "departamento": departamento,
    };

    try {
      if (funcionarioEditando != null) {
        await FuncionarioService.editarFuncionario(
          funcionarioEditando!["id"].toString(),
          body,
        );
      } else {
        await FuncionarioService.criarFuncionario(body);
      }

      await carregarFuncionarios();

      setState(() {
        funcionarioEditando = null;
        nomeCtrl.clear();
        emailCtrl.clear();
        cpfCtrl.clear();
        senhaCtrl.clear();
        cargo = "";
        departamento = "";
        mostrarForm = false;
      });
    } catch (e) {
      setState(() => mensagemErro = "Erro ao salvar funcionário");
    }
  }

  Future<void> deletarFuncionario(String id) async {
    try {
      await FuncionarioService.deletarFuncionario(id);
      await carregarFuncionarios();
    } catch (e) {
      setState(() => mensagemErro = "Erro ao deletar funcionário");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Funcionários")),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Título + botão de expandir
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  funcionarioEditando != null
                      ? "Atualizar Funcionário"
                      : "Cadastro de Funcionário",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                ElevatedButton(
                  onPressed: () =>
                      setState(() => mostrarForm = !mostrarForm),
                  child: Text(
                      mostrarForm ? "Fechar Formulário" : "Expandir Formulário"),
                )
              ],
            ),

            if (mostrarForm) ...[
              if (mensagemErro.isNotEmpty)
                Text(
                  mensagemErro,
                  style: TextStyle(color: Colors.red),
                ),

              SizedBox(height: 12),

              TextField(controller: nomeCtrl, decoration: InputDecoration(labelText: "Nome")),
              TextField(controller: emailCtrl, decoration: InputDecoration(labelText: "Email")),
              TextField(controller: cpfCtrl, decoration: InputDecoration(labelText: "CPF")),
              TextField(controller: senhaCtrl, obscureText: true, decoration: InputDecoration(labelText: "Senha")),

              DropdownButtonFormField(
                value: cargo.isEmpty ? null : cargo,
                items: cargos.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                decoration: InputDecoration(labelText: "Cargo"),
                onChanged: (v) => setState(() => cargo = v.toString()),
              ),

              DropdownButtonFormField(
                value: departamento.isEmpty ? null : departamento,
                items: departamentos.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                decoration: InputDecoration(labelText: "Departamento"),
                onChanged: (v) => setState(() => departamento = v.toString()),
              ),

              SizedBox(height: 16),

              ElevatedButton(
                onPressed: salvarFuncionario,
                child: Text(funcionarioEditando != null ? "Atualizar" : "Cadastrar"),
              ),
            ],

            SizedBox(height: 30),

            Text("Funcionários cadastrados", style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),

            if (funcionarios.isEmpty)
              Text("Nenhum funcionário cadastrado"),

            ...funcionarios.map((f) {
              return Card(
                child: ListTile(
                  title: Text(f["nome"] ?? ""),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Email: ${f['email']}"),
                      Text("CPF: ${f['cpf']}"),
                      Text("Cargo: ${f['cargo']}"),
                      Text("Departamento: ${f['departamento']}"),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(icon: Icon(Icons.edit), onPressed: () => preencherForm(f)),
                      IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () => deletarFuncionario(f["id"].toString())),
                    ],
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}

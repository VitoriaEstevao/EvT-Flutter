import 'package:flutter/material.dart';
import '../services/funcionario_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_header.dart';

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
      appBar:  AppHeader(),

      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [

            /// CARD DO FORMULÁRIO
            Container(
              padding: EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: AppTheme.card,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  )
                ],
              ),

              child: Column(
                children: [

                  /// CABEÇALHO
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        funcionarioEditando != null
                            ? "Atualizar Funcionário"
                            : "Cadastro de Funcionário",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                      ),
                      TextButton(
                        onPressed: () => setState(() => mostrarForm = !mostrarForm),
                        child: Text(
                          mostrarForm ? "Fechar" : "Expandir",
                          style: TextStyle(color: AppTheme.primary),
                        ),
                      )
                    ],
                  ),

                  if (mostrarForm) ...[
                    SizedBox(height: 14),

                    TextField(controller: nomeCtrl, decoration: InputDecoration(labelText: "Nome")),
                    SizedBox(height: 10),

                    TextField(controller: emailCtrl, decoration: InputDecoration(labelText: "Email")),
                    SizedBox(height: 10),

                    TextField(controller: cpfCtrl, decoration: InputDecoration(labelText: "CPF")),
                    SizedBox(height: 10),

                    TextField(
                      controller: senhaCtrl,
                      decoration: InputDecoration(labelText: "Senha"),
                      obscureText: true,
                    ),
                    SizedBox(height: 10),

                    DropdownButtonFormField(
                      value: cargo.isEmpty ? null : cargo,
                      decoration: InputDecoration(labelText: "Cargo"),
                      items: cargos.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                      onChanged: (v) => setState(() => cargo = v.toString()),
                    ),

                    SizedBox(height: 10),

                    DropdownButtonFormField(
                      value: departamento.isEmpty ? null : departamento,
                      decoration: InputDecoration(labelText: "Departamento"),
                      items: departamentos.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                      onChanged: (v) => setState(() => departamento = v.toString()),
                    ),

                    SizedBox(height: 20),

                    ElevatedButton(
                      onPressed: salvarFuncionario,
                      child: Text(funcionarioEditando != null ? "Atualizar" : "Cadastrar"),
                    )
                  ]
                ],
              ),
            ),

            SizedBox(height: 30),

            /// LISTA DE FUNCIONÁRIOS
            Text("Funcionários cadastrados",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),

            SizedBox(height: 14),

            if (funcionarios.isEmpty)
              Text("Nenhum funcionário cadastrado"),

            Column(
              children: funcionarios.map((f) {
                return Container(
                  margin: EdgeInsets.only(bottom: 12),
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.background,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.border),
                    boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(f["nome"] ?? "",
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            SizedBox(height: 4),
                            Text("Email: ${f['email']}"),
                            Text("CPF: ${f['cpf']}"),
                            Text("Cargo: ${f['cargo']}"),
                            Text("Departamento: ${f['departamento']}"),
                          ],
                        ),
                      ),

                      Column(
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit, color: AppTheme.primary),
                            onPressed: () => preencherForm(f),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: AppTheme.danger),
                            onPressed: () => deletarFuncionario(f["id"].toString()),
                          ),
                        ],
                      )
                    ],
                  ),
                );
              }).toList(),
            )
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../services/local_service.dart';
import '../widgets/app_header.dart';

class LocalScreen extends StatefulWidget {
  const LocalScreen({Key? key}) : super(key: key);

  @override
  _LocalScreenState createState() => _LocalScreenState();
}

class _LocalScreenState extends State<LocalScreen> {
  List<dynamic> locais = [];
  Map<String, dynamic>? localEditando;

  bool mostrarForm = false;
  String mensagemErro = "";

  final nomeCtrl = TextEditingController();
  final ruaCtrl = TextEditingController();
  final bairroCtrl = TextEditingController();
  final cidadeCtrl = TextEditingController();
  final estadoCtrl = TextEditingController();
  final numeroCtrl = TextEditingController();
  final cepCtrl = TextEditingController();
  final capacidadeCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    carregarLocais();
  }

  Future<void> carregarLocais() async {
    try {
      final data = await LocalService.getLocais();
      setState(() => locais = data);
    } catch (e) {
      setState(() => mensagemErro = "Erro ao carregar locais");
    }
  }

  void preencherForm(Map<String, dynamic> local) {
    localEditando = local;

    nomeCtrl.text = local["nome"] ?? "";
    capacidadeCtrl.text = local["capacidade"]?.toString() ?? "";

    final end = local["endereco"] ?? {};
    ruaCtrl.text = end["rua"] ?? "";
    bairroCtrl.text = end["bairro"] ?? "";
    cidadeCtrl.text = end["cidade"] ?? "";
    estadoCtrl.text = end["estado"] ?? "";
    numeroCtrl.text = end["numero"]?.toString() ?? "";
    cepCtrl.text = end["cep"] ?? "";

    setState(() => mostrarForm = true);
  }

  Future<void> salvar() async {
    setState(() => mensagemErro = "");

    final body = {
      "nome": nomeCtrl.text,
      "capacidade": capacidadeCtrl.text,
      "endereco": {
        "rua": ruaCtrl.text,
        "bairro": bairroCtrl.text,
        "cidade": cidadeCtrl.text,
        "estado": estadoCtrl.text,
        "numero": int.tryParse(numeroCtrl.text) ?? 0,
        "cep": cepCtrl.text,
      }
    };

    try {
      if (localEditando != null) {
        await LocalService.atualizarLocal(
          localEditando!["id"].toString(),
          body,
        );
      } else {
        await LocalService.criarLocal(body);
      }

      await carregarLocais();

      limparFormulario();
      setState(() => mostrarForm = false);
    } catch (e) {
      setState(() => mensagemErro = "Erro ao salvar local");
    }
  }

  Future<void> deletar(String id) async {
    try {
      await LocalService.deletarLocal(id);
      await carregarLocais();
    } catch (e) {
      setState(() => mensagemErro = "Erro ao deletar local");
    }
  }

  void limparFormulario() {
    localEditando = null;
    nomeCtrl.clear();
    ruaCtrl.clear();
    bairroCtrl.clear();
    cidadeCtrl.clear();
    estadoCtrl.clear();
    numeroCtrl.clear();
    cepCtrl.clear();
    capacidadeCtrl.clear();
  }

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
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
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
          if (mensagemErro.isNotEmpty)
            Text(mensagemErro, style: const TextStyle(color: Colors.red)),

          const SizedBox(height: 12),

          TextField(controller: nomeCtrl, decoration: inputStyle("Nome")),

          const SizedBox(height: 16),

          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Endereço",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),

          const SizedBox(height: 10),

          TextField(controller: ruaCtrl, decoration: inputStyle("Rua")),
          const SizedBox(height: 10),
          TextField(controller: bairroCtrl, decoration: inputStyle("Bairro")),
          const SizedBox(height: 10),
          TextField(controller: cidadeCtrl, decoration: inputStyle("Cidade")),
          const SizedBox(height: 10),
          TextField(controller: estadoCtrl, decoration: inputStyle("Estado")),
          const SizedBox(height: 10),
          TextField(controller: numeroCtrl, decoration: inputStyle("Número")),
          const SizedBox(height: 10),
          TextField(controller: cepCtrl, decoration: inputStyle("CEP")),

          const SizedBox(height: 16),

          TextField(
            controller: capacidadeCtrl,
            decoration: inputStyle("Capacidade"),
          ),

          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: salvar,
              child: Text(
                localEditando != null ? "Atualizar" : "Cadastrar",
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget buildCard(dynamic local) {
    final end = local["endereco"] ?? {};

    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        title: Text(
          local["nome"],
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text("${end["cidade"]}, ${end["estado"]}"),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () => preencherForm(local),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => deletar(local["id"].toString()),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar:  AppHeader(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            /// Header + botão expandir
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  localEditando != null
                      ? "Editar Local"
                      : "Cadastrar Local",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () =>
                      setState(() => mostrarForm = !mostrarForm),
                  child: Text(
                    mostrarForm
                        ? "Fechar Formulário"
                        : "Expandir Formulário",
                  ),
                )
              ],
            ),

            const SizedBox(height: 20),

            if (mostrarForm) buildForm(),

            const SizedBox(height: 30),

            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Locais cadastrados",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 14),

            if (locais.isEmpty)
              const Text("Nenhum local cadastrado"),

            ...locais.map(buildCard).toList(),
          ],
        ),
      ),
    );
  }
}

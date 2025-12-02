import 'package:flutter/material.dart';
import 'package:evt_flutter/widgets/app_layout.dart';
import 'dart:convert'; // 🎯 Adicionar para jsonDecode, utf8 e base64
import 'package:shared_preferences/shared_preferences.dart'; // 🎯 Adicionar para SharedPreferences
import '../services/local_service.dart';
import '../widgets/app_header.dart'; // Mantido o widget AppHeader

class LocalScreen extends StatefulWidget {
  const LocalScreen({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _LocalScreenState createState() => _LocalScreenState();
}

class _LocalScreenState extends State<LocalScreen> {
  List<dynamic> locais = [];
  Map<String, dynamic>? localEditando;
  String? userRole;
  bool mostrarForm = false;
  String mensagemAlerta = ""; // Unificado para sucesso e erro
  bool isError = false; // Flag para diferenciar erro de sucesso

  final nomeCtrl = TextEditingController();
  final ruaCtrl = TextEditingController();
  final bairroCtrl = TextEditingController();
  final cidadeCtrl = TextEditingController();
  final estadoCtrl = TextEditingController();
  final numeroCtrl = TextEditingController();
  final cepCtrl = TextEditingController();
  final capacidadeCtrl = TextEditingController();
  
  // Flag para desabilitar o botão enquanto busca CEP
  bool buscandoCep = false; 

  @override
  void initState() {
    super.initState();
    carregarTokenRole();
    carregarLocais();
  }

  @override
  void dispose() {
    nomeCtrl.dispose();
    ruaCtrl.dispose();
    bairroCtrl.dispose();
    cidadeCtrl.dispose();
    estadoCtrl.dispose();
    numeroCtrl.dispose();
    cepCtrl.dispose();
    capacidadeCtrl.dispose();
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

  Future<void> carregarLocais() async {
    setState(() {
      mensagemAlerta = "";
      isError = false;
    });
    try {
      final data = await LocalService.getLocais();
      setState(() => locais = data);
    } catch (e) {
      setState(() {
        mensagemAlerta = e.toString().replaceFirst('Exception: ', '');
        isError = true;
      });
    }
  }

  void preencherForm(Map<String, dynamic> local) {
    limparFormulario(manterVisibilidade: true); // Limpa mas mantém o form aberto
    
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
    setState(() {
      mensagemAlerta = "";
      isError = false;
    });

    // Converte capacidade e número para o tipo correto esperado pelo Spring
    final capacidade = int.tryParse(capacidadeCtrl.text);
    final numero = int.tryParse(numeroCtrl.text);

    if (capacidade == null || numero == null) {
      setState(() {
        mensagemAlerta = "Capacidade e Número devem ser números inteiros válidos.";
        isError = true;
      });
      return;
    }

    final body = {
      "nome": nomeCtrl.text,
      "capacidade": capacidade,
      "endereco": {
        "rua": ruaCtrl.text,
        "bairro": bairroCtrl.text,
        "cidade": cidadeCtrl.text,
        "estado": estadoCtrl.text,
        "numero": numero,
        "cep": cepCtrl.text,
      }
    };

    try {
      if (localEditando != null) {
        await LocalService.atualizarLocal(
          localEditando!["id"].toString(),
          body,
        );
        setState(() {
          mensagemAlerta = "Local atualizado com sucesso!";
          isError = false;
        });
      } else {
        await LocalService.criarLocal(body);
        setState(() {
          mensagemAlerta = "Local cadastrado com sucesso!";
          isError = false;
        });
      }

      await carregarLocais();

      limparFormulario();
      setState(() => mostrarForm = false);
    } catch (e) {
      setState(() {
        // Remove 'Exception: ' da mensagem de erro
        mensagemAlerta = e.toString().replaceFirst('Exception: ', ''); 
        isError = true;
      });
    }
  }

  Future<void> deletar(String id) async {
    setState(() {
      mensagemAlerta = "";
      isError = false;
    });
    try {
      await LocalService.deletarLocal(id);
      await carregarLocais();
      setState(() {
        mensagemAlerta = "Local deletado com sucesso!";
        isError = false;
      });
    } catch (e) {
      setState(() {
        mensagemAlerta = e.toString().replaceFirst('Exception: ', '');
        isError = true;
      });
    }
  }

  Future<void> buscarCep() async {
    if (cepCtrl.text.isEmpty) {
      setState(() {
        mensagemAlerta = "O campo CEP não pode estar vazio.";
        isError = true;
      });
      return;
    }

    setState(() {
      buscandoCep = true;
      mensagemAlerta = "";
      isError = false;
    });

    try {
      final data = await LocalService.buscarCepViaCep(cepCtrl.text);

      setState(() {
        // Preenche os campos do formulário
        ruaCtrl.text = data["logradouro"] ?? "";
        bairroCtrl.text = data["bairro"] ?? "";
        cidadeCtrl.text = data["localidade"] ?? "";
        estadoCtrl.text = data["uf"] ?? "";
        // Manter número e cep sem alteração (apenas se encontrado)
        
        mensagemAlerta = "Endereço preenchido via CEP!";
        isError = false;
      });
    } catch (e) {
      setState(() {
        mensagemAlerta = e.toString().replaceFirst('Exception: ', '');
        isError = true;
      });
    } finally {
      setState(() => buscandoCep = false);
    }
  }

  void limparFormulario({bool manterVisibilidade = false}) {
    localEditando = null;
    nomeCtrl.clear();
    ruaCtrl.clear();
    bairroCtrl.clear();
    cidadeCtrl.clear();
    estadoCtrl.clear();
    numeroCtrl.clear();
    cepCtrl.clear();
    capacidadeCtrl.clear();
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

  // Novo widget para o campo CEP com botão de busca
  Widget buildCepField() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: cepCtrl,
            decoration: inputStyle("CEP"),
            keyboardType: TextInputType.number,
          ),
        ),
        const SizedBox(width: 10),
        ElevatedButton(
          onPressed: buscandoCep ? null : buscarCep,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF10B981), // Cor do botão de buscar CEP
            padding: const EdgeInsets.symmetric(vertical: 18), // Ajuste de padding para alinhar
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: buscandoCep
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Text(
                  "Buscar CEP",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                ),
        ),
      ],
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
          const SizedBox(height: 16),

          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Endereço",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF2563EB)),
            ),
          ),
          const SizedBox(height: 10),

          buildCepField(),
          const SizedBox(height: 10),

          TextField(controller: numeroCtrl, decoration: inputStyle("Número")),
          const SizedBox(height: 10),
          
          // Campos desabilitados, preenchidos pelo CEP
          TextField(controller: ruaCtrl, decoration: inputStyle("Rua"), readOnly: true, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 10),
          TextField(controller: bairroCtrl, decoration: inputStyle("Bairro"), readOnly: true, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 10),
          TextField(controller: cidadeCtrl, decoration: inputStyle("Cidade"), readOnly: true, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 10),
          TextField(controller: estadoCtrl, decoration: inputStyle("Estado"), readOnly: true, style: const TextStyle(color: Colors.grey)),

          const SizedBox(height: 16),

          TextField(
            controller: capacidadeCtrl,
            decoration: inputStyle("Capacidade"),
            keyboardType: TextInputType.number,
          ),

          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                backgroundColor: localEditando != null ? const Color(0xFF2563EB) : Colors.green, // Azul para editar
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: salvar,
              child: Text(
                localEditando != null ? "Atualizar Local" : "Cadastrar Local",
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16),
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
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Capacidade: ${local["capacidade"]}"),
            Text("${end["rua"]}, ${end["numero"]} - ${end["bairro"]} | ${end["cidade"]}, ${end["estado"]}"),
          ],
        ),
        isThreeLine: true,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Color(0xFF2563EB)),
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
                  localEditando != null ? "Editar Local" : "Cadastrar Local",
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
                    // Limpa o formulário ao fechar ou se for abrir para novo cadastro
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
                    mostrarForm ? "Fechar" : "Novo Local",
                    style: const TextStyle(color: Colors.white),
                  ),
                )
              ],
            ),

            const SizedBox(height: 20),

            // O formulário é exibido se mostrarForm for true
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
                "Locais cadastrados",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 14),

            if (locais.isEmpty)
              const Text("Nenhum local cadastrado", style: TextStyle(color: Colors.grey)),

            ...locais.map(buildCard).toList(),
          ],
        ),
      ),
    );
  }
}
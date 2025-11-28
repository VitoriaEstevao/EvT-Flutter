import 'package:flutter/material.dart';
import '../services/evento_service.dart';
import '../services/local_service.dart';
import '../services/usuarios_service.dart';
import '../widgets/app_header.dart';


class EventoScreen extends StatefulWidget {
  const EventoScreen({super.key});

  @override
  State<EventoScreen> createState() => _EventoScreenState();
}

class _EventoScreenState extends State<EventoScreen> {
  List<dynamic> eventos = [];
  List<dynamic> locais = [];
  List<dynamic> palestrantes = [];

  bool mostrarForm = false;
  Map<String, dynamic>? eventoEditando;

  final tituloCtrl = TextEditingController();
  final descricaoCtrl = TextEditingController();
  final vagasCtrl = TextEditingController();

  DateTime? dataEvento;
  String tipoEvento = "REMOTO";
  int? localId;
  int? palestranteId;

  String mensagemErro = "";

  @override
  void initState() {
    super.initState();
    carregarDados();
  }

  Future<void> carregarDados() async {
    try {
      final e = await EventoService.getEventos();
      final l = await LocalService.getLocais();
      final p = await UsuariosService.getUsuarios();

      setState(() {
        eventos = e;
        locais = l;
        palestrantes = p;
      });
    } catch (e) {
      setState(() => mensagemErro = "Erro ao carregar dados");
    }
  }

  void preencherForm(dynamic ev) {
    eventoEditando = ev;

    tituloCtrl.text = ev["titulo"] ?? "";
    descricaoCtrl.text = ev["descricao"] ?? "";
    vagasCtrl.text = ev["vagas"]?.toString() ?? "";
    tipoEvento = ev["tipoEvento"] ?? "REMOTO";
    localId = ev["localId"];
    palestranteId = ev["palestranteId"];

    dataEvento = DateTime.tryParse(ev["data"]);
    setState(() => mostrarForm = true);
  }

  void limparForm() {
    eventoEditando = null;
    tituloCtrl.clear();
    descricaoCtrl.clear();
    vagasCtrl.clear();
    tipoEvento = "REMOTO";
    localId = null;
    palestranteId = null;
    dataEvento = null;
    mensagemErro = "";
  }

  Future<void> salvar() async {
    if (tituloCtrl.text.isEmpty) {
      setState(() => mensagemErro = "O título é obrigatório");
      return;
    }
    if (dataEvento == null) {
      setState(() => mensagemErro = "Selecione uma data");
      return;
    }
    if (palestranteId == null) {
      setState(() => mensagemErro = "Selecione um palestrante");
      return;
    }
    if (tipoEvento != "REMOTO" && localId == null) {
      setState(() => mensagemErro = "Selecione o local do evento");
      return;
    }

    final body = {
      "titulo": tituloCtrl.text,
      "descricao": descricaoCtrl.text,
      "data": dataEvento!.toIso8601String(),
      "tipoEvento": tipoEvento,
      "estadoEvento": "ABERTO",
      "vagas": int.tryParse(vagasCtrl.text) ?? 0,
      "localId": tipoEvento == "REMOTO" ? null : localId,
      "palestranteId": palestranteId,
    };

    try {
      if (eventoEditando != null) {
        await EventoService.editarEvento(eventoEditando!["id"], body);
      } else {
        await EventoService.criarEvento(body);
      }

      await carregarDados();
      limparForm();
      setState(() => mostrarForm = false);
    } catch (e) {
      setState(() => mensagemErro = "Erro ao salvar evento");
    }
  }

  Future<void> deletar(int id) async {
    try {
      await EventoService.deletarEvento(id);
      await carregarDados();
    } catch (e) {
      setState(() => mensagemErro = "Erro ao deletar evento");
    }
  }

  Future<void> selecionarData() async {
    final date = await showDatePicker(
      context: context,
      initialDate: dataEvento ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(DateTime.now()),
      );

      if (time != null) {
        setState(() {
          dataEvento = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  // ------------------------------
  //         ESTILOS (TEMP)
  // ------------------------------

  BoxDecoration get cardDecoration => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: const Color(0xFFE0E0E0)),
    boxShadow: const [
      BoxShadow(
        color: Color.fromRGBO(123, 97, 255, 0.12),
        blurRadius: 12,
        offset: Offset(0, 6),
      ),
    ],
  );

  InputDecoration get inputStyle => InputDecoration(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Color(0xFF9B5DE5), width: 2),
    ),
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
  );

  // ------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      appBar: AppHeader(),


      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  eventoEditando != null
                      ? "Atualizar Evento"
                      : "Cadastro de Evento",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2A2A2A),
                  ),
                ),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF06D6A0),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    setState(() => mostrarForm = !mostrarForm);
                    if (!mostrarForm) limparForm();
                  },
                  child: Text(
                    mostrarForm ? "Fechar Formulário" : "Expandir Formulário",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // FORM CARD
            if (mostrarForm)
              Container(
                padding: const EdgeInsets.all(18),
                decoration: cardDecoration,
                child: Column(
                  children: [
                    if (mensagemErro.isNotEmpty)
                      Text(
                        mensagemErro,
                        style: const TextStyle(color: Colors.red),
                      ),

                    const SizedBox(height: 10),

                    TextField(
                      controller: tituloCtrl,
                      decoration: inputStyle.copyWith(labelText: "Título"),
                    ),
                    const SizedBox(height: 12),

                    TextField(
                      controller: descricaoCtrl,
                      decoration: inputStyle.copyWith(labelText: "Descrição"),
                    ),
                    const SizedBox(height: 12),

                    TextField(
                      readOnly: true,
                      decoration: inputStyle.copyWith(
                        labelText: "Data do Evento",
                        hintText: dataEvento == null
                            ? "Selecionar Data"
                            : dataEvento.toString(),
                      ),
                      onTap: selecionarData,
                    ),
                    const SizedBox(height: 12),

                    DropdownButtonFormField<String>(
                      value: tipoEvento,
                      decoration: inputStyle.copyWith(labelText: "Tipo de Evento"),
                      items: const [
                        DropdownMenuItem(
                            value: "REMOTO", child: Text("Remoto")),
                        DropdownMenuItem(
                            value: "PRESENCIAL", child: Text("Presencial")),
                        DropdownMenuItem(
                            value: "HIBRIDO", child: Text("Híbrido")),
                      ],
                      onChanged: (v) => setState(() => tipoEvento = v ?? "REMOTO"),
                    ),
                    const SizedBox(height: 12),

                    TextField(
                      controller: vagasCtrl,
                      decoration: inputStyle.copyWith(labelText: "Vagas"),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),

                    if (tipoEvento != "REMOTO")
                      DropdownButtonFormField<int>(
                        value: localId,
                        decoration: inputStyle.copyWith(labelText: "Local"),
                        items: locais
                            .map<DropdownMenuItem<int>>(
                              (l) => DropdownMenuItem(
                                value: l["id"],
                                child: Text("${l["nome"]} - ${l["endereco"]["cidade"]}"),
                              ),
                            )
                            .toList(),
                        onChanged: (v) => setState(() => localId = v),
                      ),

                    const SizedBox(height: 12),

                    DropdownButtonFormField<int>(
                      value: palestranteId,
                      decoration: inputStyle.copyWith(labelText: "Palestrante"),
                      items: palestrantes
                          .map<DropdownMenuItem<int>>(
                            (p) => DropdownMenuItem(
                              value: p["id"],
                              child: Text("${p["nome"]} - ${p["email"]}"),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => palestranteId = v),
                    ),

                    const SizedBox(height: 18),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF06D6A0),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: salvar,
                        child: Text(
                          eventoEditando != null ? "Atualizar" : "Cadastrar",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),

            const SizedBox(height: 30),

            const Text(
              "Eventos cadastrados",
              style:
                  TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            if (eventos.isEmpty)
              const Text("Nenhum evento cadastrado"),

            ...eventos.map((e) {
              return Container(
                padding: const EdgeInsets.all(18),
                margin: const EdgeInsets.symmetric(vertical: 6),
                decoration: cardDecoration,
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    e["titulo"],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Text(
                    "Data: ${DateTime.parse(e["data"])}\n"
                    "Tipo: ${e["tipoEvento"]}\n"
                    "Vagas: ${e["vagas"]}",
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => preencherForm(e),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => deletar(e["id"]),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

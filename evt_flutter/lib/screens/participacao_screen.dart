import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/evento_service.dart';
import '../services/local_service.dart';
import '../services/participacao_service.dart';
import '../widgets/app_header.dart';

class ParticipacaoPage extends StatefulWidget {
  const ParticipacaoPage({Key? key}) : super(key: key);

  @override
  _ParticipacaoPageState createState() => _ParticipacaoPageState();
}

class _ParticipacaoPageState extends State<ParticipacaoPage> {
  List eventos = [];
  dynamic eventoSelecionado;
  List participantes = [];
  List meusEventos = [];

  String mensagem = "";
  String mensagemTipo = "";
  String? userRole;

  dynamic localDetalhes;

  @override
  void initState() {
    super.initState();
    carregarTokenRole();
    carregarEventos();
    carregarMeusEventos();
  }

  // ----------------------------
  // CARREGAMENTOS
  // ----------------------------

  Future<void> carregarTokenRole() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    if (token != null) {
      final payload = jsonDecode(
        utf8.decode(base64.decode(token.split('.')[1])),
      );

      setState(() => userRole = payload["role"]);
    }
  }

  Future<void> carregarEventos() async {
    try {
      final data = await EventoService.getEventos();
      setState(() => eventos = data);
    } catch (e) {
      setState(() => mensagem = "Erro ao carregar eventos");
    }
  }

  Future<void> carregarMeusEventos() async {
    try {
      final data = await ParticipacaoService.getMeusEventos();
      setState(() => meusEventos = data);
    } catch (e) {}
  }

  Future<void> carregarParticipantes() async {
    if (eventoSelecionado == null || userRole == "VISITANTE") {
      setState(() => participantes = []);
      return;
    }

    try {
      final data = await ParticipacaoService.getUsuariosPorEvento(
        eventoSelecionado["id"].toString(),
      );

      setState(() => participantes = data);
    } catch (e) {}
  }

  Future<void> carregarLocal() async {
    if (eventoSelecionado == null || eventoSelecionado["localId"] == null) {
      localDetalhes = null;
      return;
    }

    setState(() =>
        localDetalhes = {"nome": "Carregando...", "endereco": {}});

    try {
      final local = await LocalService.getLocalById(eventoSelecionado["localId"]);

      setState(() => localDetalhes = local);
    } catch (e) {
      setState(() => localDetalhes = {
            "nome": "Erro ao carregar local",
            "endereco": {}
          });
    }
  }

  // ----------------------------
  // AÇÕES
  // ----------------------------

  Future<void> participar(String titulo) async {
    setState(() {
      mensagem = "";
      mensagemTipo = "";
    });

    try {
      await ParticipacaoService.participar(titulo);

      setState(() {
        mensagem = "Participação registrada!";
        mensagemTipo = "success";
      });

      await carregarParticipantes();
      await carregarMeusEventos();
    } catch (e) {
      setState(() {
        mensagem = "Erro ao participar.";
        mensagemTipo = "error";
      });
    }
  }

  // ----------------------------
  // FORMATADORES
  // ----------------------------

  String formatarData(String? data) {
    if (data == null) return "Sem data";
    final d = DateTime.parse(data);
    return "${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year} ${d.hour}:${d.minute.toString().padLeft(2, '0')}";
  }

  Widget formatarEndereco(dynamic local) {
    if (local == null || local["endereco"] == null) {
      return Text("Local não encontrado ou remoto");
    }

    final e = local["endereco"];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Nome: ${local["nome"]}"),
        Text("Endereço: ${e["rua"]}, ${e["numero"] ?? 'S/N'}"),
        Text("Bairro: ${e["bairro"]}"),
        Text("Cidade: ${e["cidade"]} - ${e["estado"]}"),
        Text("CEP: ${e["cep"]}"),
      ],
    );
  }

  // ----------------------------
  // UI
  // ----------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:  AppHeader(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Container(
          padding: EdgeInsets.all(20),
          constraints: BoxConstraints(maxWidth: 600),
          margin: EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),

          // COLUNA PRINCIPAL
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ----------------------------
              // TÍTULO
              // ----------------------------
              Center(
                child: Text(
                  "Participar de Eventos",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
              ),

              SizedBox(height: 20),

              // ----------------------------
              // DROPDOWN EVENTO
              // ----------------------------
              DropdownButtonFormField(
                decoration: InputDecoration(
                  labelText: "Selecione um evento",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                items: eventos
                    .map(
                      (ev) => DropdownMenuItem(
                        value: ev,
                        child: Text(
                          "${ev["titulo"]} — ${formatarData(ev["data"])}",
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() => eventoSelecionado = value);
                  carregarParticipantes();
                  carregarLocal();
                },
              ),

              // ----------------------------
              // MENSAGEM
              // ----------------------------
              if (mensagem.isNotEmpty) ...[
                SizedBox(height: 14),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: mensagemTipo == "error"
                        ? Colors.red[100]
                        : Colors.green[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    mensagem,
                    style: TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],

              // ----------------------------
              // BOTÃO
              // ----------------------------
              if (eventoSelecionado != null) ...[
                SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () =>
                        participar(eventoSelecionado["titulo"].toString()),
                    child: Text(
                      "Participar",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],

              // ----------------------------
              // DETALHES DO EVENTO
              // ----------------------------
              if (eventoSelecionado != null) ...[
                SizedBox(height: 30),
                Text(
                  "Detalhes do Evento",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 10),

                Text("Descrição: ${eventoSelecionado["descricao"]}"),
                Text("Data/Hora: ${formatarData(eventoSelecionado["data"])}"),
                Text("Tipo: ${eventoSelecionado["tipoEvento"]}"),
                Text("Estado: ${eventoSelecionado["estadoEvento"]}"),
                Text("Vagas: ${eventoSelecionado["vagas"]}"),

                if (eventoSelecionado["tipoEvento"] == "PRESENCIAL") ...[
                  SizedBox(height: 10),
                  formatarEndereco(localDetalhes),
                ],
              ],

              // ----------------------------
              // PARTICIPANTES
              // ----------------------------
              if (eventoSelecionado != null && userRole != "VISITANTE") ...[
                SizedBox(height: 30),
                Text(
                  "Participantes",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 10),

                if (participantes.isEmpty)
                  Text("Nenhum participante ainda."),

                ...participantes.map(
                  (p) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(p["nome"] ?? p["email"] ?? "Usuário"),
                  ),
                ),
              ],

              // ----------------------------
              // MEUS EVENTOS
              // ----------------------------
              SizedBox(height: 30),
              Text(
                "Meus Eventos",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),

              if (meusEventos.isEmpty)
                Text("Você não participa de nenhum evento."),

              ...meusEventos.map(
                (ev) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(ev["titulo"]),
                  subtitle: Text(formatarData(ev["data"])),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

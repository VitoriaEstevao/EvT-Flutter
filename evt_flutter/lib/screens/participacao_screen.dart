import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

//import '../services/evento_service.dart';
import '../services/participacao_service.dart';
//import '../services/local_service.dart';

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

  Future<void> carregarTokenRole() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    if (token != null) {
      final payload = jsonDecode(utf8.decode(base64.decode(token.split('.')[1])));
      setState(() => userRole = payload["role"]);
    }
  }

  Future<void> carregarEventos() async {
    try {
      //final data = await EventoService.getEventos();
      //setState(() => eventos = data);
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
      final data =
          await ParticipacaoService.getUsuariosPorEvento(eventoSelecionado["id"].toString());
      setState(() => participantes = data);
    } catch (e) {}
  }

  Future<void> carregarLocal() async {
    if (eventoSelecionado == null || eventoSelecionado["localId"] == null) {
      localDetalhes = null;
      return;
    }

    setState(() => localDetalhes = {"nome": "Carregando...", "endereco": {}});

    try {
      //final local = await LocalService.getLocal(eventoSelecionado["localId"]);
      //setState(() => localDetalhes = local);
    } catch (e) {
      setState(() => localDetalhes = {"nome": "Erro ao carregar Local", "endereco": {}});
    }
  }

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
        mensagem = "Erro ao participar do evento.";
        mensagemTipo = "error";
      });
    }
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Participação em Eventos")),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Participar de Eventos",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),

            DropdownButtonFormField(
              decoration: InputDecoration(labelText: "Selecione um evento"),
              items: eventos
                  .map((ev) => DropdownMenuItem(
                        value: ev,
                        child: Text("${ev["titulo"]} — ${formatarData(ev["data"])}"),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() => eventoSelecionado = value);
                carregarParticipantes();
                carregarLocal();
              },
            ),

            if (mensagem.isNotEmpty)
              Container(
                margin: EdgeInsets.symmetric(vertical: 12),
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: mensagemTipo == "error"
                      ? Colors.red[200]
                      : Colors.green[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(mensagem),
              ),

            if (eventoSelecionado != null)
              ElevatedButton(
                onPressed: () =>
                    participar(eventoSelecionado["titulo"].toString()),
                child: Text("Participar"),
              ),

            if (eventoSelecionado != null) ...[
              SizedBox(height: 20),
              Text("Detalhes: ${eventoSelecionado["titulo"]}",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

              Text("Descrição: ${eventoSelecionado["descricao"]}"),
              Text("Data/Hora: ${formatarData(eventoSelecionado["data"])}"),
              Text("Tipo: ${eventoSelecionado["tipoEvento"]}"),
              Text("Estado: ${eventoSelecionado["estadoEvento"]}"),
              Text("Vagas: ${eventoSelecionado["vagas"]}"),

              if (eventoSelecionado["tipoEvento"] == "PRESENCIAL")
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: formatarEndereco(localDetalhes),
                ),

              SizedBox(height: 20),
            ],

            /// Participantes
            if (eventoSelecionado != null && userRole != "VISITANTE") ...[
              Text("Participantes",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

              if (participantes.isEmpty)
                Text("Nenhum participante ainda."),

              ...participantes.map((p) => ListTile(
                    title: Text(p["nome"] ?? p["email"] ?? "Usuário"),
                  )),
            ],

            SizedBox(height: 30),

            Text("Meus Eventos",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

            if (meusEventos.isEmpty)
              Text("Você não participa de nenhum evento."),

            ...meusEventos.map((ev) => ListTile(
                  title: Text(ev["titulo"]),
                  subtitle: Text(formatarData(ev["data"])),
                )),
          ],
        ),
      ),
    );
  }
}

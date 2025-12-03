import 'dart:convert';
import 'package:evt_flutter/widgets/app_layout.dart';
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
  static const Color _primaryColor = Color(0xFF2563EB);
  static const Color _successColor = Color(0xFF10B981);
  static const Color _errorColor = Color(0xFFEF4444);

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

  // Lógica do Login/Permissão
  /// Decodifica o token JWT para obter a permissão (role) do usuário.
  Future<void> carregarTokenRole() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    if (token != null) {
      final parts = token.split('.');
      if (parts.length == 3) {
        final payload = jsonDecode(
          utf8.decode(base64.decode(base64.normalize(parts[1]))),
        );
        setState(() => userRole = payload["role"]);
      }
    }
  }

  /// Carrega a lista de todos os eventos disponíveis.
  Future<void> carregarEventos() async {
    try {
      final data = await EventoService.getEventos();
      setState(() => eventos = data);
    } catch (e) {
      setState(() => mensagem =
          "Erro ao carregar eventos: ${e.toString().replaceFirst('Exception: ', '')}");
    }
  }

  /// Carrega os eventos em que o usuário logado está participando.
  Future<void> carregarMeusEventos() async {
    try {
      final data = await ParticipacaoService.getMeusEventos();
      setState(() => meusEventos = data);
    } catch (e) {
      // Erro silencioso (esperado se não houver eventos ou não estiver logado)
    }
  }

  /// Carrega a lista de participantes do evento selecionado.
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
    } catch (e) {
      // Erro silencioso
    }
  }

  /// Carrega os detalhes do local do evento selecionado.
  Future<void> carregarLocal() async {
    if (eventoSelecionado == null || eventoSelecionado["localId"] == null) {
      setState(() => localDetalhes = null);
      return;
    }

    setState(() =>
        localDetalhes = {"nome": "Carregando...", "endereco": {}});

    try {
      final local = await LocalService.getLocalById(eventoSelecionado["localId"] as int);
      setState(() => localDetalhes = local);
    } catch (e) {
      setState(() => localDetalhes = {
            "nome": "Erro ao carregar local: ${e.toString().replaceFirst('Exception: ', '')}",
            "endereco": {}
          });
    }
  }

  /// Registra a participação do usuário no evento selecionado.
  Future<void> participar(String titulo) async {
    setState(() {
      mensagem = "";
      mensagemTipo = "";
    });

    try {
      await ParticipacaoService.participar(titulo);

      setState(() {
        mensagem = "Participação registrada com sucesso!";
        mensagemTipo = "success";
      });

      // Atualiza listas após a ação.
      await carregarParticipantes();
      await carregarMeusEventos();
    } catch (e) {
      setState(() {
        mensagem =
            e.toString().replaceFirst('Exception: ', 'Erro ao participar: ');
        mensagemTipo = "error";
      });
    }
  }

  String formatarData(String? data) {
    if (data == null) return "Sem data";
    final d = DateTime.parse(data);
    return "${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}";
  }

  Widget formatarEndereco(dynamic local) {
    if (local == null || local["endereco"] == null) {
      return Text(local?["nome"] ?? "Local não encontrado ou remoto",
          style: TextStyle(color: Colors.black87));
    }

    final e = local["endereco"];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Nome: ${local["nome"]}", style: TextStyle(color: Colors.black87)),
        Text("Endereço: ${e["rua"]}, ${e["numero"] ?? 'S/N'}", style: TextStyle(color: Colors.black87)),
        Text("Bairro: ${e["bairro"]}", style: TextStyle(color: Colors.black87)),
        Text("Cidade: ${e["cidade"]} - ${e["estado"]}", style: TextStyle(color: Colors.black87)),
        Text("CEP: ${e["cep"]}", style: TextStyle(color: Colors.black87)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      userRole: userRole ?? "VISITANTE",
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Container(
            padding: EdgeInsets.all(24),
            constraints: BoxConstraints(maxWidth: 600),
            margin: EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 16,
                  offset: Offset(0, 6),
                ),
              ],
            ),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    "Participar de Eventos",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: _primaryColor,
                    ),
                  ),
                ),

                SizedBox(height: 30),

                Text(
                  "Selecione o Evento:",
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
                ),
                SizedBox(height: 8),
                DropdownButtonFormField(
                  value: eventoSelecionado,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                    labelText: "Evento",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: _primaryColor, width: 2),
                    ),
                  ),
                  items: eventos
                      .map(
                        (ev) => DropdownMenuItem(
                          value: ev,
                          child: Text(
                            "${ev["titulo"]} — ${formatarData(ev["data"])}",
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (value) async {
                    setState(() => eventoSelecionado = value);
                    await carregarParticipantes();
                    await carregarLocal();
                  },
                ),

                if (mensagem.isNotEmpty) ...[
                  SizedBox(height: 18),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: mensagemTipo == "error"
                          ? _errorColor.withOpacity(0.15)
                          : _successColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: mensagemTipo == "error" ? _errorColor : _successColor,
                        width: 1.5,
                      ),
                    ),
                    child: Text(
                      mensagem,
                      style: TextStyle(
                        color: mensagemTipo == "error" ? _errorColor : _successColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],

                if (eventoSelecionado != null) ...[
                  SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryColor,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                      ),
                      onPressed: () =>
                          participar(eventoSelecionado["titulo"].toString()),
                      child: Text(
                        "Confirmar Participação",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],

                if (eventoSelecionado != null) ...[
                  SizedBox(height: 40),
                  Text(
                    "Detalhes do Evento Selecionado",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: _primaryColor,
                    ),
                  ),
                  Divider(height: 20, thickness: 1, color: Colors.grey.shade300),

                  _buildDetailRow("Descrição:", eventoSelecionado["descricao"] ?? 'N/A'),
                  _buildDetailRow("Data/Hora:", formatarData(eventoSelecionado["data"])),
                  _buildDetailRow("Tipo:", eventoSelecionado["tipoEvento"] ?? 'N/A'),
                  _buildDetailRow("Estado:", eventoSelecionado["estadoEvento"] ?? 'N/A'),
                  _buildDetailRow("Vagas:", eventoSelecionado["vagas"]?.toString() ?? '0'),


                  if (eventoSelecionado["tipoEvento"] == "PRESENCIAL" || eventoSelecionado["tipoEvento"] == "HIBRIDO") ...[
                    SizedBox(height: 20),
                    Text(
                      "Local",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 8),
                    formatarEndereco(localDetalhes),
                  ],
                ],

                if (eventoSelecionado != null && userRole != "VISITANTE") ...[
                  SizedBox(height: 40),
                  Text(
                    "Quem Vai Participar",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: _primaryColor,
                    ),
                  ),
                  Divider(height: 20, thickness: 1, color: Colors.grey.shade300),

                  if (participantes.isEmpty)
                    Text("Nenhum participante registrado ainda.", style: TextStyle(color: Colors.black54)),

                  ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: participantes.length,
                    itemBuilder: (context, index) {
                      final p = participantes[index];
                      return _buildParticipantTile(
                        p["nome"] ?? p["email"] ?? "Usuário Desconhecido",
                        p["email"],
                      );
                    },
                  ),
                ],

                SizedBox(height: 40),
                Text(
                  "Seus Eventos Confirmados",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: _primaryColor,
                  ),
                ),
                Divider(height: 20, thickness: 1, color: Colors.grey.shade300),

                if (meusEventos.isEmpty)
                  Text("Você não possui participações confirmadas em eventos.", style: TextStyle(color: Colors.black54)),

                ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: meusEventos.length,
                  itemBuilder: (context, index) {
                    final ev = meusEventos[index];
                    return _buildMyEventTile(
                      ev["titulo"],
                      formatarData(ev["data"]),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.black87,
              fontSize: 15,
            ),
          ),
          SizedBox(width: 4),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: Colors.black87, fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParticipantTile(String nome, String? email) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.person_outline, size: 20, color: _primaryColor),
          SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                nome,
                style: TextStyle(
                    fontWeight: FontWeight.w600, color: Colors.black87),
              ),
              if (email != null)
                Text(
                  email,
                  style: TextStyle(color: Colors.black54, fontSize: 13),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMyEventTile(String titulo, String data) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _primaryColor.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: _primaryColor),
          ),
          SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.calendar_today, size: 14, color: Colors.black54),
              SizedBox(width: 5),
              Text(
                data,
                style: TextStyle(color: Colors.black54, fontSize: 13),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
// lib/screens/evento_screen.dart
import 'package:evt_flutter/widgets/app_layout.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert'; // 🎯 Adicionar para jsonDecode, utf8 e base64
import 'package:shared_preferences/shared_preferences.dart';
import '../services/evento_service.dart';
import '../services/local_service.dart';
import '../services/usuarios_service.dart'; // Importação do serviço de Usuários
import '../widgets/app_header.dart'; // Assumindo que AppHeader está disponível

class EventosPage extends StatefulWidget {
  const EventosPage({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _EventosPageState createState() => _EventosPageState();
}

class _EventosPageState extends State<EventosPage> {
  // === ESTADO E CONTROLADORES ===
  List<dynamic> eventos = [];
  List<dynamic> locais = []; // Locais disponíveis
  List<dynamic> palestrantes = []; // Usuários disponíveis
  Map<String, dynamic>? eventoEditando;
  String? userRole;

  final TextEditingController tituloCtrl = TextEditingController();
  final TextEditingController descricaoCtrl = TextEditingController();
  final TextEditingController vagasCtrl = TextEditingController(text: '0');

  DateTime? dataEvento;
  String tipoEvento = "PRESENCIAL";
  int? localId;
  int? palestranteId;

  String mensagemAlerta = ""; // Alterado para seguir o nome de UsuarioScreen
  bool isError = false; // Adicionado para seguir o nome de UsuarioScreen
  bool loading = false; // Adicionado para seguir o nome de UsuarioScreen
  bool mostrarForm = false;

  final tiposEvento = [
    'PRESENCIAL',
    'REMOTO',
    'HIBRIDO',
  ];


  @override
  void initState() {
    super.initState();
    carregarTokenRole();
    carregarDados();
  }

  @override
  void dispose() {
    tituloCtrl.dispose();
    descricaoCtrl.dispose();
    vagasCtrl.dispose();
    super.dispose();
  }

  // === LÓGICA DE DADOS ===

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

  Future<void> carregarDados() async {
    setState(() {
      mensagemAlerta = "";
      isError = false;
    });
    try {
      final e = await EventoService.getEventos();
      final l = await LocalService.getLocais();
      final p = await UsuarioService.getUsuarios();

      setState(() {
        eventos = e;
        locais = l;
        palestrantes = p;
      });
    } catch (e) {
      setState(() {
        mensagemAlerta = "Erro ao carregar dados: ${e.toString().replaceFirst('Exception: ', '')}";
        isError = true;
      });
    }
  }

  void limparForm({bool manterVisibilidade = false}) {
    setState(() {
      eventoEditando = null;
      tituloCtrl.clear();
      descricaoCtrl.clear();
      vagasCtrl.text = '0';
      dataEvento = null;
      tipoEvento = "PRESENCIAL";
      localId = null;
      palestranteId = null;
      mensagemAlerta = ""; // Limpa a mensagem ao limpar o formulário
      isError = false; // Limpa o estado de erro
      if (!manterVisibilidade) {
        mostrarForm = false;
      }
    });
  }

  void preencherForm(Map<String, dynamic> e) {
    limparForm(manterVisibilidade: true); // Limpa campos, mas mantém 'mostrarForm' true
    
    final dataString = e['data'];
    final localIdValue = e['localId'];
    final palestranteIdValue = e['palestranteId'];

    DateTime? parsedDate;
    if (dataString is String) {
      try {
        parsedDate = DateTime.parse(dataString);
      } catch (_) {}
    }

    // Garante que os IDs sejam tratados como int (necessário para Dropdown)
    final parsedLocalId = localIdValue is int ? localIdValue : (localIdValue is String ? int.tryParse(localIdValue) : null);
    final parsedPalestranteId = palestranteIdValue is int ? palestranteIdValue : (palestranteIdValue is String ? int.tryParse(palestranteIdValue) : null);

    setState(() {
      eventoEditando = e;
      tituloCtrl.text = e['titulo'] ?? "";
      descricaoCtrl.text = e['descricao'] ?? "";
      vagasCtrl.text = (e['vagas'] ?? 0).toString();
      dataEvento = parsedDate;
      tipoEvento = e['tipoEvento'] ?? "PRESENCIAL";
      localId = parsedLocalId;
      palestranteId = parsedPalestranteId;
      mostrarForm = true;
      mensagemAlerta = "";
      isError = false;
    });
  }

  Future<void> selecionarData(BuildContext context) async {
    final DateTime? dataSelecionada = await showDatePicker(
      context: context,
      initialDate: dataEvento ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2030),
    );

    if (dataSelecionada != null) {
      final TimeOfDay? horaSelecionada = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(dataEvento ?? DateTime.now()),
      );

      if (horaSelecionada != null) {
        setState(() {
          dataEvento = DateTime(
            dataSelecionada.year,
            dataSelecionada.month,
            dataSelecionada.day,
            horaSelecionada.hour,
            horaSelecionada.minute,
          );
        });
      }
    }
  }

  Future<void> salvar() async {
    setState(() {
      loading = true;
      mensagemAlerta = "";
      isError = false;
    });

    // === VALIDAÇÕES ===
    if (tituloCtrl.text.isEmpty) {
      setState(() {
        mensagemAlerta = "O título é obrigatório";
        isError = true;
        loading = false;
      });
      return;
    }
    if (dataEvento == null) {
      setState(() {
        mensagemAlerta = "Selecione uma data e hora";
        isError = true;
        loading = false;
      });
      return;
    }
    if (palestranteId == null) {
      setState(() {
        mensagemAlerta = "Selecione o palestrante";
        isError = true;
        loading = false;
      });
      return;
    }
    if ((tipoEvento == "PRESENCIAL" || tipoEvento == "HIBRIDO") && localId == null) {
      setState(() {
        mensagemAlerta = "Selecione o local do evento";
        isError = true;
        loading = false;
      });
      return;
    }
    if ((int.tryParse(vagasCtrl.text) ?? 0) < 0) {
      setState(() {
        mensagemAlerta = "O número de vagas não pode ser negativo";
        isError = true;
        loading = false;
      });
      return;
    }

    // === CONSTRUÇÃO DO BODY ===
    final body = {
      "titulo": tituloCtrl.text,
      "descricao": descricaoCtrl.text,
      "data": dataEvento!.toIso8601String(),
      "tipoEvento": tipoEvento,
      "estadoEvento": "ABERTO", // Assumindo estado inicial
      "vagas": int.tryParse(vagasCtrl.text) ?? 0,
      "localId": tipoEvento == "REMOTO" ? null : localId,
      "palestranteId": palestranteId,
    };

    try {
      if (eventoEditando != null) {
        await EventoService.editarEvento(eventoEditando!["id"] as int, body);
        setState(() {
          mensagemAlerta = "Evento atualizado com sucesso!";
          isError = false;
        });
      } else {
        await EventoService.criarEvento(body);
        setState(() {
          mensagemAlerta = "Evento cadastrado com sucesso!";
          isError = false;
        });
      }

      await carregarDados();
      limparForm();
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
      await EventoService.deletarEvento(id);
      await carregarDados();
      setState(() {
        mensagemAlerta = "Evento deletado com sucesso!";
        isError = false;
      });
    } catch (e) {
      setState(() {
        mensagemAlerta = e.toString().replaceFirst('Exception: ', '');
        isError = true;
      });
    }
  }

  // === WIDGETS DE DESIGN (COPIADOS/ADAPTADOS DE _UsuarioScreenState) ===

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

  // Widget auxiliar para formatar a data
  String _formatarData(DateTime? date) {
    if (date == null) return "Selecione data e hora";
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
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

          TextField(controller: tituloCtrl, decoration: inputStyle("Título do Evento")),
          const SizedBox(height: 10),

          TextField(
            controller: descricaoCtrl,
            decoration: inputStyle("Descrição"),
            maxLines: 3,
          ),
          const SizedBox(height: 10),

          // Data e Hora e Vagas
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => selecionarData(context),
                  icon: const Icon(Icons.calendar_today, size: 18, color: Color(0xFF2563EB)),
                  label: Text(
                    _formatarData(dataEvento),
                    style: TextStyle(color: dataEvento == null ? Colors.black54 : Colors.black),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: Color(0xFF2563EB)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // Vagas (Campo de texto com design de inputStyle)
              SizedBox(
                width: 100,
                child: TextField(
                  controller: vagasCtrl,
                  decoration: inputStyle("Vagas"),
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Dropdown: Tipo de Evento
          DropdownButtonFormField<String>(
            value: tipoEvento.isEmpty ? null : tipoEvento,
            decoration: inputStyle("Tipo de Evento"),
            items: tiposEvento.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
            onChanged: (v) {
              setState(() {
                tipoEvento = v.toString();
                if (tipoEvento == "REMOTO") localId = null;
              });
            },
          ),
          const SizedBox(height: 10),

          // Dropdown: Palestrante (Usuários)
          DropdownButtonFormField<int>(
            value: palestranteId,
            decoration: inputStyle("Palestrante"),
            items: palestrantes.map((p) => DropdownMenuItem<int>(
                  value: p['id'] as int,
                  child: Text(p['nome'] ?? 'Usuário Sem Nome'),
                )).toList(),
            onChanged: (v) => setState(() => palestranteId = v),
            isExpanded: true,
          ),
          const SizedBox(height: 10),

          // Dropdown: Local (Visível apenas para PRESENCIAL ou HIBRIDO)
          if (tipoEvento == "PRESENCIAL" || tipoEvento == "HIBRIDO")
            Column(
              children: [
                DropdownButtonFormField<int>(
                  value: localId,
                  decoration: inputStyle("Local do Evento"),
                  items: locais.map((l) => DropdownMenuItem<int>(
                        value: l['id'] as int,
                        child: Text(l['nome'] ?? 'Local Sem Nome'),
                      )).toList(),
                  onChanged: (v) => setState(() => localId = v),
                  isExpanded: true,
                ),
                const SizedBox(height: 20),
              ],
            ),
          
          if (!(tipoEvento == "PRESENCIAL" || tipoEvento == "HIBRIDO"))
            const SizedBox(height: 20), // Espaçamento se o local não for exibido

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: loading ? null : salvar,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                backgroundColor: eventoEditando != null ? const Color(0xFF2563EB) : Colors.green,
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
                      eventoEditando != null ? "Atualizar Evento" : "Cadastrar Evento",
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16),
                    ),
            ),
          )
        ],
      ),
    );
  }

  Widget buildCard(dynamic evento) {
    // Busca o nome do palestrante e local para exibição
    final palestranteNome = palestrantes.firstWhere(
        (p) => p['id'] == evento['palestranteId'],
        orElse: () => {'nome': 'Desconhecido'})['nome'];
    final localNome = locais.firstWhere(
        (l) => l['id'] == evento['localId'],
        orElse: () => {'nome': 'Remoto/N/A'})['nome'];

    final dataHora = _formatarData(DateTime.tryParse(evento['data'] ?? ''));
    final tipo = evento['tipoEvento'];

    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        title: Text(
          evento["titulo"] ?? "",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Tipo: $tipo"),
            Text("Data/Hora: $dataHora"),
            Text("Palestrante: $palestranteNome"),
            if (tipo != 'REMOTO') Text("Local: $localNome"),
            Text("Vagas: ${evento['vagas'] ?? 0}"),
          ],
        ),
        isThreeLine: true, // Garante espaço para mais linhas
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Color(0xFF2563EB)),
              onPressed: () => preencherForm(evento),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => deletar(evento["id"] as int),
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
                  eventoEditando != null ? "Editar Evento" : "Cadastrar Evento",
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
                      limparForm(); // Limpa e fecha
                    } else {
                      limparForm(manterVisibilidade: true); // Limpa mas só vai mostrar se mostrarForm for true
                      setState(() => mostrarForm = true); // Alterna e mostra o formulário limpo
                    }
                  },
                  icon: Icon(
                    mostrarForm ? Icons.close : Icons.add,
                    color: Colors.white,
                  ),
                  label: Text(
                    mostrarForm ? "Fechar" : "Novo Evento",
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
                "Eventos Cadastrados",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 14),

            if (eventos.isEmpty)
              const Text("Nenhum evento cadastrado", style: TextStyle(color: Colors.grey)),

            ...eventos.map(buildCard).toList(),
          ],
        ),
      ),
    );
  }
}
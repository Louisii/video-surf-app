import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';
import 'package:video_surf_app/dao/indicador_dao.dart';
import 'package:video_surf_app/dao/tipo_acao_dao.dart';
import 'package:video_surf_app/model/enum/side.dart';
import 'package:video_surf_app/model/tipo_acao.dart';
import 'package:video_surf_app/model/indicador.dart';
import 'package:video_surf_app/widget/custom_appbar_widget.dart';
import 'package:video_surf_app/widget/custom_drawer_widget.dart';

class TipoAcaoIndicadorScreen extends StatefulWidget {
  const TipoAcaoIndicadorScreen({super.key});

  @override
  State<TipoAcaoIndicadorScreen> createState() =>
      _TipoAcaoIndicadorScreenState();
}

class _TipoAcaoIndicadorScreenState extends State<TipoAcaoIndicadorScreen> {
  late TipoAcaoDao tipoAcaoDao;
  late IndicadorDao indicadorDao;

  late Future<Map<TipoAcao, List<Indicador>>> dataFuture;

  @override
  void initState() {
    super.initState();
    tipoAcaoDao = TipoAcaoDao();
    indicadorDao = IndicadorDao();
    _loadData();
  }

  void _loadData() {
    dataFuture = _fetchData();
  }

  Future<Map<TipoAcao, List<Indicador>>> _fetchData() async {
    final tipoAcoes = await tipoAcaoDao.getAll();
    final indicadores = await indicadorDao.getAll();

    final Map<int, TipoAcao> tipoAcaoMap = {
      for (var t in tipoAcoes) t.tipoAcaoId!: t,
    };

    final Map<TipoAcao, List<Indicador>> grouped = {};
    for (final indicador in indicadores) {
      final tipo = tipoAcaoMap[indicador.idTipoAcao];
      if (tipo != null) {
        grouped.putIfAbsent(tipo, () => []).add(indicador);
      }
    }
    return grouped;
  }

  Future<void> _importCsv() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );

    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      final content = await file.readAsString();
      final rows = const CsvToListConverter().convert(content);

      final dataRows = rows.skip(1);

      final List<String> erros = [];

      for (var i = 0; i < dataRows.length; i++) {
        final row = dataRows.elementAt(i);

        if (row.isEmpty || row.length < 3) {
          continue;
        }

        try {
          final nivel = row[0].toString();
          final side = row[1].toString();
          final nomeManobra = row[2].toString();
          final ordemItem = row[3].toString();
          final descricao = row[4].toString();

          // Verifica se tipo ação já existe
          TipoAcao? tipo = await tipoAcaoDao.findByNomeNivel(
            nome: nomeManobra,
            nivel: nivel,
          );

          if (tipo == null) {
            final novo = TipoAcao(
              nome: nomeManobra,
              nivel: nivel,
              side: SideExt.findSide(side),
            );
            final id = await tipoAcaoDao.create(novo);
            tipo = TipoAcao(
              tipoAcaoId: id,
              nome: nomeManobra,
              nivel: nivel,
              side: SideExt.findSide(side),
            );
          }
          final indicador = Indicador(
            descricao: descricao,
            idTipoAcao: tipo.tipoAcaoId!,
            ordemItem: int.tryParse(ordemItem) ?? 0,
          );
          await indicadorDao.create(indicador);
        } catch (e) {
          erros.add("Linha ${i + 2}: $e");
        }
      }

      setState(() {
        _loadData();
      });

      if (mounted) {
        final titulo = erros.isEmpty ? 'Sucesso' : 'Importação com erros';
        final mensagem = erros.isEmpty
            ? "CSV importado com sucesso."
            : "Erros:\n${erros.join('\n')}";

        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(titulo),
            content: SingleChildScrollView(child: SelectableText(mensagem)),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Ok'),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      drawer: const CustomDrawerWidget(),
      appBar: const CustomAppbarWidget(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton.icon(
              onPressed: _importCsv,
              icon: const Icon(Icons.file_upload),
              label: const Text("Importar CSV Tipo Ações + Indicadores"),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: FutureBuilder<Map<TipoAcao, List<Indicador>>>(
                future: dataFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text('Erro ao carregar dados: ${snapshot.error}'),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text("Nenhum dado cadastrado"));
                  }

                  final grouped = snapshot.data!;

                  return ListView(
                    children: grouped.entries.map((entry) {
                      return _buildCardTipoAcao(entry.key, entry.value);
                    }).toList(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardTipoAcao(TipoAcao tipo, List<Indicador> indicadores) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      child: ExpansionTile(
        leading: Icon(
          Icons.directions_run,
          color: Theme.of(context).colorScheme.primary,
        ),
        title: Text(tipo.nome),
        subtitle: Text("Nível: ${tipo.nivel}"),
        children: indicadores.map((ind) {
          return ListTile(
            leading: const Icon(Icons.checklist),
            title: Text(ind.descricao),
            trailing: PopupMenuButton<String>(
              onSelected: (value) async {
                if (value == 'excluir') {
                  await indicadorDao.delete(ind.indicadorId!);
                  setState(() {
                    _loadData();
                  });
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'excluir',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red),
                      SizedBox(width: 8),
                      Text("Excluir"),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';
import 'package:video_surf_app/model/local.dart';
import 'package:video_surf_app/dao/local_dao.dart';
import 'package:video_surf_app/widget/custom_appbar_widget.dart';
import 'package:video_surf_app/widget/custom_drawer_widget.dart';

class LocalScreen extends StatefulWidget {
  const LocalScreen({super.key});

  @override
  State<LocalScreen> createState() => _LocalScreenState();
}

class _LocalScreenState extends State<LocalScreen> {
  late LocalDao localDao;
  late Future<List<Local>> locaisFuture;

  @override
  void initState() {
    super.initState();
    localDao = LocalDao();
    _loadLocais();
  }

  void _loadLocais() {
    locaisFuture = localDao.getAll();
  }

  Future<void> _importCsv() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );

    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      final content = await file.readAsString();
      final rows = const CsvToListConverter().convert(content, eol: '\n');
      final dataRows = rows.skip(1);

      final List<String> erros = [];

      for (var i = 0; i < dataRows.length; i++) {
        final row = dataRows.elementAt(i);
        try {
          final local = LocalCSV.fromCSV(row.map((e) => e.toString()).toList());

          await localDao.create(local);
        } catch (e) {
          erros.add("Linha ${i + 2}: $e");
        }
      }

      setState(() {
        _loadLocais();
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
        child: Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  ElevatedButton.icon(
                    onPressed: _importCsv,
                    icon: const Icon(Icons.file_upload),
                    label: const Text("Importar CSV de Locais"),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: FutureBuilder<List<Local>>(
                      future: locaisFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        } else if (snapshot.hasError) {
                          return Center(
                            child: Text(
                              'Erro ao carregar locais: ${snapshot.error}',
                            ),
                          );
                        } else if (!snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          return const Center(
                            child: Text("Nenhum local cadastrado"),
                          );
                        }

                        final locais = snapshot.data!
                          ..sort((a, b) => a.praia.compareTo(b.praia));

                        return SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: locais.map((local) {
                                return _buildListTileLocal(context, local);
                              }).toList(),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListTileLocal(BuildContext context, Local local) {
    return SizedBox(
      width: 520,
      child: Card(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                spacing: 16,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Theme.of(context).colorScheme.primary,
                        width: 3,
                      ),
                    ),
                    child: Icon(
                      Icons.tsunami,
                      size: 30,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${local.praia} - ${local.pico}",
                        style: Theme.of(context).textTheme.titleMedium,
                      ),

                      Text("${local.cidade}, ${local.pais}"),
                    ],
                  ),
                ],
              ),

              PopupMenuButton<String>(
                onSelected: (value) async {
                  if (value == 'excluir') {
                    await localDao.delete(local.localId!);
                    setState(() {
                      _loadLocais();
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
            ],
          ),
        ),
      ),
    );
  }
}

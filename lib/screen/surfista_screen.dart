import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';
import 'package:video_surf_app/model/surfista.dart';
import 'package:video_surf_app/dao/surfista_dao.dart';
import 'package:video_surf_app/screen/videos_screen.dart';
import 'package:video_surf_app/widget/custom_appbar_widget.dart';
import 'package:video_surf_app/widget/custom_drawer_widget.dart';
import 'package:video_surf_app/widget/novo_video_dialog.dart';

class SurfistarScreen extends StatefulWidget {
  const SurfistarScreen({super.key});

  @override
  State<SurfistarScreen> createState() => _SurfistarScreenState();
}

class _SurfistarScreenState extends State<SurfistarScreen> {
  late SurfistaDao surfistaDao;
  late Future<List<Surfista>> surfistasFuture;

  @override
  void initState() {
    super.initState();
    surfistaDao = SurfistaDao();
    _loadSurfistas();
  }

  void _loadSurfistas() {
    surfistasFuture = surfistaDao.getAll();
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
          final surfista = Surfista.fromCSV(
            row.map((e) => e.toString()).toList(),
          );

          // Verifica se o CPF já existe
          final existente = await surfistaDao.getByCpf(surfista.cpf);
          if (existente != null) {
            erros.add("Linha ${i + 2}: CPF ${surfista.cpf} já cadastrado.");
            continue;
          }

          await surfistaDao.create(surfista);
        } catch (e) {
          erros.add("Linha ${i + 2}: $e");
        }
      }

      // Atualiza o Future para recarregar os surfistas
      setState(() {
        _loadSurfistas();
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
                    label: const Text("Importar CSV de Surfistas"),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: FutureBuilder<List<Surfista>>(
                      future: surfistasFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        } else if (snapshot.hasError) {
                          return Center(
                            child: Text(
                              'Erro ao carregar surfistas: ${snapshot.error}',
                            ),
                          );
                        } else if (!snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          return const Center(
                            child: Text("Nenhum surfista cadastrado"),
                          );
                        }

                        final surfistas = snapshot.data!
                          ..sort((a, b) => a.nome.compareTo(b.nome));
                        return SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Wrap(
                              spacing: 12, // espaço horizontal
                              runSpacing: 12, // espaço vertical
                              children: surfistas.map((surfista) {
                                return _buildListTileSurfista(
                                  context,
                                  surfista,
                                );
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

  Widget _buildListTileSurfista(BuildContext context, Surfista surfista) {
    return SizedBox(
      width: 520,
      child: Stack(
        children: [
          Card(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  surfista.iconeSurfista(Theme.of(context).colorScheme.primary),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        surfista.nome,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("CPF: ${surfista.cpf}"),

                          Text("Idade: ${surfista.idade}"),
                          Text(
                            "Data de nascimento: ${surfista.dataNascimentoFormatada}",
                          ),
                          Text("Base: ${surfista.base.name}"),

                          FutureBuilder(
                            future: surfista.nVideosDb,
                            builder: (context, asyncSnapshot) {
                              int n = asyncSnapshot.data ?? 0;
                              return Text(
                                n != 1 ? "$n vídeos" : "$n vídeo",
                                style: Theme.of(context).textTheme.bodySmall!
                                    .copyWith(color: Colors.grey),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(
                    width: 160,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      spacing: 8,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            PopupMenuButton<String>(
                              iconColor: Colors.black54,
                              onSelected: (value) async {
                                if (value == 'excluir') {
                                  await surfistaDao.delete(
                                    surfista.surfistaId!,
                                  );
                                  setState(() {
                                    _loadSurfistas(); // recarrega a lista
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
                        SizedBox(height: 8),
                        Column(
                          spacing: 8,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () async {
                                      final result = await showDialog(
                                        context: context,
                                        builder: (context) =>
                                            NovoVideoDialog(surfista: surfista),
                                      );

                                      if (result == true) {
                                        setState(() {
                                          _loadSurfistas();
                                        });
                                      }
                                    },
                                    icon: Icon(Icons.library_add),
                                    label: Text("Novo Vídeo"),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              VideosScreen(surfista: surfista),
                                        ),
                                      );
                                    },
                                    icon: Icon(
                                      Icons.video_library_rounded,
                                      color: Colors.teal.shade900,
                                    ),
                                    label: Text(
                                      "Galeria",
                                      style: TextStyle(
                                        color: Colors.teal.shade900,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.teal.shade100,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

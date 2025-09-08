import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';
import 'package:video_surf_app/model/surfista.dart';
import 'package:video_surf_app/dao/surfista_dao.dart';
import 'package:video_surf_app/widget/custom_appbar_widget.dart';
import 'package:video_surf_app/widget/custom_drawer_widget.dart';

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
            content: SingleChildScrollView(child: Text(mensagem)),
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
              label: const Text("Importar CSV de Surfistas"),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: FutureBuilder<List<Surfista>>(
                future: surfistasFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Erro ao carregar surfistas: ${snapshot.error}',
                      ),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text("Nenhum surfista cadastrado"),
                    );
                  }

                  final surfistas = snapshot.data!;
                  return ListView.builder(
                    itemCount: surfistas.length,
                    itemBuilder: (context, index) {
                      final surfista = surfistas[index];
                      return Card(
                        color: Colors.white,
                        child: ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Theme.of(context).colorScheme.primary,
                                width: 3,
                              ),
                            ),
                            child: Icon(
                              Icons.surfing,
                              size: 30,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          title: Text(surfista.nome),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("CPF: ${surfista.cpf}"),
                              Text(
                                "Data de nascimento: ${surfista.dataNascimentoFormatada}",
                              ),
                              Text("Base: ${surfista.base.name}"),
                            ],
                          ),
                          trailing: Text(
                            "${surfista.videos.length} vídeos",
                            style: Theme.of(
                              context,
                            ).textTheme.bodySmall!.copyWith(color: Colors.grey),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

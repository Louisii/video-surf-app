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
  List<Surfista> surfistasCsv = [];
  late SurfistaDao surfistaDao;

  @override
  void initState() {
    super.initState();
    surfistaDao = SurfistaDao();
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

    // Pula o cabeçalho
    final dataRows = rows.skip(1);

    final List<Surfista> surfistas = [];
    final List<String> erros = [];

    for (var i = 0; i < dataRows.length; i++) {
      final row = dataRows.elementAt(i);

      try {
        final surfista =
            Surfista.fromCSV(row.map((e) => e.toString()).toList());

        // Verifica se o CPF já existe
        final existente = await surfistaDao.getByCpf(surfista.cpf);
        if (existente != null) {
          erros.add("Linha ${i + 2}: CPF ${surfista.cpf} já cadastrado.");
          continue; // pula a inserção
        }

        final id = await surfistaDao.create(surfista);
        surfistas.add(surfista.copyWith(surfistaId: id));
      } catch (e) {
        erros.add("Linha ${i + 2}: $e");
      }
    }

    setState(() {
      surfistasCsv = surfistas;
    });

    if (mounted) {
      final total = surfistas.length;
      final titulo = erros.isEmpty ? 'Sucesso' : 'Importação com erros';
      final mensagem = erros.isEmpty
          ? "CSV importado com sucesso: $total surfistas."
          : "Importados: $total surfistas.\n\nErros:\n${erros.join('\n')}";

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(titulo),
          content: SingleChildScrollView(child: Text(mensagem)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Fechar'),
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
              child: surfistasCsv.isEmpty
                  ? const Center(child: Text("Nenhum surfista importado"))
                  : ListView.builder(
                      itemCount: surfistasCsv.length,
                      itemBuilder: (context, index) {
                        final surfista = surfistasCsv[index];
                        return Card(
                          child: ListTile(
                            leading: const Icon(Icons.surfing),
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
                              style: Theme.of(context).textTheme.bodySmall!
                                  .copyWith(color: Colors.grey),
                            ),
                          ),
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

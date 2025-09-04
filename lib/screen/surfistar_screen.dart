import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';
import 'package:video_surf_app/widget/custom_appbar_widget.dart';
import 'package:video_surf_app/widget/custom_drawer_widget.dart';

class SurfistarScreen extends StatefulWidget {
  const SurfistarScreen({super.key});

  @override
  State<SurfistarScreen> createState() => _SurfistarScreenState();
}

class _SurfistarScreenState extends State<SurfistarScreen> {
  List<List<dynamic>> surfistasCsv = [];

  Future<void> _importCsv() async {
    // Abre o picker de arquivos
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );

    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      final content = await file.readAsString();
      final rows = const CsvToListConverter().convert(content);

      setState(() {
        surfistasCsv = rows;
      });

      // Aqui você pode salvar no banco:
      // rows.forEach((row) => salvarSurfistaNoBanco(row));

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('CSV importado com sucesso!')),
      );
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
                        final row = surfistasCsv[index];
                        return ListTile(
                          title: Text(row[2].toString()), // Nome do surfista
                          subtitle: Text("CPF: ${row[1]}"),
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

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';
import 'package:video_surf_app/model/enum/base_surfista.dart';
import 'package:video_surf_app/model/surfista.dart';
import 'package:video_surf_app/widget/custom_appbar_widget.dart';
import 'package:video_surf_app/widget/custom_drawer_widget.dart';

class SurfistarScreen extends StatefulWidget {
  const SurfistarScreen({super.key});

  @override
  State<SurfistarScreen> createState() => _SurfistarScreenState();
}

class _SurfistarScreenState extends State<SurfistarScreen> {
  List<Surfista> surfistasCsv = [];

  Future<void> _importCsv() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );

    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      final content = await file.readAsString();
      final rows = const CsvToListConverter().convert(content, eol: '\n');

      // Pula o cabeçalho (linha 0)
      final dataRows = rows.skip(1);

      final List<Surfista> surfistas = dataRows.map((row) {
        String baseStr = row[4].toString().trim().toLowerCase();
        BaseSurfista base;

        switch (baseStr) {
          case 'regular':
            base = BaseSurfista.regular;
            break;
          case 'goofy':
            base = BaseSurfista.goofy;
            break;
          default:
            base = BaseSurfista.regular;
        }

        return Surfista(
          surfistaId: row[0] != 0 ? row[0] : null,
          cpf: row[1].toString(),
          nome: row[2].toString(),
          dataNascimento: DateTime.parse(row[3].toString()),
          base: base,
        );
      }).toList();

      setState(() {
        surfistasCsv = surfistas;
      });

      // Exemplo de salvar no banco (assumindo que você tenha um DAO):
      // for (var surfista in surfistas) {
      //   await SurfistaDAO.instance.insert(surfista);
      // }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('CSV importado com ${surfistas.length} surfistas!'),
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
                          color: Colors.teal.shade50,
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              spacing: 16,
                              children: [
                                Icon(
                                  Icons.surfing,
                                  color: Colors.teal.shade800,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      surfista.nome,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium!
                                          .copyWith(
                                            color: Colors.teal.shade800,
                                          ),
                                    ),
                                    Text("CPF: ${surfista.cpf}"),
                                    Text(
                                      "Data de nascimento: ${surfista.dataNascimentoFormatada}",
                                    ),
                                    Text("Base: ${surfista.base.name}"),
                                  ],
                                ),
                              ],
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

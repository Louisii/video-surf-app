import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:video_surf_app/model/relatorio_onda.dart';
import 'package:video_surf_app/model/surfista.dart';

Future<File> exportarRelatorioCsv(
  Surfista surfista,
  List<RelatorioOnda> relatorio,
) async {
  final buffer = StringBuffer();

  // Cabeçalho
  buffer.writeln(
    'Onda;Data;Local;Lado;Terminou Caindo;Total Manobras;Desempenho (%)',
  );

  // Linhas
  for (int i = 0; i < relatorio.length; i++) {
    final r = relatorio[i];

    buffer.writeln(
      '${i + 1};'
      '${_formatDate(r.data)};'
      '${r.local};'
      '${r.lado};'
      '${r.terminouCaindo ? 'Sim' : 'Não'};'
      '${r.totalManobras};'
      '${r.desempenhoPercent.toStringAsFixed(0)}',
    );
  }

  // Diretório
  final directory = await getApplicationDocumentsDirectory();

  final fileName =
      'relatorio_${surfista.nome.replaceAll(' ', '_').toLowerCase()}.csv';

  final file = File('${directory.path}/$fileName');

  return file.writeAsString(
    buffer.toString(),
    encoding: const SystemEncoding(),
  );
}

String _formatDate(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}/'
    '${d.month.toString().padLeft(2, '0')}/'
    '${d.year}';

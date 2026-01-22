import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:video_surf_app/model/avaliacao_indicador.dart';
import 'package:video_surf_app/model/avaliacao_manobra.dart';
import 'package:video_surf_app/model/enum/classificacao.dart';
import 'package:video_surf_app/model/relatorio_onda.dart';
import 'package:video_surf_app/model/surfista.dart';

Future<File> exportarRelatorioCsvCompleto(
  Surfista surfista,
  List<RelatorioOnda> relatorio,
) async {
  final buffer = StringBuffer();

  // Cabeçalho
  buffer.writeln(
    'Surfista;'
    'Onda;Data;Local;Lado;Terminou Caindo;'
    'Manobra;Indicador;Classificacao;Nota;'
    'Total Manobras Onda;Desempenho Onda (%)',
  );

  for (int i = 0; i < relatorio.length; i++) {
    RelatorioOnda relOnda = relatorio[i];

    for (final AvaliacaoManobra manobra in relOnda.manobrasAvaliadas) {
      for (final AvaliacaoIndicador indicador in manobra.avaliacaoIndicadores) {
        buffer.writeln(
          '${surfista.nome};'
          '${i + 1};'
          '${_formatDate(relOnda.data)};'
          '${relOnda.local};'
          '${relOnda.lado};'
          '${relOnda.terminouCaindo ? 'Sim' : 'Não'};'
          '${manobra.tipoAcao?.nome ?? "nome ação"};'
          '${indicador.indicador?.descricao ?? "descrição indicador"};'
          '${indicador.classificacao.label};'
          '${indicador.classificacao.valor};'
          '${relOnda.totalManobras};'
          '${relOnda.desempenhoPercent.toStringAsFixed(0)}',
        );
      }
    }
  }

  final directory = await getApplicationDocumentsDirectory();

  final fileName =
      'relatorio_completo_${surfista.nome.replaceAll(' ', '_').toLowerCase()}.csv';

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

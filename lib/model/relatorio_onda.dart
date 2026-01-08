import 'package:video_surf_app/model/avaliacao_manobra.dart';
import 'package:video_surf_app/model/enum/classificacao.dart';
import 'package:video_surf_app/model/onda.dart';

class RelatorioOnda {
  final int ondaId;
  final DateTime data;
  final String local;
  final String lado;
  final bool terminouCaindo;
  final bool avaliada;
  List<AvaliacaoManobra> manobrasAvaliadas;

  final int totalManobras;
  final int totalIndicadores;
  final double mediaIndicadores;
  final double desempenhoPercent;

  RelatorioOnda({
    required this.ondaId,
    required this.data,
    required this.local,
    required this.lado,
    required this.terminouCaindo,
    required this.avaliada,
    required this.totalManobras,
    required this.totalIndicadores,
    required this.mediaIndicadores,
    required this.desempenhoPercent,
    required this.manobrasAvaliadas,
  });

  /// Para CSV
  List<String> toCsvRow() {
    return [
      data.toIso8601String(),
      local,
      lado,
      terminouCaindo ? 'Sim' : 'Não',
      avaliada ? 'Sim' : 'Não',
      totalManobras.toString(),
      mediaIndicadores.toStringAsFixed(2),
      '${desempenhoPercent.toStringAsFixed(0)}%',
    ];
  }
}

extension RelatorioOndaMapper on RelatorioOnda {
  static RelatorioOnda fromOnda(Onda onda) {
    final manobras = onda.manobrasAvaliadas;
    final indicadores = manobras.expand((m) => m.avaliacaoIndicadores).toList();

    final totalIndicadores = indicadores.length;

    double mediaIndicadores = totalIndicadores == 0
        ? 0
        : indicadores
                  .map((i) => i.classificacao.valor)
                  .reduce((a, b) => a + b) /
              totalIndicadores;

    // desempenho em %
    final desempenho = (mediaIndicadores) * 100;

    return RelatorioOnda(
      ondaId: onda.ondaId!,
      data: onda.data,
      local: onda.local?.toString() ?? '-',
      lado: onda.ladoOnda.name,
      terminouCaindo: onda.terminouCaindo,
      avaliada: onda.avaliacaoConcluida,
      totalManobras: manobras.length,
      totalIndicadores: totalIndicadores,
      mediaIndicadores: mediaIndicadores,
      desempenhoPercent: desempenho.clamp(0, 100),
      manobrasAvaliadas: onda.manobrasAvaliadas,
    );
  }
}

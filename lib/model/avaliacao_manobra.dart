import 'package:video_surf_app/model/avaliacao_indicador.dart';
import 'package:video_surf_app/model/enum/classificacao.dart';
import 'package:video_surf_app/model/enum/side.dart';
import 'package:video_surf_app/model/onda.dart';
import 'package:video_surf_app/model/tipo_acao.dart';

class AvaliacaoManobra {
  final int? avaliacaoManobraId;
  final int ondaId; // FK para Onda
  final int idTipoAcao; // FK para TipoAcao
  final Side side;
  final int tempoMs;

  // Relações opcionais
  final Onda? onda;
   TipoAcao? tipoAcao;
  List<AvaliacaoIndicador> avaliacaoIndicadores;

  AvaliacaoManobra({
    this.avaliacaoManobraId,
    required this.ondaId,
    required this.idTipoAcao,
    required this.side,
    required this.tempoMs,

    this.onda,
    this.tipoAcao,
    this.avaliacaoIndicadores = const [],
  });

  double mediaDesempenhoPercent() {
    double soma = 0.0;
    int totalIndicadores = 0;

    for (AvaliacaoIndicador indicador in avaliacaoIndicadores) {
      soma += indicador.classificacao.valor;
      totalIndicadores++;
    }

    if (totalIndicadores == 0) return 0.0;

    return (soma / totalIndicadores) * 100; // retorna em %
  }

  /// Converte milissegundos em um formato legível (ex: "1m23s", "12s500ms")
  String getTempoFormatado() {
    final duration = Duration(milliseconds: tempoMs);
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    final millis = duration.inMilliseconds % 1000;

    if (minutes > 0) {
      return "${minutes}m${seconds}s";
    } else if (seconds > 0) {
      return "${seconds}s${millis}ms";
    } else {
      return "${millis}ms";
    }
  }

  Map<String, dynamic> toMap() {
    return {
      AvaliacaoManobraFields.avaliacaoManobraId: avaliacaoManobraId,
      AvaliacaoManobraFields.side: side.nameDb,
      AvaliacaoManobraFields.tempoMs: tempoMs,
      AvaliacaoManobraFields.ondaId: ondaId,
      AvaliacaoManobraFields.tipoAcaoId: idTipoAcao,
    };
  }

  factory AvaliacaoManobra.fromMap(Map<String, dynamic> map) {
    return AvaliacaoManobra(
      avaliacaoManobraId:
          map[AvaliacaoManobraFields.avaliacaoManobraId] as int?,
      side: SideExt.fromDb(map[AvaliacaoManobraFields.side] as String),
      tempoMs: map[AvaliacaoManobraFields.tempoMs] as int,
      ondaId: map[AvaliacaoManobraFields.ondaId] as int,
      idTipoAcao: map[AvaliacaoManobraFields.tipoAcaoId] as int,

      onda: null,
      tipoAcao: null,
      avaliacaoIndicadores: [],
    );
  }
}

class AvaliacaoManobraFields {
  static const String tableName = 'avaliacao_manobra';

  static const String avaliacaoManobraId = 'avaliacao_manobra_id';
  static const String side = 'side';
  static const String tempoMs = 'tempo_ms';
  static const String idVideo = 'idVideo';
  static const String tipoAcaoId = 'tipoacao_id';
  static const String ondaId = 'ondaId';

  static const List<String> values = [
    avaliacaoManobraId,
    side,
    tempoMs,
    idVideo,
    tipoAcaoId,
    ondaId,
  ];
}

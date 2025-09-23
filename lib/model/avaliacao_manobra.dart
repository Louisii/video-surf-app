import 'package:video_surf_app/model/avaliacao_indicador.dart';
import 'package:video_surf_app/model/enum/classificacao.dart';
import 'package:video_surf_app/model/enum/lado_onda.dart';
import 'package:video_surf_app/model/enum/side.dart';
import 'package:video_surf_app/model/tipo_acao.dart';
import 'package:video_surf_app/model/video.dart';

class AvaliacaoManobra {
  final int? avaliacaoManobraId;
  final int idVideo; // FK para Video
  final int idTipoAcao; // FK para TipoAcao
  final Side side;
  final int tempoMs;
  final LadoOnda? ladoOnda;

  // Relações opcionais
  final Video? video;
  final TipoAcao? tipoAcao;
   List<AvaliacaoIndicador> avaliacaoIndicadores;

  AvaliacaoManobra({
    this.avaliacaoManobraId,
    required this.idVideo,
    required this.idTipoAcao,
    required this.side,
    required this.tempoMs,
    this.ladoOnda,
    this.video,
    this.tipoAcao,
    this.avaliacaoIndicadores = const [],
  });

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
      AvaliacaoManobraFields.idVideo: idVideo,
      AvaliacaoManobraFields.tipoAcaoId: idTipoAcao,
      AvaliacaoManobraFields.ladoOnda: ladoOnda?.nameDb,
    };
  }

  factory AvaliacaoManobra.fromMap(Map<String, dynamic> map) {
    return AvaliacaoManobra(
      avaliacaoManobraId:
          map[AvaliacaoManobraFields.avaliacaoManobraId] as int?,
      side: SideExt.fromDb(map[AvaliacaoManobraFields.side] as String),
      tempoMs: map[AvaliacaoManobraFields.tempoMs] as int,
      idVideo: map[AvaliacaoManobraFields.idVideo] as int,
      idTipoAcao: map[AvaliacaoManobraFields.tipoAcaoId] as int,
      ladoOnda: LadoOndaExt.fromDb(
        map[AvaliacaoIndicadorFields.ladoOnda] as String,
      ),

      video: null,
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
  static const String ladoOnda = 'ladoonda';

  static const List<String> values = [
    avaliacaoManobraId,
    side,
    tempoMs,
    idVideo,
    tipoAcaoId,
    ladoOnda,
  ];
}

import 'package:video_surf_app/model/acao_indicador.dart';
import 'package:video_surf_app/model/enum/lado_onda.dart';
import 'package:video_surf_app/model/enum/side.dart';
import 'package:video_surf_app/model/tipo_acao.dart';
import 'package:video_surf_app/model/video.dart';

class AcaoManobra {
  final int? acaoManobraId;
  final int idVideo; // FK para Video
  final int idTipoAcao; // FK para TipoAcao
  final Side side;
  final int tempoMs;
  final LadoOnda? ladoOnda;

  // Relações opcionais
  final Video? video;
  final TipoAcao? tipoAcao;
  final List<AcaoIndicador> indicadores;

  AcaoManobra({
    this.acaoManobraId,
    required this.idVideo,
    required this.idTipoAcao,
    required this.side,
    required this.tempoMs,
    this.ladoOnda,
    this.video,
    this.tipoAcao,
    this.indicadores = const [],
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
      AcaoManobraFields.acaoManobraId: acaoManobraId,
      AcaoManobraFields.side: side.nameDb,
      AcaoManobraFields.tempoMs: tempoMs,
      AcaoManobraFields.idVideo: idVideo,
      AcaoManobraFields.tipoAcaoId: idTipoAcao,
      AcaoManobraFields.ladoOnda: ladoOnda?.nameDb,
    };
  }

  factory AcaoManobra.fromMap(Map<String, dynamic> map) {
    return AcaoManobra(
      acaoManobraId: map[AcaoManobraFields.acaoManobraId] as int?,
      side: SideExt.fromDb(map[AcaoManobraFields.side] as String),
      tempoMs: map[AcaoManobraFields.tempoMs] as int,
      idVideo: map[AcaoManobraFields.idVideo] as int,
      idTipoAcao: map[AcaoManobraFields.tipoAcaoId] as int,
      ladoOnda: map[AcaoIndicadorFields.ladoOnda],
      video: null,
      tipoAcao: null,
      indicadores: [],
    );
  }
}

class AcaoManobraFields {
  static const String tableName = 'acaomanobra';

  static const String acaoManobraId = 'acaomanobra_id';
  static const String side = 'side';
  static const String tempoMs = 'tempo_ms';
  static const String idVideo = 'idVideo';
  static const String tipoAcaoId = 'tipoacao_id';
  static const String ladoOnda = 'ladoonda';

  static const List<String> values = [
    acaoManobraId,
    side,
    tempoMs,
    idVideo,
    tipoAcaoId,
    ladoOnda,
  ];
}

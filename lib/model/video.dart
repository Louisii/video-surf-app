import 'package:video_surf_app/model/acao_manobra.dart';
import 'package:video_surf_app/model/local.dart';
import 'package:video_surf_app/model/surfista.dart';

class Video {
  final int? videoId;
  final int idSurfista; // FK para Surfista
  final int idLocal; // FK para Local
  final DateTime data;
  final String path;

  // Relações opcionais (carregadas em JOIN ou consultas separadas)
  final Surfista? surfista;
  final Local? local;
  final List<AcaoManobra> acoes;

  Video({
    this.videoId,
    required this.idSurfista,
    required this.idLocal,
    required this.data,
    required this.path,
    this.surfista,
    this.local,
    this.acoes = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      VideoFields.videoId: videoId,
      VideoFields.data: data.toIso8601String(),
      VideoFields.path: path,
      VideoFields.surfistaId: idSurfista,
      VideoFields.localId: idLocal,
    };
  }

  factory Video.fromMap(Map<String, dynamic> map) {
    return Video(
      videoId: map[VideoFields.videoId] as int?,
      data: DateTime.parse(map[VideoFields.data] as String),
      path: map[VideoFields.path] as String,
      idSurfista: map[VideoFields.surfistaId] as int,
      idLocal: map[VideoFields.localId] as int,
      // surfista, local e acoes podem ser carregados depois
      surfista: null,
      local: null,
      acoes: [],
    );
  }
}

class VideoFields {
  static const String tableName = 'video';

  static const String videoId = 'video_id';
  static const String data = 'data';
  static const String path = 'path';
  static const String surfistaId = 'surfista_id';
  static const String localId = 'local_id';

  static const List<String> values = [videoId, data, path, surfistaId, localId];
}

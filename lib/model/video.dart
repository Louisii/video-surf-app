import 'package:flutter/foundation.dart';
import 'package:video_surf_app/model/atleta.dart';
import 'package:video_surf_app/model/local.dart';
import 'package:video_surf_app/model/onda.dart';
import 'package:video_surf_app/model/surfista.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class Video {
  final int? videoId;
  final int atletaId; // FK para Atleta
  final int localId; // FK para Local
  final DateTime data;
  final String path;

  // Relações opcionais (carregadas em JOIN ou consultas separadas)
  final Surfista? surfista;
  Local? local;
  final List<Onda> ondas;

  Video({
    this.videoId,
    required this.atletaId,
    required this.localId,
    required this.data,
    required this.path,
    this.surfista,
    this.local,
    this.ondas = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      VideoFields.videoId: videoId,
      VideoFields.data: data.toIso8601String(),
      VideoFields.path: path,
      AtletaFields.atletaId: atletaId,
      VideoFields.localId: localId,
    };
  }

  factory Video.fromMap(Map<String, dynamic> map) {
    return Video(
      videoId: map[VideoFields.videoId] as int?,
      data: DateTime.parse(map[VideoFields.data] as String),
      path: map[VideoFields.path] as String,
      atletaId: map[AtletaFields.atletaId] as int,
      localId: map[VideoFields.localId] as int,
      // surfista, local e acoes podem ser carregados depois
      surfista: null,
      local: null,
      ondas: [],
    );
  }

  Future<Uint8List?> get videoThumbnail async {
    try {
      return await VideoThumbnail.thumbnailData(
        video: path,
        imageFormat: ImageFormat.PNG,
        maxWidth: 128,
        quality: 75,
      );
    } catch (e) {
      if (kDebugMode) {
        print("Erro ao gerar thumbnail: $e");
      }
      return null;
    }
  }
}

class VideoFields {
  static const String tableName = 'video';

  static const String videoId = 'video_id';
  static const String data = 'data';
  static const String path = 'path';
  static const String localId = 'local_id';
  static const String ondaId = 'onda_id';

  static const List<String> values = [videoId, data, path, localId];
}

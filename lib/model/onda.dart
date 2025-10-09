import 'package:video_surf_app/model/avaliacao_manobra.dart';
import 'package:video_surf_app/model/enum/lado_onda.dart';
import 'package:video_surf_app/model/local.dart';
import 'package:video_surf_app/model/surfista.dart';

class Onda {
  final int? ondaId;
  final int surfistaId; // FK para Surfista
  final int localId; // FK para Local
  final int videoId; // FK para Video
  final DateTime data;
  final LadoOnda ladoOnda;
  final bool terminouCaindo;

  // Relações opcionais
  final Surfista? surfista;
  Local? local;
  final List<AvaliacaoManobra> acoes;

  Onda({
    this.ondaId,
    required this.surfistaId,
    required this.localId,
    required this.videoId,
    required this.data,
    required this.ladoOnda,
    required this.terminouCaindo,
    this.surfista,
    this.local,
    this.acoes = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      OndaFields.ondaId: ondaId,
      OndaFields.surfistaId: surfistaId,
      OndaFields.localId: localId,
      OndaFields.videoId: videoId,
      OndaFields.data: data.toIso8601String(),
      OndaFields.ladoOnda: ladoOnda.nameDb,
     OndaFields.terminouCaindo: terminouCaindo ? 1 : 0,
    };
  }

  factory Onda.fromMap(Map<String, dynamic> map) {
    return Onda(
      ondaId: map[OndaFields.ondaId] as int?,
      surfistaId: map[OndaFields.surfistaId] as int,
      localId: map[OndaFields.localId] as int,
      videoId: map[OndaFields.videoId] as int,
      data: DateTime.parse(map[OndaFields.data] as String),
      ladoOnda: LadoOndaExt.fromDb(map[OndaFields.ladoOnda] as String),
      terminouCaindo: map[OndaFields.terminouCaindo] == 1,
    );
  }
}

class OndaFields {
  static const String tableName = 'onda';

  static const String ondaId = 'onda_id';
  static const String surfistaId = 'surfista_id';
  static const String data = 'data';
  static const String localId = 'local_id';
  static const String videoId = 'video_id';
  static const String ladoOnda = 'lado_onda';
  static const String terminouCaindo = 'terminou_caindo';

  static const List<String> values = [
    ondaId,
    surfistaId,
    localId,
    videoId,
    data,
    ladoOnda,
    terminouCaindo,
  ];
}

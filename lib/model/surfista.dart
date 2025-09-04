import 'package:video_surf_app/model/enum/base_surfista.dart';
import 'package:video_surf_app/model/video.dart';

class Surfista {
  final int? surfistaId;
  final String cpf;
  final String nome;
  final DateTime dataNascimento;
  final BaseSurfista base;
  final List<Video> videos;

  Surfista({
    this.surfistaId,
    required this.cpf,
    required this.nome,
    required this.dataNascimento,
    required this.base,
    this.videos = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      SurfistaFields.surfistaId: surfistaId,
      SurfistaFields.cpf: cpf,
      SurfistaFields.nome: nome,
      SurfistaFields.dataNascimento: dataNascimento.toIso8601String(),
      SurfistaFields.base: base.nameDb,
    };
  }

  factory Surfista.fromMap(Map<String, dynamic> map) {
    return Surfista(
      surfistaId: map[SurfistaFields.surfistaId] as int?,
      cpf: map[SurfistaFields.cpf] as String,
      nome: map[SurfistaFields.nome] as String,
      dataNascimento: DateTime.parse(
        map[SurfistaFields.dataNascimento] as String,
      ),
      base: BaseSurfistaExt.fromDb(map[SurfistaFields.base] as String),
      // videos normalmente vem de outra tabela, então inicializamos vazio aqui
      videos: [],
    );
  }
}

class SurfistaFields {
  static const String tableName = 'surfista';

  static const String surfistaId = 'surfista_id';
  static const String cpf = 'cpf';
  static const String nome = 'nome';
  static const String dataNascimento = 'data_nascimento';
  static const String base = 'base';

  static const List<String> values = [
    surfistaId,
    cpf,
    nome,
    dataNascimento,
    base,
  ];
}

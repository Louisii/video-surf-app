import 'package:video_surf_app/exceptions/surfista_csv_exceptions.dart';
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

  String get dataNascimentoFormatada {
    final day = dataNascimento.day.toString().padLeft(2, '0');
    final month = dataNascimento.month.toString().padLeft(2, '0');
    final year = dataNascimento.year.toString();
    return '$day/$month/$year';
  }

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

  factory Surfista.fromCSV(List<String> row) {
    if (row.length < 4) {
      throw SurfistaCsvException("Número de colunas insuficiente no CSV.");
    }

    final cpf = row[0].trim();
    final nome = row[1].trim();
    final dataStr = row[2].trim();
    final baseStr = row[3].trim();

    if (cpf.isEmpty) throw CampoAusenteException("cpf");
    if (nome.isEmpty) throw CampoAusenteException("nome");
    if (dataStr.isEmpty) throw CampoAusenteException("dataNascimento");
    if (baseStr.isEmpty) throw CampoAusenteException("base");

    DateTime dataNascimento;
    try {
      dataNascimento = DateTime.parse(dataStr);
    } catch (_) {
      throw DataInvalidaException(dataStr);
    }

    BaseSurfista base;
    try {
      base = BaseSurfistaExt.fromDb(baseStr); 
    } catch (_) {
      throw SurfistaCsvException("BaseSurfista inválida: $baseStr");
    }

    return Surfista(
      cpf: cpf,
      nome: nome,
      dataNascimento: dataNascimento,
      base: base,
    );
  }

  Surfista copyWith({
    int? surfistaId,
    String? cpf,
    String? nome,
    DateTime? dataNascimento,
    BaseSurfista? base,
    List<Video>? videos,
  }) {
    return Surfista(
      surfistaId: surfistaId ?? this.surfistaId,
      cpf: cpf ?? this.cpf,
      nome: nome ?? this.nome,
      dataNascimento: dataNascimento ?? this.dataNascimento,
      base: base ?? this.base,
      videos: videos ?? this.videos,
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

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:video_surf_app/dao/video_dao.dart';
import 'package:video_surf_app/exceptions/surfista_csv_exceptions.dart';
import 'package:video_surf_app/model/enum/base_surfista.dart';
import 'package:video_surf_app/model/onda.dart';
import 'package:video_surf_app/model/video.dart';
import 'package:video_surf_app/model/atleta.dart';

class Surfista extends Atleta {
  final int? surfistaId;
  final BaseSurfista base;
  final List<Video> videos;
  final List<Onda> ondas;

  Surfista({
    this.surfistaId,
    required this.base,
    this.videos = const [],
    this.ondas = const [],
    required super.cpf,
    required super.nome,
    required super.dataNascimento,
    required super.modalidade,
    super.atletaId,
  });

  Widget iconeSurfista(Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 3),
      ),
      child: Icon(Icons.surfing, size: 30, color: color),
    );
  }

  Future<int> get nVideosDb async {
    if (surfistaId == null) return 0;
    final videoDao = VideoDao();
    return await videoDao.countBySurfistaId(surfistaId!);
  }

  Future<int> get nOndasDb async {
    if (surfistaId == null) return 0;
    // final videoDao = VideoDao(); TODO
    // return await videoDao.countBySurfistaId(surfistaId!);
    return 0;
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      ...super.toMap(), // dados da tabela atleta
      SurfistaFields.surfistaId: surfistaId,
      SurfistaFields.base: base.nameDb,
    };
  }

  factory Surfista.fromMap(Map<String, dynamic> map) {
    return Surfista(
      surfistaId: map[SurfistaFields.surfistaId] as int?,
      base: BaseSurfistaExt.fromDb(map[SurfistaFields.base] as String),
      cpf: map[AtletaFields.cpf] as String,
      nome: map[AtletaFields.nome] as String,
      dataNascimento: DateTime.parse(
        map[AtletaFields.dataNascimento] as String,
      ),
      atletaId: map[AtletaFields.atletaId] as int?,
      modalidade: map[AtletaFields.modalidade] as String,
    );
  }

  Map<String, dynamic> toAtletaMap() {
    return super.toMap();
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
      throw SurfistaCsvException('BaseSurfista inválida: $baseStr');
    }

    return Surfista(
      cpf: cpf,
      nome: nome,
      dataNascimento: dataNascimento,
      modalidade: "surf",
      base: base,
    );
  }
}

class SurfistaFields {
  static const String tableName = 'surfista';

  static const String surfistaId = 'surfista_id';
  static const String atletaId = 'atleta_id';
  static const String base = 'base';

  static const List<String> values = [surfistaId, atletaId, base];
}

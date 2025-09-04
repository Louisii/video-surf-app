import 'package:video_surf_app/model/acao_manobra.dart';
import 'package:video_surf_app/model/enum/classificacao.dart';
import 'package:video_surf_app/model/indicador.dart';

class AcaoIndicador {
  final int? acaoIndicadorId;
  final int idAcaoManobra; // FK para AcaoManobra
  final int idIndicador;    // FK para Indicador
  final Classificacao classificacao;

  // Relações opcionais
  final AcaoManobra? acao;
  final Indicador? indicador;

  AcaoIndicador({
    this.acaoIndicadorId,
    required this.idAcaoManobra,
    required this.idIndicador,
    required this.classificacao,
    this.acao,
    this.indicador,
  });

  Map<String, dynamic> toMap() {
    return {
      AcaoIndicadorFields.acaoIndicadorId: acaoIndicadorId,
      AcaoIndicadorFields.idAcaoManobra: idAcaoManobra,
      AcaoIndicadorFields.idIndicador: idIndicador,
      AcaoIndicadorFields.classificacao: classificacao.nameDb,
    };
  }

  factory AcaoIndicador.fromMap(Map<String, dynamic> map) {
    return AcaoIndicador(
      acaoIndicadorId: map[AcaoIndicadorFields.acaoIndicadorId] as int?,
      idAcaoManobra: map[AcaoIndicadorFields.idAcaoManobra] as int,
      idIndicador: map[AcaoIndicadorFields.idIndicador] as int,
      classificacao: ClassificacaoExt.fromDb(map[AcaoIndicadorFields.classificacao] as String),
      acao: null,
      indicador: null,
    );
  }
}

class AcaoIndicadorFields {
  static const String tableName = 'acaopindicador';

  static const String acaoIndicadorId = 'acaoindicador_id';
  static const String idAcaoManobra = 'idAcaoManobra';
  static const String idIndicador = 'idIndicador';
  static const String classificacao = 'classificacao';

  static const List<String> values = [
    acaoIndicadorId,
    idAcaoManobra,
    idIndicador,
    classificacao,
  ];
}

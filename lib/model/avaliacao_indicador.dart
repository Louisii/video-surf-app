import 'package:video_surf_app/model/avaliacao_manobra.dart';
import 'package:video_surf_app/model/enum/classificacao.dart';
import 'package:video_surf_app/model/indicador.dart';

class avaliacaoIndicador {
  final int? acaoIndicadorId;
  final int idAcaoManobra; // FK para AcaoManobra
  final int idIndicador; // FK para Indicador
  final Classificacao classificacao;

  // Relações opcionais
  final AvaliacaoManobra? acao;
  final Indicador? indicador;

  avaliacaoIndicador({
    this.acaoIndicadorId,
    required this.idAcaoManobra,
    required this.idIndicador,
    required this.classificacao,
    this.acao,
    this.indicador,
  });

  Map<String, dynamic> toMap() {
    return {
      AvaliacaoIndicadorFields.acaoIndicadorId: acaoIndicadorId,
      AvaliacaoIndicadorFields.idAcaoManobra: idAcaoManobra,
      AvaliacaoIndicadorFields.idIndicador: idIndicador,
      AvaliacaoIndicadorFields.classificacao: classificacao.nameDb,
    };
  }

  factory avaliacaoIndicador.fromMap(Map<String, dynamic> map) {
    return avaliacaoIndicador(
      acaoIndicadorId: map[AvaliacaoIndicadorFields.acaoIndicadorId] as int?,
      idAcaoManobra: map[AvaliacaoIndicadorFields.idAcaoManobra] as int,
      idIndicador: map[AvaliacaoIndicadorFields.idIndicador] as int,
      classificacao: ClassificacaoExt.fromDb(
        map[AvaliacaoIndicadorFields.classificacao] as String,
      ),
      acao: null,
      indicador: null,
    );
  }
}

class AvaliacaoIndicadorFields {
  static const String tableName = 'avaliacaoindicador';

  static const String acaoIndicadorId = 'acaoindicador_id';
  static const String idAcaoManobra = 'idAcaoManobra';
  static const String idIndicador = 'idIndicador';
  static const String classificacao = 'classificacao';
  static const String ladoOnda = 'ladoonda';

  static const List<String> values = [
    acaoIndicadorId,
    idAcaoManobra,
    idIndicador,
    classificacao,
    ladoOnda,
  ];
}

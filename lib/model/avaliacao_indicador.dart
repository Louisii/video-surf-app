import 'package:video_surf_app/model/avaliacao_manobra.dart';
import 'package:video_surf_app/model/indicador.dart';
import 'package:video_surf_app/model/enum/classificacao.dart';

class AvaliacaoIndicador {
  final int? avaliacaoIndicadorId;
  int? idAvaliacaoManobra; // FK para AvaliacaoManobra
  final int idIndicador; // FK para Indicador
  Classificacao classificacao;

  // Relações opcionais
  final AvaliacaoManobra? acao;
   Indicador? indicador;

  AvaliacaoIndicador({
    this.avaliacaoIndicadorId,
    this.idAvaliacaoManobra,
    required this.idIndicador,
    required this.classificacao,
    this.acao,
    this.indicador,
  });

  Map<String, dynamic> toMap() {
    return {
      AvaliacaoIndicadorFields.acaoIndicadorId: avaliacaoIndicadorId,
      AvaliacaoIndicadorFields.idAvaliacaoManobra: idAvaliacaoManobra,
      AvaliacaoIndicadorFields.idIndicador: idIndicador,
      AvaliacaoIndicadorFields.classificacao: classificacao.nameDb,
    };
  }

  factory AvaliacaoIndicador.fromMap(Map<String, dynamic> map) {
    return AvaliacaoIndicador(
      avaliacaoIndicadorId:
          map[AvaliacaoIndicadorFields.acaoIndicadorId] as int?,
      idAvaliacaoManobra:
          map[AvaliacaoIndicadorFields.idAvaliacaoManobra] as int,
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
  static const String idAvaliacaoManobra = 'idAvaliacaoManobra';
  static const String idIndicador = 'idIndicador';
  static const String classificacao = 'classificacao';
  static const String ladoOnda = 'ladoonda';

  static const List<String> values = [
    acaoIndicadorId,
    idAvaliacaoManobra,
    idIndicador,
    classificacao,
    ladoOnda,
  ];
}

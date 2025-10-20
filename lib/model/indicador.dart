import 'package:video_surf_app/model/tipo_acao.dart';

class Indicador {
  final int? indicadorId;
  final String descricao;
  final int idTipoAcao; // FK para TipoAcao
  final int ordemItem;
  // Relação opcional
  final TipoAcao? tipoAcao;

  Indicador({
    this.indicadorId,
    required this.descricao,
    required this.idTipoAcao,
    required this.ordemItem,
    this.tipoAcao,
  });

  Map<String, dynamic> toMap() {
    return {
      IndicadorFields.indicadorId: indicadorId,
      IndicadorFields.descricao: descricao,
      IndicadorFields.idTipoAcao: idTipoAcao,
      IndicadorFields.ordemItem: ordemItem,
    };
  }

  factory Indicador.fromMap(Map<String, dynamic> map) {
    return Indicador(
      indicadorId: map[IndicadorFields.indicadorId] as int?,
      descricao: map[IndicadorFields.descricao] as String,
      idTipoAcao: map[IndicadorFields.idTipoAcao] as int,
      ordemItem: map[IndicadorFields.ordemItem] as int,
      tipoAcao: null,
    );
  }
}

class IndicadorFields {
  static const String tableName = 'indicador';

  static const String indicadorId = 'indicador_id';
  static const String descricao = 'descricao';
  static const String idTipoAcao = 'idTipoAcao';
  static const String ordemItem = 'ordemItem';

  static const List<String> values = [
    indicadorId,
    descricao,
    idTipoAcao,
    ordemItem,
  ];
}

class TipoAcao {
  final int? tipoAcaoId;
  final String nome;
  final String nivel;

  TipoAcao({this.tipoAcaoId, required this.nome, required this.nivel});

  Map<String, dynamic> toMap() {
    return {
      TipoAcaoFields.tipoAcaoId: tipoAcaoId,
      TipoAcaoFields.nome: nome,
      TipoAcaoFields.nivel: nivel,
    };
  }

  factory TipoAcao.fromMap(Map<String, dynamic> map) {
    return TipoAcao(
      tipoAcaoId: map[TipoAcaoFields.tipoAcaoId] as int?,
      nome: map[TipoAcaoFields.nome] as String,
      nivel: map[TipoAcaoFields.nivel] as String,
    );
  }
}

class TipoAcaoFields {
  static const String tableName = 'tipoacao';

  static const String tipoAcaoId = 'tipoAcao_id';
  static const String nome = 'nome';
  static const String nivel = 'nivel';

  static const List<String> values = [tipoAcaoId, nome, nivel];
}

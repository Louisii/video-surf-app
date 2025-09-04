class TipoAcao {
  final int? tipoAcaoId;
  final String nome;

  TipoAcao({
    this.tipoAcaoId,
    required this.nome,
  });

  Map<String, dynamic> toMap() {
    return {
      TipoAcaoFields.tipoAcaoId: tipoAcaoId,
      TipoAcaoFields.nome: nome,
    };
  }

  factory TipoAcao.fromMap(Map<String, dynamic> map) {
    return TipoAcao(
      tipoAcaoId: map[TipoAcaoFields.tipoAcaoId] as int?,
      nome: map[TipoAcaoFields.nome] as String,
    );
  }
}

class TipoAcaoFields {
  static const String tableName = 'tipoacao';

  static const String tipoAcaoId = 'tipoAcao_id';
  static const String nome = 'nome';

  static const List<String> values = [
    tipoAcaoId,
    nome,
  ];
}

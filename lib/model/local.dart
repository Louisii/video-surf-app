class Local {
  final int? localId;
  final String pais;
  final String cidade;
  final String praia;
  final String pico;

  Local({
    this.localId,
    required this.pais,
    required this.cidade,
    required this.praia,
    required this.pico,
  });

  Map<String, dynamic> toMap() {
    return {
      LocalFields.localId: localId,
      LocalFields.pais: pais,
      LocalFields.cidade: cidade,
      LocalFields.praia: praia,
      LocalFields.pico: pico,
    };
  }

  factory Local.fromMap(Map<String, dynamic> map) {
    return Local(
      localId: map[LocalFields.localId] as int?,
      pais: map[LocalFields.pais] as String,
      cidade: map[LocalFields.cidade] as String,
      praia: map[LocalFields.praia] as String,
      pico: map[LocalFields.pico] as String,
    );
  }

  //TODO: fromCSV
  //TODO: copyWith
}

class LocalFields {
  static const String tableName = 'local';

  static const String localId = 'local_id';
  static const String pais = 'pais';
  static const String cidade = 'cidade';
  static const String praia = 'praia';
  static const String pico = 'pico';

  static const List<String> values = [
    localId,
    pais,
    cidade,
    praia,
    pico,
  ];
}

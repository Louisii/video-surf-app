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

  // Copia um Local alterando os campos opcionais
  Local copyWith({
    int? localId,
    String? pais,
    String? cidade,
    String? praia,
    String? pico,
  }) {
    return Local(
      localId: localId ?? this.localId,
      pais: pais ?? this.pais,
      cidade: cidade ?? this.cidade,
      praia: praia ?? this.praia,
      pico: pico ?? this.pico,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Local &&
          runtimeType == other.runtimeType &&
          localId == other.localId;

  @override
  int get hashCode => localId.hashCode;

  @override
  String toString() {
    return "$praia - $pico";
  }
}

// Extensão separada para CSV
extension LocalCSV on Local {
  static Local fromCSV(List<String> row) {
    if (row.length < 4) {
      throw Exception('Número de colunas insuficiente no CSV.');
    }

    final pais = row[0].trim();
    final cidade = row[1].trim();
    final praia = row[2].trim();
    final pico = row[3].trim();

    if (pais.isEmpty) throw Exception('Campo "pais" ausente');
    if (cidade.isEmpty) throw Exception('Campo "cidade" ausente');
    if (praia.isEmpty) throw Exception('Campo "praia" ausente');
    if (pico.isEmpty) throw Exception('Campo "pico" ausente');

    return Local(pais: pais, cidade: cidade, praia: praia, pico: pico);
  }
}

class LocalFields {
  static const String tableName = 'local';

  static const String localId = 'local_id';
  static const String pais = 'pais';
  static const String cidade = 'cidade';
  static const String praia = 'praia';
  static const String pico = 'pico';

  static const List<String> values = [localId, pais, cidade, praia, pico];
}

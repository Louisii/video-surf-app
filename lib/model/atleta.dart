
class Atleta {
  final int? atletaId;
  final String cpf;
  final String nome;
  final DateTime dataNascimento;
  final String modalidade;

  Atleta({
    this.atletaId,
    required this.cpf,
    required this.nome,
    required this.dataNascimento,
    required this.modalidade,
  });

  String get dataNascimentoFormatada {
    final day = dataNascimento.day.toString().padLeft(2, '0');
    final month = dataNascimento.month.toString().padLeft(2, '0');
    final year = dataNascimento.year.toString();
    return '$day/$month/$year';
  }

  String get idade {
    final hoje = DateTime.now();
    int anos = hoje.year - dataNascimento.year;
    if (hoje.month < dataNascimento.month ||
        (hoje.month == dataNascimento.month && hoje.day < dataNascimento.day)) {
      anos--;
    }
    return '$anos anos';
  }

  Map<String, dynamic> toMap() {
    return {
      AtletaFields.atletaId: atletaId,
      AtletaFields.cpf: cpf,
      AtletaFields.nome: nome,
      AtletaFields.dataNascimento: dataNascimento.toIso8601String(),
      AtletaFields.modalidade: modalidade,
    };
  }

  factory Atleta.fromMap(Map<String, dynamic> map) {
    return Atleta(
      atletaId: map[AtletaFields.atletaId] as int?,
      cpf: map[AtletaFields.cpf] as String,
      nome: map[AtletaFields.nome] as String,
      dataNascimento: DateTime.parse(map[AtletaFields.dataNascimento] as String),
      modalidade: map[AtletaFields.modalidade] as String,
    );
  }

  Atleta copyWith({
    int? atletaId,
    String? cpf,
    String? nome,
    DateTime? dataNascimento,
    String? modalidade,
  }) {
    return Atleta(
      atletaId: atletaId ?? this.atletaId,
      cpf: cpf ?? this.cpf,
      nome: nome ?? this.nome,
      dataNascimento: dataNascimento ?? this.dataNascimento,
      modalidade: modalidade ?? this.modalidade,
    );
  }
}

class AtletaFields {
  static const String tableName = 'atleta';

  static const String atletaId = 'atleta_id';
  static const String cpf = 'cpf';
  static const String nome = 'nome';
  static const String dataNascimento = 'data_nascimento';
  static const String modalidade = 'modalidade';

  static const List<String> values = [
    atletaId,
    cpf,
    nome,
    dataNascimento,
    modalidade,
  ];
}

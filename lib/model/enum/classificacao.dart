enum Classificacao { naoRealizado, imperfeito, quasePerfeito, perfeito }

extension ClassificacaoExt on Classificacao {
  /// Retorna a string que será armazenada no banco
  String get nameDb {
    switch (this) {
      case Classificacao.naoRealizado:
        return 'naoRealizado';
      case Classificacao.imperfeito:
        return 'imperfeito';
      case Classificacao.quasePerfeito:
        return 'quasePerfeito';
      case Classificacao.perfeito:
        return 'perfeito';
    }
  }

  /// Converte string do banco para enum
  static Classificacao fromDb(String value) {
    switch (value) {
      case 'naoRealizado':
        return Classificacao.naoRealizado;
      case 'imperfeito':
        return Classificacao.imperfeito;
      case 'quasePerfeito':
        return Classificacao.quasePerfeito;
      case 'perfeito':
        return Classificacao.perfeito;
      default:
        return Classificacao.naoRealizado; // default seguro
    }
  }

  String get label {
    switch (this) {
      case Classificacao.naoRealizado:
        return 'Não Realizado';
      case Classificacao.imperfeito:
        return 'Imperfeito';
      case Classificacao.quasePerfeito:
        return 'Quase Perfeito';
      case Classificacao.perfeito:
        return 'Perfeito';
    }
  }

  int get stars {
    switch (this) {
      case Classificacao.naoRealizado:
        return 1;
      case Classificacao.imperfeito:
        return 2;
      case Classificacao.quasePerfeito:
        return 3;
      case Classificacao.perfeito:
        return 4;
    }
  }
}

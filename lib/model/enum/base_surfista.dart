enum BaseSurfista { regular, goofy }

extension BaseSurfistaExt on BaseSurfista {
  /// Retorna a string que será armazenada no banco
  String get nameDb {
    switch (this) {
      case BaseSurfista.regular:
        return 'regular';
      case BaseSurfista.goofy:
        return 'goofy';
    }
  }

  /// Converte string do banco para enum (aceita maiúsculas/minúsculas)
  static BaseSurfista fromDb(String value) {
    final normalized = value.trim().toLowerCase();
    switch (normalized) {
      case 'regular':
        return BaseSurfista.regular;
      case 'goofy':
        return BaseSurfista.goofy;
      default:
        return BaseSurfista.regular; // fallback seguro
    }
  }
}

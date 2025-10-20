enum Side { frontside, backside, desconhecido }

extension SideExt on Side {
  String get nameDb {
    switch (this) {
      case Side.frontside:
        return 'frontside';
      case Side.backside:
        return 'backside';
      case Side.desconhecido:
        return 'desconhecido';
    }
  }

  static Side fromDb(String value) {
    switch (value) {
      case 'frontside':
        return Side.frontside;
      case 'backside':
        return Side.backside;
      default:
        return Side.desconhecido;
    }
  }

  /// 🔹 Novo método: aceita "FS", "BS", "frontside", "backside", "indefinido"
  static Side findSide(String? value) {
    if (value == null) return Side.desconhecido;

    final cleaned = value
        .trim()
        .toUpperCase()
        .replaceAll('\r', '')
        .replaceAll('"', '');

    switch (cleaned) {
      case 'FS':
      case 'FRONTSIDE':
        return Side.frontside;

      case 'BS':
      case 'BACKSIDE':
        return Side.backside;

      case 'INDEFINIDO':
      case 'DESCONHECIDO':
        return Side.desconhecido;

      default:
        return Side.desconhecido;
    }
  }
}

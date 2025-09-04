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
}

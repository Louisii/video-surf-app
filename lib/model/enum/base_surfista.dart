import 'package:video_surf_app/exceptions/surfista_csv_exceptions.dart';

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

  static BaseSurfista fromDb(String value) {
    switch (value.toLowerCase()) {
      case 'regular':
        return BaseSurfista.regular;
      case 'goofy':
        return BaseSurfista.goofy;
      default:
        throw SurfistaCsvException('BaseSurfista inválida: $value');
    }
  }
}

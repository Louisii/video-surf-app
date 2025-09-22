import 'package:video_surf_app/exceptions/acao_manobra_exceptions.dart';

enum LadoOnda { direita, esquerda }

extension LadoOndaExt on LadoOnda {
  /// Retorna a string que será armazenada no banco
  String get nameDb {
    switch (this) {
      case LadoOnda.direita:
        return 'Direita';
      case LadoOnda.esquerda:
        return 'Esquerda';
    }
  }

  static LadoOnda fromDb(String value) {
    switch (value.toLowerCase()) {
      case 'direita':
        return LadoOnda.direita;
      case 'esquerda':
        return LadoOnda.esquerda;
      default:
        throw AcaoManobraException('LadoOnda inválida: $value');
    }
  }
}

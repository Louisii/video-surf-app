import 'package:flutter_test/flutter_test.dart';
import 'package:video_surf_app/exceptions/surfista_csv_exceptions.dart';
import 'package:video_surf_app/model/surfista.dart';
import 'package:video_surf_app/model/enum/base_surfista.dart';

void main() {
  group('Surfista.fromCSV', () {
    test('Deve criar Surfista válido a partir de linha CSV correta', () {
      final row = ['12345678900', 'João da Silva', '1995-06-20', 'regular'];

      final surfista = Surfista.fromCSV(row);

      expect(surfista.cpf, '12345678900');
      expect(surfista.nome, 'João da Silva');
      expect(surfista.dataNascimento, DateTime(1995, 6, 20));
      expect(surfista.base, BaseSurfista.regular);
    });

    test('Deve aceitar base em maiúsculas ou minúsculas', () {
      final rowUpper = ['98765432100', 'Maria Souza', '2000-01-15', 'GOOFY'];
      final rowLower = ['11122233344', 'Pedro Santos', '1998-03-10', 'goofy'];

      final surfista1 = Surfista.fromCSV(rowUpper);
      final surfista2 = Surfista.fromCSV(rowLower);

      expect(surfista1.base, equals(BaseSurfista.goofy));
      expect(surfista2.base, equals(BaseSurfista.goofy));
    });

    test(
      'Deve lançar SurfistaCsvException para linha CSV inválida (faltando colunas)',
      () {
        final rowIncompleta = ['12345678900', 'Fulano']; // faltam colunas

        expect(
          () => Surfista.fromCSV(rowIncompleta),
          throwsA(isA<SurfistaCsvException>()),
        );
      },
    );

    test('Deve lançar DataInvalidaException para data inválida', () {
      final rowDataInvalida = [
        '12345678900',
        'Fulano de Tal',
        'data-errada',
        'regular',
      ];

      expect(
        () => Surfista.fromCSV(rowDataInvalida),
        throwsA(isA<DataInvalidaException>()),
      );
    });

    test('Deve lançar CampoAusenteException se CPF estiver vazio', () {
      final csvLine = ['', 'Nome', '2000-01-01', 'regular'];
      expect(
        () => Surfista.fromCSV(csvLine),
        throwsA(isA<CampoAusenteException>()),
      );
    });

    test('Deve lançar DataInvalidaException para data inválida', () {
      final csvLine = ['12345678900', 'Nome', 'data-errada', 'regular'];
      expect(
        () => Surfista.fromCSV(csvLine),
        throwsA(isA<DataInvalidaException>()),
      );
    });

    test('Deve lançar SurfistaCsvException para base inválida', () {
      final csvLine = ['12345678900', 'Nome', '2000-01-01', 'alien'];
      expect(
        () => Surfista.fromCSV(csvLine),
        throwsA(isA<SurfistaCsvException>()),
      );
    });

    test('Deve lançar SurfistaCsvException para colunas insuficientes', () {
      final csvLine = ['12345678900', 'Nome'];
      expect(
        () => Surfista.fromCSV(csvLine),
        throwsA(isA<SurfistaCsvException>()),
      );
    });
  });
}

import 'package:video_surf_app/dao/db.dart';
import 'package:video_surf_app/model/avaliacao_indicador.dart';
import 'package:video_surf_app/model/avaliacao_manobra.dart';
import 'package:video_surf_app/model/local.dart';
import 'package:video_surf_app/model/onda.dart';
import 'package:video_surf_app/model/relatorio_onda.dart';

class RelatorioSurfistaDto {
  Future<List<RelatorioOnda>> getRelatorioSurfista(int surfistaId) async {
    final db = await DB.instance.database;

    final ondasMaps = await db!.query(
      OndaFields.tableName,
      where: '${OndaFields.surfistaId} = ?',
      whereArgs: [surfistaId],
    );

    List<RelatorioOnda> relatorio = [];

    for (var m in ondasMaps) {
      Onda onda = Onda.fromMap(m);

      // Local
      final localMaps = await db.query(
        LocalFields.tableName,
        where: '${LocalFields.localId} = ?',
        whereArgs: [onda.localId],
      );
      if (localMaps.isNotEmpty) {
        onda.local = Local.fromMap(localMaps.first);
      }

      // Manobras
      final avaliacoesMaps = await db.query(
        AvaliacaoManobraFields.tableName,
        where: 'ondaId = ?',
        whereArgs: [onda.ondaId],
      );

      List<AvaliacaoManobra> manobras = [];
      for (var aMap in avaliacoesMaps) {
        AvaliacaoManobra manobra = AvaliacaoManobra.fromMap(aMap);

        final indicadoresMaps = await db.query(
          AvaliacaoIndicadorFields.tableName,
          where: '${AvaliacaoIndicadorFields.idAvaliacaoManobra} = ?',
          whereArgs: [manobra.avaliacaoManobraId],
        );

        manobra.avaliacaoIndicadores = indicadoresMaps
            .map((iMap) => AvaliacaoIndicador.fromMap(iMap))
            .toList();

        manobras.add(manobra);
      }

      onda.manobrasAvaliadas = manobras;

      relatorio.add(RelatorioOndaMapper.fromOnda(onda));
    }

    return relatorio;
  }
}

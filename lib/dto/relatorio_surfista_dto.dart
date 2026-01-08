import 'package:video_surf_app/dao/db.dart';
import 'package:video_surf_app/model/avaliacao_indicador.dart';
import 'package:video_surf_app/model/avaliacao_manobra.dart';
import 'package:video_surf_app/model/enum/classificacao.dart';
import 'package:video_surf_app/model/indicador.dart';
import 'package:video_surf_app/model/local.dart';
import 'package:video_surf_app/model/onda.dart';
import 'package:video_surf_app/model/relatorio_onda.dart';
import 'package:video_surf_app/model/tipo_acao.dart';

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
      final onda = Onda.fromMap(m);

      // 🔹 Local
      final localMaps = await db.query(
        LocalFields.tableName,
        where: '${LocalFields.localId} = ?',
        whereArgs: [onda.localId],
      );
      if (localMaps.isNotEmpty) {
        onda.local = Local.fromMap(localMaps.first);
      }

      // 🔹 Manobras (AvaliacaoManobra + TipoAcao)
      final manobrasMaps = await db.rawQuery(
        '''
        SELECT am.*,
               ta.${TipoAcaoFields.nome} AS tipoAcaoNome
        FROM ${AvaliacaoManobraFields.tableName} am
        JOIN ${TipoAcaoFields.tableName} ta
          ON ta.${TipoAcaoFields.tipoAcaoId} =
             am.${AvaliacaoManobraFields.tipoAcaoId}
        WHERE am.${AvaliacaoManobraFields.ondaId} = ?
      ''',
        [onda.ondaId],
      );

      List<AvaliacaoManobra> manobras = [];

      for (var mm in manobrasMaps) {
        final manobra = AvaliacaoManobra.fromMap(mm);

        // popula o TipoAcao no model (opcional, mas útil)
        manobra.tipoAcao = TipoAcao(
          side: manobra.side,
          tipoAcaoId: manobra.idTipoAcao,
          nome: mm['tipoAcaoNome'] as String,
        );

        // 🔹 Indicadores (AvaliacaoIndicador + Indicador)
        final indicadoresMaps = await db.rawQuery(
          '''
          SELECT ai.*,
                 i.${IndicadorFields.descricao} AS indicadorNome
          FROM ${AvaliacaoIndicadorFields.tableName} ai
          JOIN ${IndicadorFields.tableName} i
            ON i.${IndicadorFields.indicadorId} =
               ai.${AvaliacaoIndicadorFields.acaoIndicadorId}
          WHERE ai.${AvaliacaoIndicadorFields.idAvaliacaoManobra} = ?
        ''',
          [manobra.avaliacaoManobraId],
        );

        manobra.avaliacaoIndicadores = indicadoresMaps.map((iMap) {
          final indicadorAvaliado = AvaliacaoIndicador.fromMap(iMap);

          // 🔹 associa o indicador com a descrição
          indicadorAvaliado.indicador = Indicador(
            ordemItem: 0,
            idTipoAcao: iMap[AvaliacaoIndicadorFields.acaoIndicadorId] as int,
            indicadorId: iMap[AvaliacaoIndicadorFields.acaoIndicadorId] as int,
            descricao: iMap['indicadorNome'] as String,
          );

          return indicadorAvaliado;
        }).toList();

        manobras.add(manobra);
      }

      onda.manobrasAvaliadas = manobras;

      relatorio.add(RelatorioOndaMapper.fromOnda(onda));
    }

    return relatorio;
  }
}

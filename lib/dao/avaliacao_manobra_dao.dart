import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:video_surf_app/dao/avaliacao_indicador_dao.dart';
import 'package:video_surf_app/dao/db.dart';
import 'package:video_surf_app/model/avaliacao_indicador.dart';
import 'package:video_surf_app/model/avaliacao_manobra.dart';

class AvaliacaoManobraDao {
  AvaliacaoManobraDao();

  Future<int> insert(AvaliacaoManobra avaliacao) async {
    final db = await DB.instance.database;
    return await db!.insert(
      AvaliacaoManobraFields.tableName,
      avaliacao.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<AvaliacaoManobra?> getById(int id) async {
    final db = await DB.instance.database;
    final maps = await db!.query(
      AvaliacaoManobraFields.tableName,
      where: '${AvaliacaoManobraFields.avaliacaoManobraId} = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return AvaliacaoManobra.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<List<AvaliacaoManobra>> findByVideo(int idVideo) async {
    final db = await DB.instance.database;
    final manobrasMaps = await db!.query(
      AvaliacaoManobraFields.tableName,
      where: '${AvaliacaoManobraFields.idVideo} = ?',
      whereArgs: [idVideo],
    );

    List<AvaliacaoManobra> manobras = [];

    for (var m in manobrasMaps) {
      AvaliacaoManobra avaliacaoManobra = AvaliacaoManobra.fromMap(m);

      // agora buscamos os indicadores relacionados a esta manobra
      final indicadoresMaps = await db.query(
        AvaliacaoIndicadorFields.tableName,
        where: '${AvaliacaoIndicadorFields.idAvaliacaoManobra} = ?',
        whereArgs: [avaliacaoManobra.avaliacaoManobraId],
      );

      avaliacaoManobra.avaliacaoIndicadores = indicadoresMaps.map((i) {
        return AvaliacaoIndicador.fromMap(i);
      }).toList();

      manobras.add(avaliacaoManobra);
    }

    return manobras;
  }

  Future<int> createManobra(AvaliacaoManobra manobraAvaliada) async {
    try {
      final db = await DB.instance.database;

      // Salva manobra
      int manobraId = await db!.insert(
        AvaliacaoManobraFields.tableName,
        manobraAvaliada.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      // Salva indicadores avaliados
      if (manobraAvaliada.avaliacaoIndicadores.isNotEmpty) {
        AvaliacaoIndicadorDao avaliacaoIndicadorDao = AvaliacaoIndicadorDao();
        for (AvaliacaoIndicador indicador
            in manobraAvaliada.avaliacaoIndicadores) {
          indicador.idAvaliacaoManobra = manobraId; // garantir FK
          await avaliacaoIndicadorDao.createIndicadorAvaliado(indicador);
        }
      }

      return manobraId;
    } on Exception catch (e) {
      if (kDebugMode) {
        print('Erro ao inserir manobra avaliado: $e');
      }
      rethrow; // repassa o erro para o chamador
    }
  }
}

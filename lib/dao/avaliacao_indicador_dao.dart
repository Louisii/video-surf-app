import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:video_surf_app/dao/db.dart';
import 'package:video_surf_app/model/avaliacao_indicador.dart';

class AvaliacaoIndicadorDao {
  AvaliacaoIndicadorDao();

  Future<int> createIndicadorAvaliado(AvaliacaoIndicador avaliacao) async {
    final db = await DB.instance.database;
    try {
      return await db!.insert(
        AvaliacaoIndicadorFields.tableName,
        avaliacao.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } on Exception catch (e) {
      if (kDebugMode) {
        print('Erro ao inserir indicador avaliado: $e');
      }
      rethrow; 
    }
  }

  Future<List<AvaliacaoIndicador>> getByAvaliacaoManobraId(
    int idAvaliacaoManobra,
  ) async {
    final db = await DB.instance.database;
    final maps = await db!.query(
      AvaliacaoIndicadorFields.tableName,
      where: '${AvaliacaoIndicadorFields.idAvaliacaoManobra} = ?',
      whereArgs: [idAvaliacaoManobra],
    );

    return maps.map((m) => AvaliacaoIndicador.fromMap(m)).toList();
  }
}

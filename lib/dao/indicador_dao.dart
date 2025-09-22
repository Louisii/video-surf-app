import 'package:sqflite/sqflite.dart';
import 'package:video_surf_app/dao/db.dart';
import 'package:video_surf_app/model/indicador.dart';

class IndicadorDao {
  Future<int> create(Indicador indicador) async {
    final db = await DB.instance.database;
    return await db!.insert(
      IndicadorFields.tableName,
      indicador.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Indicador?> findById(int id) async {
    final db = await DB.instance.database;
    final maps = await db!.query(
      IndicadorFields.tableName,
      columns: IndicadorFields.values,
      where: '${IndicadorFields.indicadorId} = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Indicador.fromMap(maps.first);
    }
    return null;
  }

  Future<List<Indicador>> getAll() async {
    final db = await DB.instance.database;
    final result = await db!.query(IndicadorFields.tableName);
    return result.map((map) => Indicador.fromMap(map)).toList();
  }

  Future<List<Indicador>> getByTipoAcao(int idTipoAcao) async {
    final db = await DB.instance.database;
    final result = await db!.query(
      IndicadorFields.tableName,
      where: '${IndicadorFields.idTipoAcao} = ?',
      whereArgs: [idTipoAcao],
    );
    return result.map((map) => Indicador.fromMap(map)).toList();
  }

  Future<int> update(Indicador indicador) async {
    final db = await DB.instance.database;
    return await db!.update(
      IndicadorFields.tableName,
      indicador.toMap(),
      where: '${IndicadorFields.indicadorId} = ?',
      whereArgs: [indicador.indicadorId],
    );
  }

  Future<int> delete(int id) async {
    final db = await DB.instance.database;
    return await db!.delete(
      IndicadorFields.tableName,
      where: '${IndicadorFields.indicadorId} = ?',
      whereArgs: [id],
    );
  }
}

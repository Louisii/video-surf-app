import 'package:sqflite/sqflite.dart';
import 'package:video_surf_app/dao/db.dart';
import 'package:video_surf_app/dao/indicador_dao.dart';
import 'package:video_surf_app/model/indicador.dart';
import 'package:video_surf_app/model/tipo_acao.dart';

class TipoAcaoDao {
  final indicadorDao = IndicadorDao();

  Future<int> create(TipoAcao tipoAcao) async {
    final db = await DB.instance.database;
    return await db!.insert(
      TipoAcaoFields.tableName,
      tipoAcao.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<TipoAcao?> findById(int id) async {
    final db = await DB.instance.database;
    final maps = await db!.query(
      TipoAcaoFields.tableName,
      columns: TipoAcaoFields.values,
      where: '${TipoAcaoFields.tipoAcaoId} = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return TipoAcao.fromMap(maps.first);
    }
    return null;
  }

  Future<TipoAcao?> findByNomeNivel({
    required String nome,
    required String nivel,
  }) async {
    final db = await DB.instance.database;
    final maps = await db!.query(
      TipoAcaoFields.tableName,
      columns: TipoAcaoFields.values,
      where: '${TipoAcaoFields.nome} = ? AND ${TipoAcaoFields.nivel} = ?',
      whereArgs: [nome, nivel],
    );

    if (maps.isNotEmpty) {
      return TipoAcao.fromMap(maps.first);
    }
    return null;
  }

  Future<List<TipoAcao>> getAll() async {
    final db = await DB.instance.database;
    final result = await db!.query(TipoAcaoFields.tableName);
    return result.map((map) => TipoAcao.fromMap(map)).toList();
  }

  Future<int> update(TipoAcao tipoAcao) async {
    final db = await DB.instance.database;
    return await db!.update(
      TipoAcaoFields.tableName,
      tipoAcao.toMap(),
      where: '${TipoAcaoFields.tipoAcaoId} = ?',
      whereArgs: [tipoAcao.tipoAcaoId],
    );
  }

  Future<int> delete(int id) async {
    final db = await DB.instance.database;
    return await db!.delete(
      TipoAcaoFields.tableName,
      where: '${TipoAcaoFields.tipoAcaoId} = ?',
      whereArgs: [id],
    );
  }

  Future<List<String>> getDistinctNiveis() async {
    final db = await DB.instance.database;
    final result = await db!.rawQuery('''
      SELECT DISTINCT ${TipoAcaoFields.nivel}
      FROM ${TipoAcaoFields.tableName}
      ORDER BY ${TipoAcaoFields.nivel}
    ''');
    return result.map((row) => row[TipoAcaoFields.nivel] as String).toList();
  }

  Future<List<TipoAcao>> getByNivel(String nivel) async {
    final db = await DB.instance.database;
    final result = await db!.query(
      TipoAcaoFields.tableName,
      columns: TipoAcaoFields.values,
      where: '${TipoAcaoFields.nivel} = ?',
      whereArgs: [nivel],
    );
    return result.map((map) => TipoAcao.fromMap(map)).toList();
  }

  Future<TipoAcao?> findWithIndicadores(int id) async {
    final tipoAcao = await findById(id);
    if (tipoAcao != null) {
      List<Indicador> indicadores = await indicadorDao.getByTipoAcao(
        tipoAcao.tipoAcaoId!,
      );
      return tipoAcao.copyWith(indicadores: indicadores);
    }
    return null;
  }

  Future<TipoAcao?> getById(int idTipoAcao) async {
    final db = await DB.instance.database;
    final maps = await db!.query(
      TipoAcaoFields.tableName, // nome da tabela
      where: '${TipoAcaoFields.tipoAcaoId} = ?',
      whereArgs: [idTipoAcao],
    );
    if (maps.isNotEmpty) {
      return TipoAcao.fromMap(maps.first);
    }
    return null;
  }
}

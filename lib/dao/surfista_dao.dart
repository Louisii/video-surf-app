import 'package:sqflite/sqflite.dart';
import 'package:video_surf_app/dao/db.dart';
import '../model/surfista.dart';

class SurfistaDao {
  SurfistaDao();

  Future<int> create(Surfista surfista) async {
    final db = await DB.instance.database;

    try {
      return await db!.insert(SurfistaFields.tableName, surfista.toMap());
    } on DatabaseException catch (e) {
      if (e.isUniqueConstraintError()) {
        throw Exception('CPF ${surfista.cpf} já cadastrado!');
      }
      rethrow;
    }
  }

  Future<Surfista?> getById(int id) async {
    final db = await DB.instance.database;
    final maps = await db!.query(
      SurfistaFields.tableName,
      where: '${SurfistaFields.surfistaId} = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Surfista.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<Surfista?> getByCpf(String cpf) async {
    final db = await DB.instance.database;
    final maps = await db!.query(
      SurfistaFields.tableName,
      where: '${SurfistaFields.cpf} = ?',
      whereArgs: [cpf],
    );

    if (maps.isNotEmpty) {
      return Surfista.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<List<Surfista>> getAll() async {
    final db = await DB.instance.database;
    final maps = await db!.query(SurfistaFields.tableName);

    return maps.map((map) => Surfista.fromMap(map)).toList();
  }

  Future<int> update(Surfista surfista) async {
    final db = await DB.instance.database;
    return await db!.update(
      SurfistaFields.tableName,
      surfista.toMap(),
      where: '${SurfistaFields.surfistaId} = ?',
      whereArgs: [surfista.surfistaId],
    );
  }

  Future<int> delete(int id) async {
    final db = await DB.instance.database;
    return await db!.delete(
      SurfistaFields.tableName,
      where: '${SurfistaFields.surfistaId} = ?',
      whereArgs: [id],
    );
  }
}

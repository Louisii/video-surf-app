import 'package:sqflite/sqflite.dart';
import 'db.dart';
import '../model/local.dart';

class LocalDao {
  // Criar um novo Local
  Future<int> create(Local local) async {
    final db = await DB.instance.database;
    if (db == null) throw Exception('Banco de dados não inicializado');

    return await db.insert(
      LocalFields.tableName,
      local.toMap(),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  // Obter Local por ID
  Future<Local?> getById(int id) async {
    final db = await DB.instance.database;
    if (db == null) throw Exception('Banco de dados não inicializado');

    final maps = await db.query(
      LocalFields.tableName,
      where: '${LocalFields.localId} = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Local.fromMap(maps.first);
    } else {
      return null;
    }
  }

  // Obter todos os Locais
  Future<List<Local>> getAll() async {
    final db = await DB.instance.database;
    if (db == null) throw Exception('Banco de dados não inicializado');

    final maps = await db.query(LocalFields.tableName);

    return maps.map((map) => Local.fromMap(map)).toList();
  }

  // Atualizar Local
  Future<int> update(Local local) async {
    final db = await DB.instance.database;
    if (db == null) throw Exception('Banco de dados não inicializado');

    return await db.update(
      LocalFields.tableName,
      local.toMap(),
      where: '${LocalFields.localId} = ?',
      whereArgs: [local.localId],
    );
  }

  // Deletar Local
  Future<int> delete(int id) async {
    final db = await DB.instance.database;
    if (db == null) throw Exception('Banco de dados não inicializado');

    return await db.delete(
      LocalFields.tableName,
      where: '${LocalFields.localId} = ?',
      whereArgs: [id],
    );
  }
}


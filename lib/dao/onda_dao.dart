import 'package:video_surf_app/dao/db.dart';
import 'package:video_surf_app/model/onda.dart';

class OndaDao {
  // 🔹 Inserir onda
  Future<int> insert(Onda onda) async {
    final db = await DB.instance.database;
    return await db!.insert(OndaFields.tableName, onda.toMap());
  }

  // 🔹 Buscar onda por ID
  Future<Onda?> getById(int id) async {
    final db = await DB.instance.database;
    final maps = await db!.query(
      OndaFields.tableName,
      columns: OndaFields.values,
      where: '${OndaFields.ondaId} = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Onda.fromMap(maps.first);
    }
    return null;
  }

  // 🔹 Buscar ondas por Surfista
  Future<List<Onda>> getBySurfistaId(int surfistaId) async {
    final db = await DB.instance.database;
    final maps = await db!.query(
      OndaFields.tableName,
      columns: OndaFields.values,
      where: '${OndaFields.surfistaId} = ?',
      whereArgs: [surfistaId],
      orderBy: '${OndaFields.data} DESC',
    );

    return maps.map((map) => Onda.fromMap(map)).toList();
  }

  // 🔹 Listar todas
  Future<List<Onda>> getAll() async {
    final db = await DB.instance.database;
    final result = await db!.query(
      OndaFields.tableName,
      orderBy: '${OndaFields.data} DESC',
    );
    return result.map((map) => Onda.fromMap(map)).toList();
  }

  // 🔹 Atualizar
  Future<int> update(Onda onda) async {
    final db = await DB.instance.database;
    return await db!.update(
      OndaFields.tableName,
      onda.toMap(),
      where: '${OndaFields.ondaId} = ?',
      whereArgs: [onda.ondaId],
    );
  }

  // 🔹 Deletar
  Future<int> delete(int id) async {
    final db = await DB.instance.database;
    return await db!.delete(
      OndaFields.tableName,
      where: '${OndaFields.ondaId} = ?',
      whereArgs: [id],
    );
  }
}

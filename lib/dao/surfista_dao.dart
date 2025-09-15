import 'package:sqflite/sqflite.dart';
import '../model/atleta.dart';
import '../model/surfista.dart';
import 'db.dart';

class SurfistaDao {
  Future<int> create(Surfista surfista) async {
    final db = await DB.instance.database;
    if (db == null) throw Exception('Banco de dados não inicializado');

    return await db.transaction<int>((txn) async {
      // Inserir na tabela atleta
      final atletaId = await txn.insert(
        AtletaFields.tableName,
        surfista.toAtletaMap(),
        conflictAlgorithm: ConflictAlgorithm.abort,
      );

      // Inserir na tabela surfista
      final surfistaMap = {
        SurfistaFields.atletaId: atletaId,
        SurfistaFields.base: surfista.base.name,
      };

      final surfistaId = await txn.insert(
        SurfistaFields.tableName,
        surfistaMap,
        conflictAlgorithm: ConflictAlgorithm.abort,
      );

      return surfistaId; // sempre retorna
    });
  }

  Future<Surfista?> getById(int id) async {
    final db = await DB.instance.database;

    final maps = await db!.rawQuery(
      '''
      SELECT s.${SurfistaFields.surfistaId}, s.${SurfistaFields.atletaId}, s.${SurfistaFields.base},
             a.${AtletaFields.cpf}, a.${AtletaFields.nome}, a.${AtletaFields.dataNascimento}, a.${AtletaFields.modalidade}
      FROM ${SurfistaFields.tableName} s
      JOIN ${AtletaFields.tableName} a ON s.${SurfistaFields.atletaId} = a.${AtletaFields.atletaId}
      WHERE s.${SurfistaFields.surfistaId} = ?
    ''',
      [id],
    );

    if (maps.isNotEmpty) {
      return Surfista.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<List<Surfista>> getAll() async {
    final db = await DB.instance.database;

    final maps = await db!.rawQuery('''
      SELECT s.${SurfistaFields.surfistaId}, s.${SurfistaFields.atletaId}, s.${SurfistaFields.base},
             a.${AtletaFields.cpf}, a.${AtletaFields.nome}, a.${AtletaFields.dataNascimento}, a.${AtletaFields.modalidade}
      FROM ${SurfistaFields.tableName} s
      JOIN ${AtletaFields.tableName} a ON s.${SurfistaFields.atletaId} = a.${AtletaFields.atletaId}
    ''');

    return maps.map((map) => Surfista.fromMap(map)).toList();
  }

  Future<int> delete(int surfistaId) async {
    final db = await DB.instance.database;
    return await db!.delete(
      SurfistaFields.tableName,
      where: '${SurfistaFields.surfistaId} = ?',
      whereArgs: [surfistaId],
    );
  }

  Future<Surfista?> getByCpf(String cpf) async {
    final db = await DB.instance.database;

    final maps = await db!.rawQuery(
      '''
    SELECT s.*, a.cpf, a.nome, a.data_nascimento, a.modalidade
    FROM ${SurfistaFields.tableName} s
    JOIN ${AtletaFields.tableName} a ON s.atleta_id = a.atleta_id
    WHERE a.${AtletaFields.cpf} = ?
  ''',
      [cpf],
    );

    if (maps.isNotEmpty) {
      return Surfista.fromMap(maps.first);
    } else {
      return null;
    }
  }
}

import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:video_surf_app/dao/db.dart';
import 'package:video_surf_app/model/avaliacao_indicador.dart';
import 'package:video_surf_app/model/avaliacao_manobra.dart';
import 'package:video_surf_app/model/onda.dart';

class OndaDao {
  // 🔹 Inserir onda
  Future<int> insert(Onda onda) async {
    final db = await DB.instance.database;
    return await db!.insert(OndaFields.tableName, onda.toMap());
  }

  Future<int> createOnda(Onda onda) async {
    try {
      final db = await DB.instance.database;
      return await db!.insert(
        OndaFields.tableName,
        onda.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } on Exception catch (e) {
      if (kDebugMode) {
        print('Erro ao inserir onda: $e');
      }
      rethrow; // repassa o erro para o chamador
    }
  }

  Future<List<Onda>> findByVideo(int idVideo) async {
    final db = await DB.instance.database;

    // 1️⃣ Busca ondas do vídeo
    final ondasMaps = await db!.query(
      OndaFields.tableName,
      where: '${OndaFields.videoId} = ?',
      whereArgs: [idVideo],
    );

    // 2️⃣ Mapeia para Onda e busca avaliações de manobra
    List<Onda> ondas = [];
    for (var m in ondasMaps) {
      Onda onda = Onda.fromMap(m);

      // 🔹 Buscar avaliações de manobra desta onda
      final avaliacoesMaps = await db.query(
        AvaliacaoManobraFields.tableName, // nome da tabela de avaliações
        where: 'ondaId = ?',
        whereArgs: [onda.ondaId],
      );

      List<AvaliacaoManobra> manobras = [];
      for (var aMap in avaliacoesMaps) {
        AvaliacaoManobra manobra = AvaliacaoManobra.fromMap(aMap);

        // Buscar indicadores
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

      ondas.add(onda);
    }

    return ondas;
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

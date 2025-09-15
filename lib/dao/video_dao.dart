import 'package:sqflite/sqflite.dart';
import 'package:video_surf_app/dao/db.dart';
import 'package:video_surf_app/dao/local_dao.dart';
import 'package:video_surf_app/model/atleta.dart';
import 'package:video_surf_app/model/video.dart';

class VideoDao {
  LocalDao localDao = LocalDao();
  Future<int> create(Video video) async {
    final db = await DB.instance.database;
    return await db!.insert(
      VideoFields.tableName,
      video.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Video?> getById(int id) async {
    final db = await DB.instance.database;

    final maps = await db!.query(
      VideoFields.tableName,
      columns: VideoFields.values,
      where: '${VideoFields.videoId} = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      Video video = Video.fromMap(maps.first);
      video.local = await localDao.getById(video.localId);

      return video;
    }
    return null;
  }

  Future<List<Video>> getAll() async {
    final db = await DB.instance.database;
    final result = await db!.query(VideoFields.tableName);

    final List<Video> videos = [];
    for (var map in result) {
      final video = Video.fromMap(map);

      video.local = await localDao.getById(video.localId);

      videos.add(video);
    }

    return videos;
  }

  Future<int> update(Video video) async {
    final db = await DB.instance.database;
    return await db!.update(
      VideoFields.tableName,
      video.toMap(),
      where: '${VideoFields.videoId} = ?',
      whereArgs: [video.videoId],
    );
  }

  Future<int> delete(int id) async {
    final db = await DB.instance.database;
    return await db!.delete(
      VideoFields.tableName,
      where: '${VideoFields.videoId} = ?',
      whereArgs: [id],
    );
  }

  Future<int> countBySurfistaId(int surfistaId) async {
    final db = await DB.instance.database;

    final result = await db!.rawQuery(
      'SELECT COUNT(*) as total FROM ${VideoFields.tableName} WHERE ${AtletaFields.atletaId} = ?',
      [surfistaId],
    );

    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<List<Video>> getBySurfistaId(int atletaId) async {
    final db = await DB.instance.database;

    final result = await db!.query(
      VideoFields.tableName,
      where: 'atleta_id = ?',
      whereArgs: [atletaId],
      orderBy: '${VideoFields.data} DESC',
    );

    final List<Video> videos = [];
    for (var map in result) {
      final video = Video.fromMap(map);

      video.local = await localDao.getById(video.localId);

      videos.add(video);
    }

    return videos;
  }
}

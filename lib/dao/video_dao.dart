import 'package:sqflite/sqflite.dart';
import 'package:video_surf_app/model/video.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

class VideoDAO {
  static final VideoDAO instance = VideoDAO._init();
  static Database? _database;

  VideoDAO._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('videos.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE videos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        path TEXT NOT NULL
      )
    ''');
  }

  /// Inserir vídeo
  Future<Video> insert(Video video) async {
    final db = await instance.database;
    final id = await db.insert('videos', video.toMap());
    return video.copyWith(id: id);
  }

  /// Listar todos os vídeos
  Future<List<Video>> getAll() async {
    final db = await instance.database;
    final result = await db.query('videos', orderBy: 'id DESC');
    return result.map((map) => Video.fromMap(map)).toList();
  }

  /// Buscar vídeo por id
  Future<Video?> getById(int id) async {
    final db = await instance.database;
    final result = await db.query('videos', where: 'id = ?', whereArgs: [id]);
    if (result.isNotEmpty) {
      return Video.fromMap(result.first);
    } else {
      return null;
    }
  }

  /// Fechar conexão
  Future close() async {
    final db = await instance.database;
    db.close();
  }
}

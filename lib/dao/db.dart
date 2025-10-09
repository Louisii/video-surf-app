import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:video_surf_app/model/avaliacao_indicador.dart';
import 'package:video_surf_app/model/avaliacao_manobra.dart';
import 'package:video_surf_app/model/atleta.dart';
import 'package:video_surf_app/model/indicador.dart';
import 'package:video_surf_app/model/local.dart';
import 'package:video_surf_app/model/onda.dart';
import 'package:video_surf_app/model/surfista.dart';
import 'package:video_surf_app/model/tipo_acao.dart';
import 'package:video_surf_app/model/video.dart';

class DB {
  ///Esse número deve ser sempre igual ao último update + 1
  static const _databaseVersion = 1;
  static final DB instance = DB._init();

  static Database? _database;

  DB._init();

  Future<Database?> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('SurfTag.db');
    return _database;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
      onConfigure: _onConfigure,
    );
  }

  static Future<void> deleteDatabaseFile() async {
    final dbPath = await getDatabasesPath();
    final path = '$dbPath/SurfTag.db'; // nome que você usou no _initDB
    await deleteDatabase(path);
    if (kDebugMode) {
      print('Banco deletado: $path');
    }
  }

  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future _createDB(Database db, int version) async {
    try {
      await db.transaction((txn) async {
        for (var ddl in dllAtual) {
          await txn.execute(ddl);
        }
      });
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      throw Exception('Erro ao criar o banco de dados');
    }
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    try {
      await db.transaction((txn) async {
        for (int i = oldVersion; i < newVersion; i++) {
          for (var ddl in listaDeUpdates[i - 1]) {
            if (ddl != '') await txn.execute(ddl);
          }
        }
      });
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      throw Exception('Erro ao atualizar o banco de dados');
    }
  }

  Future close() async {
    final db = await instance.database;
    db?.close();
  }

  static const String textType = 'TEXT';
  static const String integerType = 'INTEGER';
  static const String primaryKey = 'PRIMARY KEY AUTOINCREMENT';
  static const String doubleType = 'REAL';

  final dllAtual = [
    // Tabela Atleta (genérica)
    '''
    CREATE TABLE atleta (
      ${AtletaFields.atletaId}  $integerType $primaryKey,
      ${AtletaFields.cpf} $textType NOT NULL UNIQUE,
      ${AtletaFields.nome} $textType NOT NULL,
      ${AtletaFields.dataNascimento} $textType NOT NULL,
      ${AtletaFields.modalidade} $textType NOT NULL
    );
    ''',

    // Tabela Surfista (específica)
    '''
    CREATE TABLE surfista (
      ${SurfistaFields.surfistaId} $integerType $primaryKey,
      ${AtletaFields.atletaId} $integerType NOT NULL,
      ${SurfistaFields.base} $textType NOT NULL,
      FOREIGN KEY (atleta_id) REFERENCES atleta(atleta_id) ON DELETE CASCADE
    );
    ''',

    // Tabela Local
    '''
    CREATE TABLE ${LocalFields.tableName} (
      ${LocalFields.localId} $integerType $primaryKey,
      ${LocalFields.pico} $textType NOT NULL,
      ${LocalFields.praia} $textType NOT NULL,
      ${LocalFields.cidade} $textType NOT NULL,
      ${LocalFields.pais} $textType NOT NULL
    );
    ''',

    // Tabela TipoAcao
    '''
    CREATE TABLE ${TipoAcaoFields.tableName} (
      ${TipoAcaoFields.tipoAcaoId} $integerType $primaryKey,
      ${TipoAcaoFields.nome} $textType NOT NULL,
      ${TipoAcaoFields.nivel} $textType NOT NULL
    );
    ''',

    // Tabela Indicador
    '''
    CREATE TABLE ${IndicadorFields.tableName} (
      ${IndicadorFields.indicadorId} $integerType $primaryKey,
      ${IndicadorFields.descricao} $textType NOT NULL,
      ${IndicadorFields.idTipoAcao} $integerType NOT NULL,
      FOREIGN KEY (${IndicadorFields.idTipoAcao}) REFERENCES ${TipoAcaoFields.tableName}(${TipoAcaoFields.tipoAcaoId}) ON DELETE CASCADE
    );
    ''',

    // Tabela Video
    '''
    CREATE TABLE ${VideoFields.tableName} (
      ${VideoFields.videoId} $integerType $primaryKey,
      ${VideoFields.data} $textType NOT NULL,
      ${VideoFields.path} $textType NOT NULL,
      ${AtletaFields.atletaId} $integerType NOT NULL,
      ${VideoFields.localId} $integerType NOT NULL,
      FOREIGN KEY (${AtletaFields.atletaId}) REFERENCES atleta(${AtletaFields.atletaId}) ON DELETE CASCADE,
      FOREIGN KEY (${VideoFields.localId}) REFERENCES ${LocalFields.tableName}(${LocalFields.localId}) ON DELETE CASCADE
    );
    ''',
    // Tabela Onda
    '''
    CREATE TABLE ${OndaFields.tableName} (
      ${OndaFields.ondaId} $integerType $primaryKey,
      ${OndaFields.data} $textType NOT NULL,
      ${OndaFields.surfistaId} $integerType NOT NULL,
      ${OndaFields.localId} $integerType NOT NULL,
      ${OndaFields.videoId} $integerType NOT NULL,
      ${OndaFields.ladoOnda} $textType NOT NULL,
      ${OndaFields.terminouCaindo} INTEGER NOT NULL CHECK (${OndaFields.terminouCaindo} IN (0,1)), -- ✅ campo booleano (0 ou 1)
      
      FOREIGN KEY (${OndaFields.surfistaId}) REFERENCES ${SurfistaFields.tableName}(${SurfistaFields.surfistaId}) ON DELETE CASCADE,
      FOREIGN KEY (${OndaFields.videoId}) REFERENCES ${VideoFields.tableName}(${VideoFields.videoId}) ON DELETE CASCADE,
      FOREIGN KEY (${OndaFields.localId}) REFERENCES ${LocalFields.tableName}(${LocalFields.localId}) ON DELETE CASCADE
    );
    '''
        // Tabela avaliacaoManobra
        '''
    CREATE TABLE ${AvaliacaoManobraFields.tableName} (
      ${AvaliacaoManobraFields.avaliacaoManobraId} $integerType $primaryKey,
      ${AvaliacaoManobraFields.side} $textType NOT NULL,
      ${AvaliacaoManobraFields.tempoMs} $integerType NOT NULL,
      ${AvaliacaoManobraFields.ondaId} $integerType NOT NULL,
      ${AvaliacaoManobraFields.tipoAcaoId} $integerType NOT NULL,
      FOREIGN KEY (${AvaliacaoManobraFields.ondaId}) REFERENCES ${OndaFields.tableName}(${OndaFields.ondaId}) ON DELETE CASCADE,
      FOREIGN KEY (${AvaliacaoManobraFields.tipoAcaoId}) REFERENCES ${TipoAcaoFields.tableName}(${TipoAcaoFields.tipoAcaoId}) ON DELETE CASCADE
    );
    ''',

    // Tabela AvaliacaoIndicador
    '''
    CREATE TABLE ${AvaliacaoIndicadorFields.tableName} (
      ${AvaliacaoIndicadorFields.acaoIndicadorId} $integerType $primaryKey,
      ${AvaliacaoIndicadorFields.idAvaliacaoManobra} $integerType NOT NULL,
      ${AvaliacaoIndicadorFields.idIndicador} $integerType NOT NULL,
      ${AvaliacaoIndicadorFields.classificacao} $textType NOT NULL,
      FOREIGN KEY (${AvaliacaoIndicadorFields.idAvaliacaoManobra}) REFERENCES ${AvaliacaoManobraFields.tableName}(${AvaliacaoManobraFields.avaliacaoManobraId}) ON DELETE CASCADE,
      FOREIGN KEY (${AvaliacaoIndicadorFields.idIndicador}) REFERENCES ${IndicadorFields.tableName}(${IndicadorFields.indicadorId}) ON DELETE CASCADE
    );
    ''',
  ];

  final listaDeUpdates = [];
}

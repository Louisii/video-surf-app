import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:video_surf_app/model/acao_indicador.dart';
import 'package:video_surf_app/model/acao_manobra.dart';
import 'package:video_surf_app/model/indicador.dart';
import 'package:video_surf_app/model/local.dart';
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
    // Tabela Surfista
    '''
  CREATE TABLE ${SurfistaFields.tableName} (
    ${SurfistaFields.surfistaId} $integerType $primaryKey,
    ${SurfistaFields.cpf} $textType NOT NULL,
    ${SurfistaFields.nome} $textType NOT NULL,
    ${SurfistaFields.dataNascimento} $textType NOT NULL,
    ${SurfistaFields.base} $textType NOT NULL
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
    ${TipoAcaoFields.nome} $textType NOT NULL
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
    ${VideoFields.surfistaId} $integerType NOT NULL,
    ${VideoFields.localId} $integerType NOT NULL,
    FOREIGN KEY (${VideoFields.surfistaId}) REFERENCES ${SurfistaFields.tableName}(${SurfistaFields.surfistaId}) ON DELETE CASCADE,
    FOREIGN KEY (${VideoFields.localId}) REFERENCES ${LocalFields.tableName}(${LocalFields.localId}) ON DELETE CASCADE
  );
  ''',

    // Tabela AcaoManobra
    '''
  CREATE TABLE ${AcaoManobraFields.tableName} (
    ${AcaoManobraFields.acaoManobraId} $integerType $primaryKey,
    ${AcaoManobraFields.side} $textType NOT NULL,
    ${AcaoManobraFields.tempoMs} $integerType NOT NULL,
    ${AcaoManobraFields.idVideo} $integerType NOT NULL,
    ${AcaoManobraFields.tipoAcaoId} $integerType NOT NULL,
    FOREIGN KEY (${AcaoManobraFields.idVideo}) REFERENCES ${VideoFields.tableName}(${VideoFields.videoId}) ON DELETE CASCADE,
    FOREIGN KEY (${AcaoManobraFields.tipoAcaoId}) REFERENCES ${TipoAcaoFields.tableName}(${TipoAcaoFields.tipoAcaoId}) ON DELETE CASCADE
  );
  ''',

    // Tabela AcaoIndicador
    '''
  CREATE TABLE ${AcaoIndicadorFields.tableName} (
    ${AcaoIndicadorFields.acaoIndicadorId} $integerType $primaryKey,
    ${AcaoIndicadorFields.idAcaoManobra} $integerType NOT NULL,
    ${AcaoIndicadorFields.idIndicador} $integerType NOT NULL,
    ${AcaoIndicadorFields.classificacao} $textType NOT NULL,
    FOREIGN KEY (${AcaoIndicadorFields.idAcaoManobra}) REFERENCES ${AcaoManobraFields.tableName}(${AcaoManobraFields.acaoManobraId}) ON DELETE CASCADE,
    FOREIGN KEY (${AcaoIndicadorFields.idIndicador}) REFERENCES ${IndicadorFields.tableName}(${IndicadorFields.indicadorId}) ON DELETE CASCADE
  );
  ''',
  ];

  final listaDeUpdates = [];
}

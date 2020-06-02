import 'dart:io';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {

  static final _databaseName = "alquran.db";
  static final _databaseVersion = 1;

  static final tableSurat = 'surat';
  static final suratId = 'surat_id';
  static final suratName = 'surat_name';
  static final suratText = 'surat_text';
  static final suratTranslation = 'surat_terjemahan';
  static final suratCountAyat = 'count_ayat';

  static final tableAyat = 'ayat';
  static final ayatId = 'aya_id';
  static final ayatNumber = 'aya_number';
  static final ayatSuratId = 'sura_id';
  static final ayatText = 'aya_text';
  static final ayatJuzId = 'juz_id';
  static final ayatPageNumber = 'page_number';
  static final ayatTranslation = 'translation_aya_text';


  // make this a singleton class
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  // only have a single app-wide reference to the database
  static Database _database;
  Future<Database> get database async {
    if (_database != null) return _database;
    // lazily instantiate the db the first time it is accessed
    _database = await _initDatabase();
    return _database;
  }

  // this opens the database (and creates it if it doesn't exist)
  _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    return await openDatabase(path,
        version: _databaseVersion,
        onCreate: _onCreate);
  }

  // SQL code to create the database tableSurat
  Future _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE $tableSurat (
            $suratId INTEGER PRIMARY KEY,
            $suratName TEXT NOT NULL,
            $suratText INTEGER NOT NULL,
            $suratTranslation INTEGER NOT NULL,
            $suratCountAyat INTEGER NOT NULL
          )
          ''');

    await db.execute('''
          CREATE TABLE $tableAyat (
            $ayatId INTEGER PRIMARY KEY,
            $ayatNumber INTEGER NOT NULL,
            $ayatText TEXT NOT NULL,
            $ayatSuratId INTEGER NOT NULL,
            $ayatJuzId INTEGER NOT NULL,
            $ayatPageNumber INTEGER NOT NULL,
            $ayatTranslation TEXT NOT NULL
          )
          ''');
  }

  // Helper methods

  // Inserts a row in the database where each key in the Map is a column name
  // and the value is the column value. The return value is the id of the
  // inserted row.
  Future<int> insert(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert(tableSurat, row);
  }

  Future<int> insertAyat(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert(tableAyat, row);
  }

  // All of the rows are returned as a list of maps, where each map is
  // a key-value list of columns.
  Future<List<Map<String, dynamic>>> queryAllRows() async {
    Database db = await instance.database;
    return await db.query(tableSurat);
  }

  Future<List<Map<String, dynamic>>> queryAllRowsAyat(suratId) async {
    Database db = await instance.database;
    return await db.query(tableAyat, where: "sura_id = '$suratId'");
  }

  Future<List<Map<String, dynamic>>> queryWhereLike(String keyword) async {
    Database db = await instance.database;
    return await db.query(tableSurat, where: "$suratName LIKE '%$keyword%' OR $suratTranslation LIKE '%$keyword%' OR $suratId = '$keyword'");
  }

  // All of the methods (insert, query, update, delete) can also be done using
  // raw SQL commands. This method uses a raw query to give the row count.
  Future<int> queryRowCount() async {
    Database db = await instance.database;
    return Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM $tableSurat'));
  }

  Future<int> queryRowCountAyat(suratId) async {
    Database db = await instance.database;
    return Sqflite.firstIntValue(await db.rawQuery("SELECT COUNT(*) FROM $tableAyat WHERE sura_id = '$suratId'"));
  }

  // We are assuming here that the id column in the map is set. The other
  // column values will be used to update the row.
  Future<int> update(Map<String, dynamic> row) async {
    Database db = await instance.database;
    int id = row[suratId];
    return await db.update(tableSurat, row, where: '$suratId = ?', whereArgs: [id]);
  }

  // Deletes the row specified by the id. The number of affected rows is
  // returned. This should be 1 as long as the row exists.
  Future<int> delete(int id) async {
    Database db = await instance.database;
    return await db.delete(tableSurat, where: '$suratId = ?', whereArgs: [id]);
  }
}
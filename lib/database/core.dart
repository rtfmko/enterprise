import 'dart:async';
import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DBProvider {
  DBProvider._();

  static final DBProvider db = DBProvider._();

  Database _database;

  Future<Database> get database async {
    if (_database != null) return _database;
    // if _database is null we instantiate it
    _database = await initDB();
    return _database;
  }

  initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "main.db");
    return await openDatabase(path, version: 1, onOpen: (db) {},
        onCreate: (Database db, int version) async {
      await db.execute("CREATE TABLE Profile ("
          "id INTEGER PRIMARY KEY,"
          "uuid TEXT,"
          "first_name TEXT,"
          "last_name TEXT,"
          "middle_name TEXT,"
          "phone TEXT,"
          "itn TEXT,"
          "email TEXT,"
          "photo TEXT,"
          "sex TEXT,"
          "blocked BIT,"
          "passport_type TEXT,"
          "passport_series TEXT,"
          "passport_number TEXT,"
          "passport_issued TEXT,"
          "passport_date TEXT,"
          "passport_expiry TEXT,"
          "civil_status TEXT,"
          "children TEXT,"
          "position INTEGER,"
          "education INTEGER,"
          "specialty TEXT,"
          "additional_education TEXT,"
          "last_work_place TEXT,"
          "skills TEXT,"
          "languages TEXT,"
          "disability BIT,"
          "pensioner BIT,"
          "info_card INTEGER"
          ")");
      await db.execute('CREATE TABLE timing ('
          'id INTEGER PRIMARY KEY,'
          'ext_id TEXT,'
          'user_id TEXT,'
          'date TEXT,'
          'operation TEXT,'
          'started_at TEXT,'
          'ended_at TEXT,'
          'created_at TEXT,'
          'updated_at TEXT,'
          'deleted_at TEXT,'
          'is_modified BIT'
          ')');
      await db.execute('CREATE TABLE timing_log ('
          'id INTEGER,'
          'old_ext_id TEXT,'
          'new_ext_id TEXT,'
          'old_user_id TEXT,'
          'new_user_id TEXT,'
          'old_date TEXT,'
          'new_date TEXT,'
          'old_operation TEXT,'
          'new_operation TEXT,'
          'old_start TEXT,'
          'new_start TEXT,'
          'old_end TEXT,'
          'new_end TEXT'
          ')');
      await db.execute('CREATE TABLE chanel ('
          'id INTEGER PRIMARY KEY,'
          'user_id TEXT,'
          'title TEXT,'
          'news TEXT,'
          'date TEXT,'
          'starred_at TEXT,'
          'archived_at TEXT,'
          'deleted_at TEXT,'
          'status TEXT'
          ')');
      await db.execute('CREATE TABLE paydesk ('
          'id INTEGER PRIMARY KEY AUTOINCREMENT,'
          'user_id INTEGER,'
          'amount DOUBLE,'
          'payment TEXT,'
          'confirming INTEGER,'
          'date TEXT,'
          'files TEXT'
          ')');
//      await db.execute('CREATE TRIGGER log_timing_after_update'
//          'AFTER UPDATE ON timing'
//          'WHEN old.ext_id <> new.ext_id'
//          'OR old.user_id <> new.user_id'
//          'OR old.date <> new.date'
//          'OR old.operation <> new.operation'
//          'OR old.start <> new.start'
//          'OR old.end <> new.end'
//          'BEGIN'
//          'INSERT INTO lead_logs ('
//          'id,'
//          'old_ext_id,'
//          'new_ext_id,'
//          'old_date,'
//          'new_date,'
//          'old_operation,'
//          'new_operation,'
//          'old_start,'
//          'new_start,'
//          'old_end,'
//          'old_end,'
//          'user_action,'
//          'created_at'
//          ')'
//          'VALUES('
//          'old.id,'
//          'old.phone,'
//          'new.phone,'
//          'old.email,'
//          'new.email,'
//          '\'UPDATE\','
//          'DATETIME(\'NOW\')'
//          ');'
//          'END;');
    });
  }

  deleteDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "main.db");
    return await deleteDatabase(path);
  }
}

import 'package:enterprise/models/timing.dart';

import '../models/contatns.dart';
import 'core.dart';

class TimingDAO {
  final dbProvider = DBProvider.db;

  insert(Timing timing, {bool isModified = true}) async {
    final db = await dbProvider.database;
    //get the biggest id in the table
    var table = await db.rawQuery("SELECT MAX(id)+1 as id FROM timing");

    if (timing.id == null) {
      timing.id = table.first["id"];
    }

    if (timing.createdAt == null) {
      timing.createdAt = DateTime.now();
    }

    if (timing.isTurnstile == null) {
      timing.isTurnstile = false;
    }

    //insert to the table using the new id
    var raw = await db.rawInsert(
        'INSERT Into timing ('
        'id,'
        'ext_id,'
        'user_id,'
        'date,'
        'operation,'
        'started_at,'
        'ended_at,'
        'created_at,'
        'updated_at,'
        'deleted_at,'
        'is_modified,'
        'is_turnstile'
        ')'
        'VALUES (?,?,?,?,?,?,?,?,?,?,?,?)',
        [
          timing.id,
          timing.extID,
          timing.userID,
          timing.date.toIso8601String(),
          timing.operation,
          timing.startedAt != null ? timing.startedAt.toIso8601String() : null,
          timing.endedAt != null ? timing.endedAt.toIso8601String() : null,
          timing.createdAt != null ? timing.createdAt.toIso8601String() : null,
          timing.updatedAt != null ? timing.updatedAt.toIso8601String() : null,
          timing.deletedAt != null ? timing.deletedAt.toIso8601String() : null,
          isModified ? 1 : 0,
          timing.isTurnstile ? 1 : 0,
        ]);
    timing.id = raw;
    return raw;
  }

  getById(int id) async {
    final db = await dbProvider.database;
    var res = await db.query("timing", where: "id = ?", whereArgs: [id]);
    return res.isNotEmpty ? Timing.fromMap(res.first) : null;
  }

  Future<List<Timing>> getAll() async {
    final db = await dbProvider.database;
    var res = await db.query(
      "timing",
    );

    List<Timing> list =
        res.isNotEmpty ? res.map((c) => Timing.fromMap(c)).toList() : [];
    return list;
  }

  Future<List<Timing>> getUndeletedByDateUserId(
      DateTime date, String userID) async {
    final db = await dbProvider.database;
    var res = await db.query(
      "timing",
      where: "date=? and user_id=? and deleted_at is null",
      whereArgs: [date.toIso8601String(), userID],
    );

    List<Timing> list =
        res.isNotEmpty ? res.map((c) => Timing.fromMap(c)).toList() : [];
    return list;
  }

  Future<List<Timing>> getOpenOperationByDateUserId(
      DateTime date, String userID) async {
    final db = await dbProvider.database;
    var res = await db.query("timing",
        where: "user_id=? and date=? and operation<>? and ended_at is null",
        whereArgs: [userID, date.toIso8601String(), TIMING_STATUS_WORKDAY]);

    List<Timing> list =
        res.isNotEmpty ? res.map((c) => Timing.fromMap(c)).toList() : [];
    return list;
  }

  Future<List<Timing>> getToUploadByUserId(String userID) async {
    final db = await dbProvider.database;
    var res = await db.query("timing",
        where: "user_id = ? and is_modified = 1", whereArgs: [userID]);

    List<Timing> list =
        res.isNotEmpty ? res.map((c) => Timing.fromMap(c)).toList() : [];
    return list;
  }

  Future<List<Timing>> getToUploadTurnstile() async {
    final db = await dbProvider.database;
    var res = await db.query("timing",
        where: "operation = ? and is_modified = 1",
        whereArgs: [TIMING_STATUS_WORKDAY]);

    List<Timing> list =
        res.isNotEmpty ? res.map((c) => Timing.fromMap(c)).toList() : [];
    return list;
  }

  Future<String> getCurrentOperationByUser(String userID) async {
    final db = await dbProvider.database;
    var res = await db.query(
      "timing",
      where: "user_id=? and ended_at is null and deleted_at is null",
      whereArgs: [userID],
      orderBy: "started_at DESC",
      limit: 1,
    );

    Timing _timing = res.isNotEmpty ? Timing.fromMap(res.first) : null;
    return _timing != null ? _timing.operation : "";
  }

  Future<List<Timing>> getTurnstileByDateUserId(
      DateTime date, String userID) async {
    final db = await dbProvider.database;
    var res = await db.query(
      "timing",
      where: "user_id=? and date=? and operation=? and deleted_at is null",
      whereArgs: [userID, date.toIso8601String(), TIMING_STATUS_WORKDAY],
      orderBy: "started_at DESC",
    );

    List<Timing> list =
        res.isNotEmpty ? res.map((c) => Timing.fromMap(c)).toList() : [];
    return list;
  }

  Future<List<Timing>> getOpenWorkdayByDateUserId(
      DateTime date, String userID) async {
    final db = await dbProvider.database;
    var res = await db.query("timing",
        where: "user_id=? and date=? and operation=? and ended_at is null",
        whereArgs: [userID, date.toIso8601String(), TIMING_STATUS_WORKDAY]);

    List<Timing> list =
        res.isNotEmpty ? res.map((c) => Timing.fromMap(c)).toList() : [];
    return list;
  }

  Future<List<Timing>> getOpenPastOperation(DateTime date) async {
    final db = await dbProvider.database;
    var res = await db.query("timing",
        where: "date <> ? and ended_at is null",
        whereArgs: [date.toIso8601String()]);

    List<Timing> list =
        res.isNotEmpty ? res.map((c) => Timing.fromMap(c)).toList() : [];
    return list;
  }

  Future<List<Timing>> geUndeletedtPeriodByDatesUserId(
      List<DateTime> date, String userID) async {
    final db = await dbProvider.database;

    List<String> conditionValues = [];
    for (var _date in date) {
      conditionValues.add(_date.toIso8601String());
    }

    String dateCondition = '';
    for (int i = 0; i < conditionValues.length; i++) {
      dateCondition += dateCondition.isEmpty ? '' : ', ';
      dateCondition += '?';
    }

    conditionValues.add(userID);

    var res = await db.query("timing",
        where:
            "date in ($dateCondition) and user_id = ? and deleted_at is null",
        whereArgs: conditionValues,
        orderBy: 'date ASC, operation ASC');

    List<Timing> list =
        res.isNotEmpty ? res.map((c) => Timing.fromMap(c)).toList() : [];
    return list;
  }

  update(Timing timing, {bool isModified = true}) async {
    final db = await dbProvider.database;
    timing.isModified = isModified;
    timing.updatedAt = DateTime.now();
    var res = await db.update("timing", timing.toMap(),
        where: "id = ?", whereArgs: [timing.id]);
    return res;
  }

  deleteAll() async {
    final db = await dbProvider.database;
    db.delete("timing");
  }
}

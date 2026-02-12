import 'package:mamba_fast_tracker/core/database/database_helper.dart';
import 'package:mamba_fast_tracker/core/utils/constants.dart';
import 'package:mamba_fast_tracker/features/fasting/data/models/fasting_protocol_model.dart';
import 'package:mamba_fast_tracker/features/fasting/data/models/fasting_session_model.dart';

class FastingLocalDatasource {
  // ─── Protocols ───
  Future<List<FastingProtocolModel>> getProtocols() async {
    final db = await DatabaseHelper.database;
    final maps = await db.query(AppConstants.fastingProtocolsTable);
    return maps.map((m) => FastingProtocolModel.fromMap(m)).toList();
  }

  Future<int> saveProtocol(FastingProtocolModel protocol) async {
    final db = await DatabaseHelper.database;
    return db.insert(AppConstants.fastingProtocolsTable, protocol.toMap());
  }

  Future<void> deleteProtocol(int id) async {
    final db = await DatabaseHelper.database;
    await db.delete(
      AppConstants.fastingProtocolsTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ─── Sessions ───
  Future<int> insertSession(FastingSessionModel session) async {
    final db = await DatabaseHelper.database;
    return db.insert(AppConstants.fastingSessionsTable, session.toMap());
  }

  Future<void> updateSession(FastingSessionModel session) async {
    final db = await DatabaseHelper.database;
    await db.update(
      AppConstants.fastingSessionsTable,
      session.toMap(),
      where: 'id = ?',
      whereArgs: [session.id],
    );
  }

  Future<FastingSessionModel?> getActiveSession() async {
    final db = await DatabaseHelper.database;
    final maps = await db.query(
      AppConstants.fastingSessionsTable,
      where: 'status = ?',
      whereArgs: ['active'],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return FastingSessionModel.fromMap(maps.first);
  }

  Future<List<FastingSessionModel>> getSessionsByDate(DateTime date) async {
    final db = await DatabaseHelper.database;
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);
    final maps = await db.query(
      AppConstants.fastingSessionsTable,
      where: 'start_time BETWEEN ? AND ?',
      whereArgs: [startOfDay.toIso8601String(), endOfDay.toIso8601String()],
      orderBy: 'start_time DESC',
    );
    return maps.map((m) => FastingSessionModel.fromMap(m)).toList();
  }

  Future<List<FastingSessionModel>> getSessionsInRange(DateTime start, DateTime end) async {
    final db = await DatabaseHelper.database;
    final maps = await db.query(
      AppConstants.fastingSessionsTable,
      where: 'start_time BETWEEN ? AND ? AND status != ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String(), 'cancelled'],
      orderBy: 'start_time ASC',
    );
    return maps.map((m) => FastingSessionModel.fromMap(m)).toList();
  }

  Future<int> getTotalFastingMinutesByDate(DateTime date) async {
    final db = await DatabaseHelper.database;
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    final result = await db.rawQuery('''
      SELECT SUM(elapsed_seconds) as total
      FROM ${AppConstants.fastingSessionsTable}
      WHERE start_time BETWEEN ? AND ?
      AND status IN ('completed', 'active')
    ''', [startOfDay.toIso8601String(), endOfDay.toIso8601String()]);

    final total = result.first['total'] as int? ?? 0;
    return total ~/ 60;
  }
}

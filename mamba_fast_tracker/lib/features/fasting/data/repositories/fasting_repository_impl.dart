import 'package:mamba_fast_tracker/features/fasting/data/datasources/fasting_local_datasource.dart';
import 'package:mamba_fast_tracker/features/fasting/data/models/fasting_protocol_model.dart';
import 'package:mamba_fast_tracker/features/fasting/data/models/fasting_session_model.dart';
import 'package:mamba_fast_tracker/features/fasting/domain/entities/fasting_protocol.dart';
import 'package:mamba_fast_tracker/features/fasting/domain/entities/fasting_session.dart';
import 'package:mamba_fast_tracker/features/fasting/domain/repositories/fasting_repository.dart';

class FastingRepositoryImpl implements FastingRepository {
  final FastingLocalDatasource _localDatasource;

  FastingRepositoryImpl(this._localDatasource);

  @override
  Future<List<FastingProtocol>> getProtocols() async {
    return await _localDatasource.getProtocols();
  }

  @override
  Future<void> saveCustomProtocol(FastingProtocol protocol) async {
    final model = FastingProtocolModel(
      name: protocol.name,
      fastingHours: protocol.fastingHours,
      eatingHours: protocol.eatingHours,
      isCustom: true,
    );
    await _localDatasource.saveProtocol(model);
  }

  @override
  Future<FastingSession> startFasting(FastingProtocol protocol) async {
    final session = FastingSessionModel(
      protocolName: protocol.name,
      fastingHours: protocol.fastingHours,
      eatingHours: protocol.eatingHours,
      startTime: DateTime.now(),
      status: FastingStatus.active,
    );
    final id = await _localDatasource.insertSession(session);
    return session.copyWith(id: id);
  }

  @override
  Future<void> endFasting(int sessionId, FastingStatus status) async {
    final activeSession = await _localDatasource.getActiveSession();
    if (activeSession != null && activeSession.id == sessionId) {
      final elapsed = DateTime.now().difference(activeSession.startTime).inSeconds;
      final updatedSession = FastingSessionModel(
        id: sessionId,
        protocolName: activeSession.protocolName,
        fastingHours: activeSession.fastingHours,
        eatingHours: activeSession.eatingHours,
        startTime: activeSession.startTime,
        endTime: DateTime.now(),
        status: status,
        elapsedSeconds: elapsed,
      );
      await _localDatasource.updateSession(updatedSession);
    }
  }

  @override
  Future<FastingSession?> getActiveSession() async {
    return await _localDatasource.getActiveSession();
  }

  @override
  Future<List<FastingSession>> getSessionsByDate(DateTime date) async {
    return await _localDatasource.getSessionsByDate(date);
  }

  @override
  Future<List<FastingSession>> getSessionsInRange(DateTime start, DateTime end) async {
    return await _localDatasource.getSessionsInRange(start, end);
  }

  @override
  Future<int> getTotalFastingMinutesByDate(DateTime date) async {
    return await _localDatasource.getTotalFastingMinutesByDate(date);
  }

  @override
  Future<void> deleteProtocol(int id) async {
    await _localDatasource.deleteProtocol(id);
  }
}

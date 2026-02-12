import 'package:mamba_fast_tracker/features/fasting/domain/entities/fasting_session.dart';
import 'package:mamba_fast_tracker/features/fasting/domain/entities/fasting_protocol.dart';

abstract class FastingRepository {
  Future<List<FastingProtocol>> getProtocols();
  Future<void> saveCustomProtocol(FastingProtocol protocol);
  Future<FastingSession> startFasting(FastingProtocol protocol);
  Future<void> endFasting(int sessionId, FastingStatus status);
  Future<FastingSession?> getActiveSession();
  Future<List<FastingSession>> getSessionsByDate(DateTime date);
  Future<List<FastingSession>> getSessionsInRange(DateTime start, DateTime end);
  Future<int> getTotalFastingMinutesByDate(DateTime date);
  Future<void> deleteProtocol(int id);
}

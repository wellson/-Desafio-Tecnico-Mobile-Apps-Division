import 'package:flutter_test/flutter_test.dart';
import 'package:mamba_fast_tracker/features/fasting/data/models/fasting_session_model.dart';
import 'package:mamba_fast_tracker/features/fasting/domain/entities/fasting_session.dart';

void main() {
  test('Calculation verification', () {
    // Simulate 5 minutes elapsed
    final elapsedSeconds = 300; // 5 * 60
    final totalMinutes = elapsedSeconds ~/ 60;
    
    expect(totalMinutes, 5);

    // Graph conversion
    final hours = totalMinutes / 60.0;
    expect(hours, 0.08333333333333333);
    
    final display = hours.toStringAsFixed(1);
    expect(display, '0.1'); // Should be 0.1h
  });

  group('FastingSessionModel Model', () {
      test('elapsedSeconds is mapped correctly', () {
          final map = {
              'id': 1,
              'protocol_name': '16:8',
              'fasting_hours': 16,
              'eating_hours': 8,
              'start_time': DateTime.now().toIso8601String(),
              'status': 'completed',
              'elapsed_seconds': 300
          };
          final model = FastingSessionModel.fromMap(map);
          expect(model.elapsedSeconds, 300);
      });
  });
}

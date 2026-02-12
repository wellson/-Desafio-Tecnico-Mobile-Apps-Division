import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mamba_fast_tracker/core/services/background_service.dart';
import 'package:mamba_fast_tracker/features/fasting/presentation/cubit/fasting_cubit.dart';
import 'package:mamba_fast_tracker/features/fasting/presentation/cubit/fasting_state.dart';
import 'package:mamba_fast_tracker/features/fasting/domain/repositories/fasting_repository.dart';
import 'package:mamba_fast_tracker/core/notifications/notification_service.dart';
import 'package:mamba_fast_tracker/features/fasting/domain/entities/fasting_protocol.dart';
import 'package:mamba_fast_tracker/features/fasting/domain/entities/fasting_session.dart';

class MockFastingRepository extends Mock implements FastingRepository {}
class MockNotificationService extends Mock implements NotificationService {}
class MockBackgroundService extends Mock implements BackgroundService {}

void main() {
  late FastingCubit cubit;
  late MockFastingRepository mockFastingRepository;
  late MockNotificationService mockNotificationService;
  late MockBackgroundService mockBackgroundService;

  final testProtocol = FastingProtocol(
    id: 1,
    name: '16:8',
    fastingHours: 16,
    eatingHours: 8,
  );

  final testSession = FastingSession(
    id: 1,
    protocolName: '16:8',
    fastingHours: 16,
    eatingHours: 8,
    startTime: DateTime.now(),
    status: FastingStatus.active,
  );

  setUpAll(() {
    registerFallbackValue(FastingStatus.completed);
    registerFallbackValue(FastingProtocol(
      id: 0,
      name: '',
      fastingHours: 0,
      eatingHours: 0,
    ));
  });

  setUp(() {
    mockFastingRepository = MockFastingRepository();
    mockNotificationService = MockNotificationService();
    mockBackgroundService = MockBackgroundService();

    // Stub BackgroundService methods to do nothing
    when(() => mockBackgroundService.startService(any(), any())).thenAnswer((_) async {});
    when(() => mockBackgroundService.stopService()).thenAnswer((_) {});

    cubit = FastingCubit(
      mockFastingRepository,
      mockNotificationService,
      backgroundService: mockBackgroundService,
    );
  });

  tearDown(() {
    cubit.close();
  });

  test('initial state is FastingInitial', () {
    expect(cubit.state, isA<FastingInitial>());
  });

  group('loadInitialState', () {
    blocTest<FastingCubit, FastingState>(
      'emits [FastingLoading, FastingIdle] when no active session exists',
      build: () {
        when(() => mockFastingRepository.getProtocols())
            .thenAnswer((_) async => [testProtocol]);
        when(() => mockFastingRepository.getActiveSession())
            .thenAnswer((_) async => null);
        return cubit;
      },
      act: (cubit) => cubit.loadInitialState(),
      expect: () => [
        isA<FastingLoading>(),
        isA<FastingIdle>(),
      ],
    );

    blocTest<FastingCubit, FastingState>(
      'emits [FastingLoading, FastingActive] when active session exists',
      build: () {
        when(() => mockFastingRepository.getProtocols())
            .thenAnswer((_) async => [testProtocol]);
        when(() => mockFastingRepository.getActiveSession())
            .thenAnswer((_) async => testSession);
        return cubit;
      },
      act: (cubit) => cubit.loadInitialState(),
      expect: () => [
        isA<FastingLoading>(),
        isA<FastingActive>(),
      ],
    );
  });

  group('startFasting', () {
    blocTest<FastingCubit, FastingState>(
      'emits [FastingActive] when starting fasting successfully',
      build: () {
        when(() => mockFastingRepository.startFasting(testProtocol))
            .thenAnswer((_) async => testSession);
        when(() => mockFastingRepository.getProtocols())
            .thenAnswer((_) async => [testProtocol]);
        when(() => mockNotificationService.showFastingStarted())
            .thenAnswer((_) async {});
        when(() => mockNotificationService.scheduleFastingEnd(any()))
            .thenAnswer((_) async {});
        return cubit;
      },
      act: (cubit) => cubit.startFasting(testProtocol),
      expect: () => [
        isA<FastingActive>(),
      ],
      verify: (_) {
        verify(() => mockFastingRepository.startFasting(testProtocol)).called(1);
        verify(() => mockNotificationService.showFastingStarted()).called(1);
        verify(() => mockNotificationService.scheduleFastingEnd(any())).called(1);
      },
    );
  });

  group('endFasting', () {
    blocTest<FastingCubit, FastingState>(
      'emits [FastingIdle] when ending fasting successfully',
      build: () {
        when(() => mockFastingRepository.getActiveSession())
            .thenAnswer((_) async => testSession);
        when(() => mockFastingRepository.endFasting(any(), any()))
            .thenAnswer((_) async {});
        when(() => mockNotificationService.cancelFastingNotifications())
            .thenAnswer((_) async {});
        when(() => mockFastingRepository.getProtocols())
            .thenAnswer((_) async => [testProtocol]);
        return cubit;
      },
      act: (cubit) => cubit.endFasting(),
      expect: () => [
        isA<FastingIdle>(),
      ],
      verify: (_) {
        verify(() => mockFastingRepository.endFasting(1, FastingStatus.completed)).called(1);
        verify(() => mockNotificationService.cancelFastingNotifications()).called(1);
      },
    );
  });
}

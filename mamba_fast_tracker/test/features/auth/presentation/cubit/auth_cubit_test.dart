import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mamba_fast_tracker/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:mamba_fast_tracker/features/auth/presentation/cubit/auth_state.dart';
import 'package:mamba_fast_tracker/features/auth/domain/repositories/auth_repository.dart';
import 'package:mamba_fast_tracker/features/auth/domain/entities/user.dart';

class MockAuthRepository extends Mock implements AuthRepository {}
class MockUser extends Mock implements User {}

void main() {
  late AuthCubit cubit;
  late MockAuthRepository mockAuthRepository;
  late User testUser;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    cubit = AuthCubit(mockAuthRepository);
    testUser = MockUser();
  });

  tearDown(() {
    cubit.close();
  });

  test('initial state is AuthInitial', () {
    expect(cubit.state, isA<AuthInitial>());
  });

  group('checkAuthStatus', () {
    blocTest<AuthCubit, AuthState>(
      'emits [AuthLoading, AuthAuthenticated] when user is logged in',
      build: () {
        when(() => mockAuthRepository.isLoggedIn())
            .thenAnswer((_) async => true);
        when(() => mockAuthRepository.getProfile())
            .thenAnswer((_) async => testUser);
        return cubit;
      },
      act: (cubit) => cubit.checkAuthStatus(),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthAuthenticated>(),
      ],
    );

    blocTest<AuthCubit, AuthState>(
      'emits [AuthLoading, AuthUnauthenticated] when user is not logged in',
      build: () {
        when(() => mockAuthRepository.isLoggedIn())
            .thenAnswer((_) async => false);
        return cubit;
      },
      act: (cubit) => cubit.checkAuthStatus(),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthUnauthenticated>(),
      ],
    );
  });

  group('login', () {
    blocTest<AuthCubit, AuthState>(
      'emits [AuthLoading, AuthAuthenticated] when login succeeds',
      build: () {
        when(() => mockAuthRepository.login(any(), any()))
            .thenAnswer((_) async {});
        when(() => mockAuthRepository.getProfile())
            .thenAnswer((_) async => testUser);
        return cubit;
      },
      act: (cubit) => cubit.login('test@email.com', 'password'),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthAuthenticated>(),
      ],
    );

    blocTest<AuthCubit, AuthState>(
      'emits [AuthLoading, AuthError] when login fails',
      build: () {
        when(() => mockAuthRepository.login(any(), any()))
            .thenThrow(Exception('Login failed'));
        return cubit;
      },
      act: (cubit) => cubit.login('test@email.com', 'password'),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthError>(),
      ],
    );
  });
}

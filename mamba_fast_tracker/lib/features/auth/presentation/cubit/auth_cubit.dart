import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mamba_fast_tracker/features/auth/domain/repositories/auth_repository.dart';
import 'package:mamba_fast_tracker/features/auth/presentation/cubit/auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;

  AuthCubit(this._authRepository) : super(AuthInitial());

  Future<void> checkAuthStatus() async {
    emit(AuthLoading());
    try {
      final isLoggedIn = await _authRepository.isLoggedIn();
      if (isLoggedIn) {
        final user = await _authRepository.getProfile();
        emit(AuthAuthenticated(user));
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (_) {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> login(String email, String password) async {
    emit(AuthLoading());
    try {
      await _authRepository.login(email, password);
      final user = await _authRepository.getProfile();
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> logout() async {
    await _authRepository.logout();
    emit(AuthUnauthenticated());
  }
}

import 'package:mamba_fast_tracker/features/auth/domain/entities/user.dart';

abstract class AuthRepository {
  Future<void> login(String email, String password);
  Future<void> register(String name, String email, String password);
  Future<User> getProfile();
  Future<void> logout();
  Future<bool> isLoggedIn();
  Future<void> refreshToken();
}

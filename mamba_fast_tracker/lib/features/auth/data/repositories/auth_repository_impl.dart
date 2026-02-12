import 'package:mamba_fast_tracker/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:mamba_fast_tracker/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:mamba_fast_tracker/features/auth/domain/entities/user.dart';
import 'package:mamba_fast_tracker/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource _remoteDatasource;
  final AuthLocalDatasource _localDatasource;

  AuthRepositoryImpl(this._remoteDatasource, this._localDatasource);

  @override
  Future<void> login(String email, String password) async {
    await _remoteDatasource.login(email, password);
    // After login, try to get profile to cache it
    try {
      final user = await _remoteDatasource.getProfile();
      await _localDatasource.saveUser(user);
    } catch (_) {
      // Ignore if profile fetch fails after login, 
      // but ideally we should have the user data.
    }
  }

  @override
  Future<void> register(String name, String email, String password) async {
    await _remoteDatasource.register(name: name, email: email, password: password);
  }

  @override
  Future<User> getProfile() async {
    try {
      final user = await _remoteDatasource.getProfile();
      await _localDatasource.saveUser(user);
      return user;
    } catch (e) {
      final localUser = await _localDatasource.getUser();
      if (localUser != null) {
        return localUser;
      }
      rethrow;
    }
  }

  @override
  Future<void> logout() async {
    await _remoteDatasource.logout();
    await _localDatasource.clearUser();
  }

  @override
  Future<bool> isLoggedIn() async {
    return await _remoteDatasource.isLoggedIn();
  }

  @override
  Future<void> refreshToken() async {
    // Handled by DioClient interceptor
  }
}

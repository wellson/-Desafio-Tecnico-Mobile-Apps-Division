import 'package:mamba_fast_tracker/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:mamba_fast_tracker/features/auth/domain/entities/user.dart';
import 'package:mamba_fast_tracker/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource _remoteDatasource;

  AuthRepositoryImpl(this._remoteDatasource);

  @override
  Future<void> login(String email, String password) async {
    await _remoteDatasource.login(email, password);
  }

  @override
  Future<User> getProfile() async {
    return await _remoteDatasource.getProfile();
  }

  @override
  Future<void> logout() async {
    await _remoteDatasource.logout();
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

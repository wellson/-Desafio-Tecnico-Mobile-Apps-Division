import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mamba_fast_tracker/core/network/dio_client.dart';
import 'package:mamba_fast_tracker/core/utils/constants.dart';
import 'package:mamba_fast_tracker/features/auth/data/models/user_model.dart';

class AuthRemoteDatasource {
  final DioClient _dioClient;
  final FlutterSecureStorage _secureStorage;

  AuthRemoteDatasource(this._dioClient, this._secureStorage);

  Future<void> login(String email, String password) async {
    try {
      final response = await _dioClient.dio.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );

      final data = response.data;
      await _secureStorage.write(
        key: AppConstants.accessTokenKey,
        value: data['access_token'],
      );
      await _secureStorage.write(
        key: AppConstants.refreshTokenKey,
        value: data['refresh_token'],
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Invalid email or password');
      }
      throw Exception('Login failed: ${e.message}');
    }
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      await _dioClient.dio.post(
        '/users/',
        data: {
          'name': name,
          'email': email,
          'password': password,
          'avatar': 'https://picsum.photos/800',
        },
      );
    } on DioException catch (e) {
      throw Exception('Registration failed: ${e.message}');
    }
  }

  Future<UserModel> getProfile() async {
    try {
      final response = await _dioClient.dio.get('/auth/profile');
      return UserModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Failed to get profile: ${e.message}');
    }
  }

  Future<void> logout() async {
    await _secureStorage.delete(key: AppConstants.accessTokenKey);
    await _secureStorage.delete(key: AppConstants.refreshTokenKey);
  }

  Future<bool> isLoggedIn() async {
    final token = await _secureStorage.read(key: AppConstants.accessTokenKey);
    return token != null;
  }
}

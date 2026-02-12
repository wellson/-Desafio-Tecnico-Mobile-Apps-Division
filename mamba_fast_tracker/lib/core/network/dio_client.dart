import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mamba_fast_tracker/core/utils/constants.dart';

class DioClient {
  late final Dio dio;
  final FlutterSecureStorage _secureStorage;

  DioClient(this._secureStorage) {
    dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _secureStorage.read(key: AppConstants.accessTokenKey);
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            final refreshed = await _refreshToken();
            if (refreshed) {
              final token = await _secureStorage.read(key: AppConstants.accessTokenKey);
              error.requestOptions.headers['Authorization'] = 'Bearer $token';
              final response = await dio.fetch(error.requestOptions);
              return handler.resolve(response);
            }
          }
          handler.next(error);
        },
      ),
    );
  }

  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await _secureStorage.read(key: AppConstants.refreshTokenKey);
      if (refreshToken == null) return false;

      final response = await Dio().post(
        '${AppConstants.baseUrl}/auth/refresh-token',
        data: {'refreshToken': refreshToken},
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        await _secureStorage.write(
          key: AppConstants.accessTokenKey,
          value: response.data['access_token'],
        );
        await _secureStorage.write(
          key: AppConstants.refreshTokenKey,
          value: response.data['refresh_token'],
        );
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }
}

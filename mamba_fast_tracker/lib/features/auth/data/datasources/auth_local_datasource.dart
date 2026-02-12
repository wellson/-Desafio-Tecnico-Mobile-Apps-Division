import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mamba_fast_tracker/core/utils/constants.dart';
import 'package:mamba_fast_tracker/features/auth/data/models/user_model.dart';


abstract class AuthLocalDatasource {
  Future<void> saveUser(UserModel user);
  Future<UserModel?> getUser();
  Future<void> clearUser();
}

class AuthLocalDatasourceImpl implements AuthLocalDatasource {
  final SharedPreferences _sharedPreferences;

  AuthLocalDatasourceImpl(this._sharedPreferences);

  @override
  Future<void> saveUser(UserModel user) async {
    final jsonString = json.encode(user.toJson());
    await _sharedPreferences.setString(AppConstants.userKey, jsonString);
  }

  @override
  Future<UserModel?> getUser() async {
    final jsonString = _sharedPreferences.getString(AppConstants.userKey);
    if (jsonString != null) {
      return UserModel.fromJson(json.decode(jsonString));
    }
    return null;
  }

  @override
  Future<void> clearUser() async {
    await _sharedPreferences.remove(AppConstants.userKey);
  }
}

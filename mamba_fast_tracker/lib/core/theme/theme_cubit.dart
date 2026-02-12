import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeState extends Equatable {
  final ThemeMode themeMode;

  const ThemeState({this.themeMode = ThemeMode.light});

  bool get isDark => themeMode == ThemeMode.dark;

  @override
  List<Object> get props => [themeMode];
}

class ThemeCubit extends Cubit<ThemeState> {
  static const String _themeKey = 'theme_mode';

  ThemeCubit() : super(const ThemeState());

  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool(_themeKey) ?? false;
    emit(ThemeState(themeMode: isDark ? ThemeMode.dark : ThemeMode.light));
  }

  Future<void> toggleTheme() async {
    final newMode =
        state.isDark ? ThemeMode.light : ThemeMode.dark;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, newMode == ThemeMode.dark);
    emit(ThemeState(themeMode: newMode));
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, mode == ThemeMode.dark);
    emit(ThemeState(themeMode: mode));
  }
}

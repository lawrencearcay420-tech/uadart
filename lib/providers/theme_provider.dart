import 'package:flutter/material.dart';
import 'package:clothingapp/data/repositories/storage_repository.dart';

class AppThemeProvider extends ChangeNotifier {
  final StorageRepository _storage;
  ThemeMode _themeMode = ThemeMode.light;
  bool _isLoading = true;

  AppThemeProvider(this._storage) {
    _loadTheme();
  }

  bool get isLoading => _isLoading;
  ThemeMode get themeMode => _themeMode;
  bool get isDark => _themeMode == ThemeMode.dark;

  Future<void> _loadTheme() async {
    final mode = await _storage.loadThemeMode();
    _themeMode = mode == 'dark' ? ThemeMode.dark : ThemeMode.light;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    await _storage.saveThemeMode(_themeMode == ThemeMode.dark ? 'dark' : 'light');
    notifyListeners();
  }

  Future<void> setTheme(ThemeMode mode) async {
    _themeMode = mode;
    await _storage.saveThemeMode(mode == ThemeMode.dark ? 'dark' : 'light');
    notifyListeners();
  }
}

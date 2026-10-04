import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AccountSettingsProvider extends ChangeNotifier {
  static const _reducedMotionKey = 'forme-setting-reduced-motion';
  static const _notificationsKey = 'forme-setting-notifications';

  final SharedPreferences _preferences;
  bool _reducedMotion = false;
  bool _notificationsEnabled = true;

  AccountSettingsProvider(this._preferences) {
    _reducedMotion = _preferences.getBool(_reducedMotionKey) ?? false;
    _notificationsEnabled = _preferences.getBool(_notificationsKey) ?? true;
  }

  bool get reducedMotion => _reducedMotion;
  bool get notificationsEnabled => _notificationsEnabled;

  Future<void> setReducedMotion(bool enabled) async {
    final saved = await _preferences.setBool(_reducedMotionKey, enabled);
    if (!saved) throw StateError('Could not save reduced-motion preference.');
    _reducedMotion = enabled;
    notifyListeners();
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    final saved = await _preferences.setBool(_notificationsKey, enabled);
    if (!saved) throw StateError('Could not save notification preference.');
    _notificationsEnabled = enabled;
    notifyListeners();
  }
}

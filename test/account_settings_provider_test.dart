import 'package:clothingapp/providers/account_settings_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('persists reduced motion and notification preferences', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final settings = AccountSettingsProvider(preferences);

    await settings.setReducedMotion(true);
    await settings.setNotificationsEnabled(false);

    expect(settings.reducedMotion, isTrue);
    expect(settings.notificationsEnabled, isFalse);

    final reloaded = AccountSettingsProvider(
      await SharedPreferences.getInstance(),
    );
    expect(reloaded.reducedMotion, isTrue);
    expect(reloaded.notificationsEnabled, isFalse);
  });
}

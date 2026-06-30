/// FLAG_SECURE is applied natively in MainActivity.onCreate (Android).
/// iOS has no equivalent system API to block screenshots.
class ScreenSecurity {
  static Future<void> enable() async {}
}

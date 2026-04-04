// ─────────────────────────────────────────────────────────
//  constants.dart  —  switch baseUrl based on test device
// ─────────────────────────────────────────────────────────

class AppConstants {
  // Android Emulator  →  10.0.2.2 maps to your PC's localhost
  static const String _emulatorUrl = 'http://10.0.2.2:8080';

  // Physical Device  →  replace X.X with your PC's local IP
  //   Windows: run `ipconfig`  |  Mac/Linux: run `ifconfig`
  //   Example: 'http://192.168.1.5:8080'
  static const String _deviceUrl = 'http://192.168.X.X:8080';

  // ↓ Change this line based on where you're running the app
  //static const String baseUrl = _emulatorUrl;
  static const String baseUrl = 'http://localhost:8080';
  // static const String baseUrl = _deviceUrl;  // ← uncomment for physical device
}

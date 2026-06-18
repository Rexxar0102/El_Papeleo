import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';

class DeviceIdService {
  static String? _cachedHash;

  static Future<String> getUserHash() async {
    if (_cachedHash != null) return _cachedHash!;

    final prefs = await SharedPreferences.getInstance();
    String? deviceId = prefs.getString('device_id');

    if (deviceId == null) {
      // Generate a new unique device ID
      deviceId = DateTime.now().millisecondsSinceEpoch.toString() +
          (List.generate(16, (_) => (DateTime.now().microsecondsSinceEpoch % 16).toInt()).join());
      await prefs.setString('device_id', deviceId);
    }

    // Create a hash of the device ID for privacy
    final bytes = utf8.encode(deviceId);
    _cachedHash = sha256.convert(bytes).toString().substring(0, 32);

    return _cachedHash!;
  }
}

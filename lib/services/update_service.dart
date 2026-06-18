import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:open_filex/open_filex.dart';
import 'package:package_info_plus/package_info_plus.dart';

class UpdateInfo {
  final String latestVersion;
  final String currentVersion;
  final String changelog;
  final String downloadUrl;
  final bool hasUpdate;

  UpdateInfo({
    required this.latestVersion,
    required this.currentVersion,
    required this.changelog,
    required this.downloadUrl,
    required this.hasUpdate,
  });
}

class UpdateService {
  static const String _apiUrl = 'https://api.github.com/repos/Rexxar0102/El_Papeleo/releases/latest';

  static Future<UpdateInfo> checkForUpdate() async {
    final packageInfo = await PackageInfo.fromPlatform();
    final currentVersion = packageInfo.version;

    try {
      final response = await http.get(
        Uri.parse(_apiUrl),
        headers: {'Accept': 'application/vnd.github.v3+json'},
      );

      if (response.statusCode != 200) {
        return UpdateInfo(
          latestVersion: currentVersion,
          currentVersion: currentVersion,
          changelog: '',
          downloadUrl: '',
          hasUpdate: false,
        );
      }

      final data = json.decode(response.body) as Map<String, dynamic>;
      final tagName = data['tag_name'] as String? ?? '';
      final latestVersion = tagName.startsWith('v') ? tagName.substring(1) : tagName;
      final changelog = data['body'] as String? ?? '';
      final assets = data['assets'] as List? ?? [];
      String downloadUrl = '';

      for (final asset in assets) {
        final name = asset['name'] as String? ?? '';
        if (name.endsWith('.apk')) {
          downloadUrl = asset['browser_download_url'] as String? ?? '';
          break;
        }
      }

      final hasUpdate = _compareVersions(latestVersion, currentVersion) > 0;

      return UpdateInfo(
        latestVersion: latestVersion,
        currentVersion: currentVersion,
        changelog: changelog,
        downloadUrl: downloadUrl,
        hasUpdate: hasUpdate,
      );
    } catch (e) {
      return UpdateInfo(
        latestVersion: currentVersion,
        currentVersion: currentVersion,
        changelog: '',
        downloadUrl: '',
        hasUpdate: false,
      );
    }
  }

  static Future<bool> downloadAndInstall(String url) async {
    try {
      final dir = Directory.systemTemp.createTempSync('el_papeleo_update_');
      final filePath = '${dir.path}/el_papeleo.apk';
      final file = File(filePath);

      final response = await http.get(Uri.parse(url));
      if (response.statusCode != 200) return false;

      await file.writeAsBytes(response.bodyBytes);
      final result = await OpenFilex.open(filePath);

      return result.type == ResultType.done;
    } catch (e) {
      return false;
    }
  }

  static int _compareVersions(String a, String b) {
    final partsA = a.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    final partsB = b.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    final maxLen = partsA.length > partsB.length ? partsA.length : partsB.length;

    for (int i = 0; i < maxLen; i++) {
      final va = i < partsA.length ? partsA[i] : 0;
      final vb = i < partsB.length ? partsB[i] : 0;
      if (va != vb) return va - vb;
    }
    return 0;
  }
}
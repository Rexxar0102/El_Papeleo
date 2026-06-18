import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/sugerencia.dart';
import 'device_id_service.dart';
import 'hive_service.dart';
import '../config/secrets.dart';

class SugerenciaService {
  static String get _baseUrl => Secrets.supabaseUrl;
  static String get _apiKey => Secrets.supabaseAnonKey;

  static Map<String, String> get _headers => {
        'apikey': _apiKey,
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
        'Prefer': 'return=representation',
      };

  static Future<List<Sugerencia>> getSugerencias() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/rest/v1/sugerencias?select=*&order=created_at.desc'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Sugerencia.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching sugerencias: $e');
      return [];
    }
  }

  static Future<int> _getUserSugerenciasCount() async {
    final userHash = await DeviceIdService.getUserHash();
    try {
      final response = await http.get(
        Uri.parse(
            '$_baseUrl/rest/v1/sugerencias?select=id&user_hash=eq.$userHash'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.length;
      }
      return 0;
    } catch (e) {
      print('Error counting sugerencias: $e');
      return 0;
    }
  }

  static Future<bool> canCreateSugerencia() async {
    final count = await _getUserSugerenciasCount();
    return count < 3;
  }

  static Future<int> getRemainingSuggestions() async {
    final count = await _getUserSugerenciasCount();
    return 3 - count;
  }

  static Future<Sugerencia?> createSugerencia({
    required String titulo,
    required String descripcion,
    required String tipo,
  }) async {
    final canCreate = await canCreateSugerencia();
    if (!canCreate) return null;

    final userHash = await DeviceIdService.getUserHash();

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/rest/v1/sugerencias'),
        headers: _headers,
        body: json.encode({
          'titulo': titulo,
          'descripcion': descripcion,
          'tipo': tipo,
          'user_hash': userHash,
        }),
      );

      if (response.statusCode == 201) {
        final List<dynamic> data = json.decode(response.body);
        return Sugerencia.fromJson(data[0]);
      }
      return null;
    } catch (e) {
      print('Error creating sugerencia: $e');
      return null;
    }
  }

  static Future<bool> likeSugerencia(int sugerenciaId) async {
    // Verificar si ya dio like
    if (HiveService.hasLikedSugerencia(sugerenciaId)) {
      return false;
    }

    try {
      // First get current likes
      final getResponse = await http.get(
        Uri.parse(
            '$_baseUrl/rest/v1/sugerencias?id=eq.$sugerenciaId&select=likes'),
        headers: _headers,
      );

      if (getResponse.statusCode != 200) return false;

      final List<dynamic> data = json.decode(getResponse.body);
      if (data.isEmpty) return false;

      final currentLikes = data[0]['likes'] as int? ?? 0;

      // Update likes
      final response = await http.patch(
        Uri.parse('$_baseUrl/rest/v1/sugerencias?id=eq.$sugerenciaId'),
        headers: _headers,
        body: json.encode({'likes': currentLikes + 1}),
      );

      if (response.statusCode == 200) {
        await HiveService.likeSugerencia(sugerenciaId);
        return true;
      }
      return false;
    } catch (e) {
      print('Error liking sugerencia: $e');
      return false;
    }
  }

  static Future<Sugerencia?> getById(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/rest/v1/sugerencias?id=eq.$id&select=*'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (data.isNotEmpty) {
          return Sugerencia.fromJson(data[0]);
        }
      }
      return null;
    } catch (e) {
      print('Error fetching sugerencia by id: $e');
      return null;
    }
  }
}

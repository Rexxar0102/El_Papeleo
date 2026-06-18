import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/tramite.dart';
import '../models/categoria.dart';

class SupabaseService {
  static SupabaseClient? _client;
  static bool _isInitialized = false;

  // Inicializar Supabase
  static Future<bool> init({
    required String url,
    required String anonKey,
  }) async {
    try {
      await Supabase.initialize(
        url: url,
        anonKey: anonKey,
      );
      _client = Supabase.instance.client;
      _isInitialized = true;
      return true;
    } catch (e) {
      print('Error initializing Supabase: $e');
      _isInitialized = false;
      return false;
    }
  }

  // Verificar conexión
  static Future<bool> checkConnection() async {
    if (!_isInitialized || _client == null) return false;

    try {
      // Intentar hacer una query simple para verificar conexión
      await _client!.from('tramites').select('id').limit(1);
      return true;
    } catch (e) {
      print('Connection check failed: $e');
      return false;
    }
  }

  // Obtener cliente
  static SupabaseClient? get client => _client;

  // ==================== TRÁMITES ====================

  // Obtener todos los trámites
  static Future<List<Tramite>> getTramites() async {
    if (_client == null) return [];

    try {
      final response = await _client!
          .from('tramites')
          .select()
          .order('nombre');

      return (response as List)
          .map((json) => Tramite.fromJson(json))
          .toList();
    } catch (e) {
      print('Error fetching tramites: $e');
      return [];
    }
  }

  // Buscar trámites
  static Future<List<Tramite>> searchTramites(String query) async {
    if (_client == null) return [];

    try {
      final response = await _client!
          .from('tramites')
          .select()
          .or('nombre.ilike.%$query%,descripcion.ilike.%$query%')
          .order('nombre');

      return (response as List)
          .map((json) => Tramite.fromJson(json))
          .toList();
    } catch (e) {
      print('Error searching tramites: $e');
      return [];
    }
  }

  // Obtener trámites por categoría
  static Future<List<Tramite>> getTramitesByCategoria(String categoriaId) async {
    if (_client == null) return [];

    try {
      final response = await _client!
          .from('tramites')
          .select()
          .eq('categoria_id', categoriaId)
          .order('nombre');

      return (response as List)
          .map((json) => Tramite.fromJson(json))
          .toList();
    } catch (e) {
      print('Error fetching tramites by category: $e');
      return [];
    }
  }

  // Obtener un trámite por ID
  static Future<Tramite?> getTramiteById(String id) async {
    if (_client == null) return null;

    try {
      final response = await _client!
          .from('tramites')
          .select()
          .eq('id', id)
          .single();

      return Tramite.fromJson(response);
    } catch (e) {
      print('Error fetching tramite by id: $e');
      return null;
    }
  }

  // ==================== CATEGORÍAS ====================

  // Obtener todas las categorías
  static Future<List<Categoria>> getCategorias() async {
    if (_client == null) return [];

    try {
      final response = await _client!
          .from('categorias')
          .select()
          .order('orden');

      return (response as List)
          .map((json) => Categoria.fromJson(json))
          .toList();
    } catch (e) {
      print('Error fetching categorias: $e');
      return [];
    }
  }
}

import 'package:hive_flutter/hive_flutter.dart';
import '../models/tramite.dart';
import '../models/categoria.dart';
import '../models/favorito.dart';
import '../config/constants.dart';

class HiveService {
  static Box<Tramite>? _tramitesBox;
  static Box<Categoria>? _categoriasBox;
  static Box<Favorito>? _favoritosBox;
  static Box? _configBox;

  // Inicializar Hive
  static Future<void> init() async {
    await Hive.initFlutter();

    // Registrar adaptadores
    Hive.registerAdapter(TramiteAdapter());
    Hive.registerAdapter(CategoriaAdapter());
    Hive.registerAdapter(FavoritoAdapter());

    // Abrir boxes
    _tramitesBox = await Hive.openBox<Tramite>(AppConstants.boxTramites);
    _categoriasBox = await Hive.openBox<Categoria>(AppConstants.boxCategorias);
    _favoritosBox = await Hive.openBox<Favorito>(AppConstants.boxFavoritos);
    _configBox = await Hive.openBox(AppConstants.boxConfig);
  }

  // ==================== TRÁMITES ====================

  static Future<void> saveTramites(List<Tramite> tramites) async {
    final box = _tramitesBox!;
    await box.clear();

    final tramitesToCache = tramites.take(AppConstants.maxCachedTramites).toList();
    for (final tramite in tramitesToCache) {
      await box.put(tramite.id, tramite);
    }

    await _configBox?.put('lastSync', DateTime.now().toIso8601String());
  }

  static List<Tramite> getAllTramites() {
    return _tramitesBox?.values.toList() ?? [];
  }

  static List<Tramite> searchTramites(String query) {
    final allTramites = getAllTramites();
    if (query.isEmpty) return allTramites;

    final lowerQuery = query.toLowerCase();
    return allTramites.where((t) {
      return t.nombre.toLowerCase().contains(lowerQuery) ||
          t.descripcion.toLowerCase().contains(lowerQuery) ||
          t.categoriaId.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  static List<Tramite> getTramitesByCategoria(String categoriaId) {
    return getAllTramites()
        .where((t) => t.categoriaId == categoriaId)
        .toList();
  }

  static Tramite? getTramiteById(String id) {
    return _tramitesBox?.get(id);
  }

  // ==================== CATEGORÍAS ====================

  static Future<void> saveCategorias(List<Categoria> categorias) async {
    final box = _categoriasBox!;
    await box.clear();
    for (final categoria in categorias) {
      await box.put(categoria.id, categoria);
    }
  }

  static List<Categoria> getAllCategorias() {
    final categorias = _categoriasBox?.values.toList() ?? [];
    categorias.sort((a, b) => a.orden.compareTo(b.orden));
    return categorias;
  }

  // ==================== FAVORITOS ====================

  static Future<void> addFavorito(String tramiteId) async {
    final favorito = Favorito(tramiteId: tramiteId);
    await _favoritosBox?.put(tramiteId, favorito);
  }

  static Future<void> removeFavorito(String tramiteId) async {
    await _favoritosBox?.delete(tramiteId);
  }

  static bool isFavorito(String tramiteId) {
    return _favoritosBox?.containsKey(tramiteId) ?? false;
  }

  static List<Tramite> getFavoritos() {
    final favoritos = _favoritosBox?.values.toList() ?? [];
    final tramites = <Tramite>[];
    for (final fav in favoritos) {
      final tramite = getTramiteById(fav.tramiteId);
      if (tramite != null) {
        tramites.add(tramite);
      }
    }
    return tramites;
  }

  static int getFavoritosCount() {
    return _favoritosBox?.length ?? 0;
  }

  // ==================== LIKED SUGERENCIAS ====================

  static Future<void> likeSugerencia(int sugerenciaId) async {
    final likedIds = _configBox?.get('likedSugerencias') as List? ?? [];
    if (!likedIds.contains(sugerenciaId)) {
      likedIds.add(sugerenciaId);
      await _configBox?.put('likedSugerencias', likedIds);
    }
  }

  static bool hasLikedSugerencia(int sugerenciaId) {
    final likedIds = _configBox?.get('likedSugerencias') as List? ?? [];
    return likedIds.contains(sugerenciaId);
  }

  // ========================= Config genérica ====

  static Future<void> setConfig(String key, dynamic value) async {
    await _configBox?.put(key, value);
  }

  static dynamic getConfig(String key) {
    return _configBox?.get(key);
  }

  static Future<void> invalidateSugerenciasCache() async {
    await _configBox?.delete('sugerencias_cached_estados');
    await _configBox?.delete('sugerencias_cached_snapshots');
    await _configBox?.delete('sugerencias_last_sync');
  }

  // ==================== CONFIGURACIÓN ====================

  static DateTime? getLastSyncDate() {
    final lastSync = _configBox?.get('lastSync');
    if (lastSync != null) {
      return DateTime.parse(lastSync);
    }
    return null;
  }

  static bool isCacheValid() {
    final lastSync = getLastSyncDate();
    if (lastSync == null) return false;

    final now = DateTime.now();
    final difference = now.difference(lastSync);
    return difference < AppConstants.cacheDuration;
  }

  static Future<void> markOnboardingCompleted() async {
    await _configBox?.put('onboardingCompleted', true);
  }

  static bool isOnboardingCompleted() {
    return _configBox?.get('onboardingCompleted') ?? false;
  }

  static Future<void> clearAll() async {
    await _tramitesBox?.clear();
    await _categoriasBox?.clear();
    await _favoritosBox?.clear();
    await _configBox?.clear();
  }
}

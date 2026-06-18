import 'dart:async';
import 'hive_service.dart';
import 'supabase_service.dart';
import 'connectivity_service.dart';
import '../models/tramite.dart';
import '../models/categoria.dart';

enum SyncStatus { idle, syncing, synced, error }

class SyncService {
  static SyncStatus _status = SyncStatus.idle;
  static final StreamController<SyncStatus> _statusController =
      StreamController<SyncStatus>.broadcast();
  static final Completer<void> _initialSyncCompleter = Completer<void>();

  static SyncStatus get status => _status;
  static Stream<SyncStatus> get statusStream => _statusController.stream;

  static bool get isInitialSyncDone => _initialSyncCompleter.isCompleted;

  static Future<void> waitForInitialSync() async {
    if (_initialSyncCompleter.isCompleted) return;
    await _initialSyncCompleter.future;
  }

  // Sincronización inicial al abrir la app
  static Future<void> initialSync() async {
    _doInitialSync();
  }

  static Future<void> _doInitialSync() async {
    _updateStatus(SyncStatus.syncing);

    try {
      // Descargar datos frescos de Supabase
      final tramites = await SupabaseService.getTramites();
      final categorias = await SupabaseService.getCategorias();

      // Guardar en Hive
      if (tramites.isNotEmpty) {
        await HiveService.saveTramites(tramites);
      }
      if (categorias.isNotEmpty) {
        await HiveService.saveCategorias(categorias);
      }

      _updateStatus(SyncStatus.synced);
    } catch (e) {
      print('Sync error: $e');
      _updateStatus(SyncStatus.error);
    } finally {
      if (!_initialSyncCompleter.isCompleted) {
        _initialSyncCompleter.complete();
      }
    }
  }

  // Forzar sincronización manual
  static Future<void> forceSync() async {
    _updateStatus(SyncStatus.syncing);

    try {
      final tramites = await SupabaseService.getTramites();
      final categorias = await SupabaseService.getCategorias();

      if (tramites.isNotEmpty) {
        await HiveService.saveTramites(tramites);
      }
      if (categorias.isNotEmpty) {
        await HiveService.saveCategorias(categorias);
      }

      _updateStatus(SyncStatus.synced);
    } catch (e) {
      print('Force sync error: $e');
      _updateStatus(SyncStatus.error);
    }
  }

  // Buscar trámites (offline-first)
  static Future<List<Tramite>> searchTramites(String query) async {
    // 1. Buscar en caché local primero (instantáneo)
    final localResults = HiveService.searchTramites(query);

    // 2. Si hay conexión, buscar en Supabase y actualizar caché
    final hasConnection = ConnectivityService.hasConnection;
    if (hasConnection) {
      try {
        final remoteResults = await SupabaseService.searchTramites(query);
        // Actualizar caché con resultados nuevos
        if (remoteResults.isNotEmpty) {
          await HiveService.saveTramites(remoteResults);
        }
        return remoteResults;
      } catch (e) {
        // Si falla la red, devolver resultados locales
        print('Search fallback to local: $e');
      }
    }

    return localResults;
  }

  // Obtener trámites por categoría (offline-first)
  static Future<List<Tramite>> getTramitesByCategoria(String categoriaId) async {
    final localResults = HiveService.getTramitesByCategoria(categoriaId);

    final hasConnection = ConnectivityService.hasConnection;
    if (hasConnection) {
      try {
        final remoteResults =
            await SupabaseService.getTramitesByCategoria(categoriaId);
        if (remoteResults.isNotEmpty) {
          await HiveService.saveTramites(remoteResults);
        }
        return remoteResults;
      } catch (e) {
        print('Get by category fallback to local: $e');
      }
    }

    return localResults;
  }

  // Obtener todos los trámites (offline-first)
  static Future<List<Tramite>> getAllTramites() async {
    final localResults = HiveService.getAllTramites();

    final hasConnection = ConnectivityService.hasConnection;
    if (hasConnection) {
      try {
        final remoteResults = await SupabaseService.getTramites();
        if (remoteResults.isNotEmpty) {
          await HiveService.saveTramites(remoteResults);
        }
        return remoteResults;
      } catch (e) {
        print('Get all fallback to local: $e');
      }
    }

    return localResults;
  }

  // Obtener categorías (offline-first)
  static Future<List<Categoria>> getAllCategorias() async {
    final localResults = HiveService.getAllCategorias();

    final hasConnection = ConnectivityService.hasConnection;
    if (hasConnection) {
      try {
        final remoteResults = await SupabaseService.getCategorias();
        if (remoteResults.isNotEmpty) {
          await HiveService.saveCategorias(remoteResults);
        }
        return remoteResults;
      } catch (e) {
        print('Get categorias fallback to local: $e');
      }
    }

    return localResults;
  }

  static void _updateStatus(SyncStatus newStatus) {
    _status = newStatus;
    _statusController.add(newStatus);
  }

  static void dispose() {
    _statusController.close();
  }
}

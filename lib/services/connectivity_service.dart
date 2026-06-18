import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  static final Connectivity _connectivity = Connectivity();
  static StreamSubscription<List<ConnectivityResult>>? _subscription;
  static bool _hasConnection = true;
  static final StreamController<bool> _connectionController =
      StreamController<bool>.broadcast();

  // Stream de estado de conexión
  static Stream<bool> get connectionStream => _connectionController.stream;

  // Obtener estado actual
  static bool get hasConnection => _hasConnection;

  // Inicializar monitoreo
  static Future<void> init() async {
    // Verificar estado inicial
    final result = await _connectivity.checkConnectivity();
    _hasConnection = result.isNotEmpty && !result.contains(ConnectivityResult.none);
    _connectionController.add(_hasConnection);

    // Monitorear cambios
    _subscription = _connectivity.onConnectivityChanged.listen((results) {
      final wasConnected = _hasConnection;
      _hasConnection = results.isNotEmpty && !results.contains(ConnectivityResult.none);

      // Notificar solo si cambió el estado
      if (wasConnected != _hasConnection) {
        _connectionController.add(_hasConnection);
      }
    });
  }

  // Verificar conexión actual
  static Future<bool> checkConnection() async {
    try {
      final result = await _connectivity.checkConnectivity();
      _hasConnection = result.isNotEmpty && !result.contains(ConnectivityResult.none);
      _connectionController.add(_hasConnection);
      return _hasConnection;
    } catch (e) {
      _hasConnection = false;
      _connectionController.add(false);
      return false;
    }
  }

  // Liberar recursos
  static void dispose() {
    _subscription?.cancel();
    _connectionController.close();
  }
}

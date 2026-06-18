import 'dart:async';
import '../models/sugerencia.dart';

class NovedadesService {
  static final StreamController<List<Sugerencia>> _controller = StreamController<List<Sugerencia>>.broadcast();
  static final List<Sugerencia> _pendientes = [];

  static Stream<List<Sugerencia>> get stream => _controller.stream;
  static List<Sugerencia> get pendientes => List.unmodifiable(_pendientes);
  static int get count => _pendientes.length;
  static bool get hasNovedades => _pendientes.isNotEmpty;

  static void addUpdates(List<Sugerencia> updates) {
    for (final u in updates) {
      if (!_pendientes.any((p) => p.id == u.id)) {
        _pendientes.insert(0, u);
      }
    }
    _controller.add(List.from(_pendientes));
  }

  static void markAsRead(int sugerenciaId) {
    _pendientes.removeWhere((s) => s.id == sugerenciaId);
    _controller.add(List.from(_pendientes));
  }

  static void clear() {
    _pendientes.clear();
    _controller.add([]);
  }

  static void dispose() {
    _controller.close();
  }
}
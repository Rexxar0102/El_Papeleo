import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import '../models/sugerencia.dart';

class NotificationService {
  static const MethodChannel _channel = MethodChannel('el_papeleo/notifications');
  static bool _initialized = false;
  static final StreamController<Sugerencia> _sugerenciaUpdateController = StreamController<Sugerencia>.broadcast();

  static Future<void> init() async {
    if (_initialized) return;

    try {
      await _channel.invokeMethod('initialize');
      
      _channel.setMethodCallHandler(_handleMethodCall);
      _initialized = true;
      debugPrint('NotificationService initialized');
    } catch (e) {
      debugPrint('NotificationService init error: $e');
    }
  }

  static Future<void> showEstadoChanged(Sugerencia sugerencia, String oldEstado) async {
    if (!_initialized) await init();

    final title = 'Sugerencia actualizada';
    final body = '"${sugerencia.titulo}" cambió de $_estadoLabel(oldEstado) a $_estadoLabel(sugerencia.estado)';

    await _showNotification(
      id: sugerencia.id ?? 0,
      title: title,
      body: body,
      payload: {'sugerencia_id': sugerencia.id, 'type': 'estado_changed'},
    );
    _sugerenciaUpdateController.add(sugerencia);
  }

  static Future<void> showCreated(Sugerencia sugerencia) async {
    if (!_initialized) await init();

    final title = 'Sugerencia creada';
    final body = 'Tu sugerencia "${sugerencia.titulo}" ha sido creada exitosamente';

    await _showNotification(
      id: sugerencia.id ?? 0,
      title: title,
      body: body,
      payload: {'sugerencia_id': sugerencia.id, 'type': 'created'},
    );
    _sugerenciaUpdateController.add(sugerencia);
  }

  static Future<void> showDeleted(Sugerencia sugerencia, String estadoFinal) async {
    if (!_initialized) await init();

    final title = 'Sugerencia eliminada';
    final body = 'Tu sugerencia "${sugerencia.titulo}" ($_estadoLabel(estadoFinal)) ha sido eliminada';

    await _showNotification(
      id: sugerencia.id ?? 0,
      title: title,
      body: body,
      payload: {'sugerencia_id': sugerencia.id, 'type': 'deleted'},
    );
    _sugerenciaUpdateController.add(sugerencia);
  }

  static Future<void> _showNotification({
    required int id,
    required String title,
    required String body,
    required Map<String, dynamic> payload,
  }) async {
    try {
      await _channel.invokeMethod('showNotification', {
        'id': id,
        'title': title,
        'body': body,
        'payload': payload,
      });
    } catch (e) {
      debugPrint('Show notification error: $e');
    }
  }

  static Future<dynamic> _handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'onNotificationTap':
        final payload = Map<String, dynamic>.from(call.arguments ?? {});
        if (payload['sugerencia_id'] != null) {
          _sugerenciaUpdateController.add(Sugerencia.fromJson(payload));
        }
        break;
    }
  }

  static Stream<Sugerencia> get sugerenciaUpdates => _sugerenciaUpdateController.stream;

  static String _estadoLabel(String estado) {
    switch (estado) {
      case 'pendiente': return 'Pendiente';
      case 'en_revision': return 'En Revisión';
      case 'finalizado': return 'Finalizado';
      case 'rechazado': return 'Rechazado';
      default: return estado;
    }
  }

  static void dispose() {
    _sugerenciaUpdateController.close();
  }
}
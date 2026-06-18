import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/sugerencia.dart';
import 'notification_service.dart';
import 'hive_service.dart';
import 'device_id_service.dart';

class RealtimeSugerenciasService {
  static RealtimeChannel? _channel;
  static String? _currentUserHash;

  static Future<void> subscribe() async {
    if (_channel != null) return;

    _currentUserHash = await DeviceIdService.getUserHash();
    if (_currentUserHash == null || _currentUserHash!.isEmpty) return;

    final supabase = Supabase.instance.client;

    _channel = supabase.channel('sugerencias_$_currentUserHash')
      .onPostgresChanges(
        event: PostgresChangeEvent.insert,
        schema: 'public',
        table: 'sugerencias',
        filter: PostgresChangeFilter(
          type: PostgresChangeFilterType.eq,
          column: 'user_hash',
          value: _currentUserHash!,
        ),
        callback: _handleInsert,
      )
      .onPostgresChanges(
        event: PostgresChangeEvent.update,
        schema: 'public',
        table: 'sugerencias',
        filter: PostgresChangeFilter(
          type: PostgresChangeFilterType.eq,
          column: 'user_hash',
          value: _currentUserHash!,
        ),
        callback: _handleUpdate,
      )
      .onPostgresChanges(
        event: PostgresChangeEvent.delete,
        schema: 'public',
        table: 'sugerencias',
        filter: PostgresChangeFilter(
          type: PostgresChangeFilterType.eq,
          column: 'user_hash',
          value: _currentUserHash!,
        ),
        callback: _handleDelete,
      )
      .subscribe();
  }

  static void _handleInsert(PostgresChangePayload payload) {
    try {
      final sugerencia = Sugerencia.fromJson(Map<String, dynamic>.from(payload.newRecord));
      NotificationService.showCreated(sugerencia);
      HiveService.invalidateSugerenciasCache();
    } catch (e) {
      print('Error handling realtime insert: $e');
    }
  }

  static void _handleUpdate(PostgresChangePayload payload) {
    final oldRecord = payload.oldRecord;
    final newRecord = payload.newRecord;

    final oldEstado = oldRecord['estado'] as String?;
    final newEstado = newRecord['estado'] as String?;

    if (oldEstado != null && newEstado != null && oldEstado != newEstado) {
      try {
        final sugerencia = Sugerencia.fromJson(Map<String, dynamic>.from(newRecord));
        NotificationService.showEstadoChanged(sugerencia, oldEstado);
        HiveService.invalidateSugerenciasCache();
      } catch (e) {
        print('Error handling realtime update: $e');
      }
    }
  }

  static void _handleDelete(PostgresChangePayload payload) {
    try {
      final oldRecord = payload.oldRecord;
      final estadoFinal = oldRecord['estado'] as String? ?? 'pendiente';
      final sugerencia = Sugerencia.fromJson(Map<String, dynamic>.from(oldRecord));
      NotificationService.showDeleted(sugerencia, estadoFinal);
      HiveService.invalidateSugerenciasCache();
    } catch (e) {
      print('Error handling realtime delete: $e');
    }
  }

  static Future<void> unsubscribe() async {
    if (_channel != null) {
      await Supabase.instance.client.removeChannel(_channel!);
      _channel = null;
    }
    _currentUserHash = null;
  }

  static bool get isSubscribed => _channel != null;
}
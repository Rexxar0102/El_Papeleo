import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/sugerencia.dart';
import 'hive_service.dart';
import 'device_id_service.dart';
import 'notification_service.dart';
import 'novedades_service.dart';

class SyncSugerenciasService {
  static const _lastSyncKey = 'sugerencias_last_sync';
  static const _cachedSnapshotsKey = 'sugerencias_cached_snapshots';

  static Future<void> syncOnAppStart() async {
    final userHash = await DeviceIdService.getUserHash();
    if (userHash.isEmpty) return;

    final lastSync = HiveService.getConfig(_lastSyncKey) as String?;
    final since = lastSync ?? DateTime.now().subtract(const Duration(days: 7)).toIso8601String();

    try {
      final supabase = Supabase.instance.client;
      final cachedSnapshots = _getCachedSnapshots();

      // Detectar eliminaciones: IDs en cache pero no en Supabase
      final currentIds = (await supabase
              .from('sugerencias')
              .select('id')
              .eq('user_hash', userHash))
          .map((r) => r['id'] as int)
          .toSet();

      final deletedIds = cachedSnapshots.keys.where((id) => !currentIds.contains(id)).toList();
      for (final id in deletedIds) {
        final snapshot = cachedSnapshots[id]!;
        final sug = Sugerencia(
          id: id,
          titulo: snapshot['titulo'] as String,
          estado: snapshot['estado'] as String,
          descripcion: '',
          tipo: snapshot['tipo'] as String,
          likes: 0,
          userHash: userHash,
          createdAt: null,
          updatedAt: null,
        );
        NotificationService.showDeleted(sug, snapshot['estado'] as String);
        NovedadesService.addUpdates([sug]);
        cachedSnapshots.remove(id);
      }

      // Detectar creates y cambios de estado recientes
      final response = await supabase
          .from('sugerencias')
          .select('id,titulo,descripcion,tipo,likes,user_hash,estado,created_at,updated_at')
          .eq('user_hash', userHash)
          .gte('updated_at', since)
          .order('updated_at', ascending: false);

      final nuevasNotificaciones = <Sugerencia>[];

      for (final u in response) {
        final id = u['id'] as int;
        final newEstado = u['estado'] as String? ?? 'pendiente';
        final snapshot = cachedSnapshots[id];

        if (snapshot == null) {
          // Sugerencia nueva
          final sug = Sugerencia.fromJson(Map<String, dynamic>.from(u));
          NotificationService.showCreated(sug);
          nuevasNotificaciones.add(sug);
        } else {
          final oldEstado = snapshot['estado'] as String;
          if (oldEstado != newEstado) {
            final sug = Sugerencia.fromJson(Map<String, dynamic>.from(u));
            NotificationService.showEstadoChanged(sug, oldEstado);
            nuevasNotificaciones.add(sug);
          }
        }

        // Actualizar cache con datos actuales
        cachedSnapshots[id] = {
          'titulo': u['titulo'] as String,
          'estado': newEstado,
          'tipo': u['tipo'] as String? ?? 'mejora',
        };
      }

      await _saveCachedSnapshots(cachedSnapshots);
      await HiveService.setConfig(_lastSyncKey, DateTime.now().toIso8601String());

      if (nuevasNotificaciones.isNotEmpty) {
        NovedadesService.addUpdates(nuevasNotificaciones);
      }
    } catch (e) {
      print('Sync sugerencias error: $e');
    }
  }

  static Map<int, Map<String, dynamic>> _getCachedSnapshots() {
    final data = HiveService.getConfig(_cachedSnapshotsKey) as Map?;
    if (data == null) return {};
    return data.map((k, v) => MapEntry(int.parse(k as String), Map<String, dynamic>.from(v as Map)));
  }

  static Future<void> _saveCachedSnapshots(Map<int, Map<String, dynamic>> snapshots) async {
    final encoded = snapshots.map((k, v) => MapEntry(k.toString(), v));
    await HiveService.setConfig(_cachedSnapshotsKey, encoded);
  }
}
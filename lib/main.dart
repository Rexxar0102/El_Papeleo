import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'services/hive_service.dart';
import 'services/connectivity_service.dart';
import 'services/supabase_service.dart';
import 'services/notification_service.dart';
import 'services/realtime_sugerencias_service.dart';
import 'services/sync_sugerencias_service.dart';
import 'config/secrets.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await HiveService.init();
  await ConnectivityService.init();
  await NotificationService.init();

  await SupabaseService.init(
    url: Secrets.supabaseUrl,
    anonKey: Secrets.supabaseAnonKey,
  );

  RealtimeSugerenciasService.subscribe();
  SyncSugerenciasService.syncOnAppStart();

  runApp(
    const ProviderScope(
      child: ElPapeleoApp(),
    ),
  );
}

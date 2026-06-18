import 'package:flutter/material.dart';
import 'config/theme.dart';
import 'config/routes.dart';
import 'services/sync_service.dart';

class ElPapeleoApp extends StatefulWidget {
  const ElPapeleoApp({super.key});

  @override
  State<ElPapeleoApp> createState() => _ElPapeleoAppState();
}

class _ElPapeleoAppState extends State<ElPapeleoApp> {
  @override
  void initState() {
    super.initState();
    SyncService.initialSync();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'El Papeleo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: appRouter,
    );
  }
}

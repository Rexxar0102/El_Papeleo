import 'dart:async';
import 'package:flutter/material.dart';
import '../config/constants.dart';
import '../services/connectivity_service.dart';
import '../services/sync_service.dart';

class SyncStatusIndicator extends StatefulWidget {
  const SyncStatusIndicator({super.key});

  @override
  State<SyncStatusIndicator> createState() => _SyncStatusIndicatorState();
}

class _SyncStatusIndicatorState extends State<SyncStatusIndicator> {
  bool _isConnected = false;
  SyncStatus _syncStatus = SyncStatus.idle;
  late StreamSubscription<bool> _connectionSubscription;
  late StreamSubscription<SyncStatus> _syncSubscription;

  @override
  void initState() {
    super.initState();
    _isConnected = ConnectivityService.hasConnection;
    _syncStatus = SyncService.status;
    _connectionSubscription = ConnectivityService.connectionStream.listen((connected) {
      if (mounted) setState(() => _isConnected = connected);
    });
    _syncSubscription = SyncService.statusStream.listen((status) {
      if (mounted) setState(() => _syncStatus = status);
    });
  }

  @override
  void dispose() {
    _connectionSubscription.cancel();
    _syncSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;
    String label;
    bool showSpinner = false;

    if (!_isConnected) {
      bgColor = AppColors.rojoCautela.withValues(alpha: 0.1);
      textColor = AppColors.rojoCautela;
      label = 'Offline';
    } else if (_syncStatus == SyncStatus.syncing) {
      bgColor = AppColors.amarilloSol.withValues(alpha: 0.1);
      textColor = AppColors.amarilloSol;
      label = 'Sincronizando...';
      showSpinner = true;
    } else if (_syncStatus == SyncStatus.error) {
      bgColor = AppColors.rojoCautela.withValues(alpha: 0.1);
      textColor = AppColors.rojoCautela;
      label = 'Error de sync';
    } else {
      bgColor = AppColors.verdeEsperanza.withValues(alpha: 0.1);
      textColor = AppColors.verdeEsperanza;
      label = 'Online';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: textColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showSpinner)
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: SizedBox(
                width: 8,
                height: 8,
                child: CircularProgressIndicator(strokeWidth: 2, color: textColor),
              ),
            )
          else
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: textColor,
                shape: BoxShape.circle,
              ),
            ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: textColor),
          ),
        ],
      ),
    );
  }
}

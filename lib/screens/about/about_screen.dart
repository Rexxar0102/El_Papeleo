import 'package:flutter/material.dart';
import '../../config/constants.dart';
import '../../services/update_service.dart';
import '../../widgets/app_snackbar.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  bool _checking = false;

  Future<void> _checkForUpdates() async {
    setState(() => _checking = true);

    final updateInfo = await UpdateService.checkForUpdate();

    if (!mounted) return;
    setState(() => _checking = false);

    if (!updateInfo.hasUpdate) {
      showAppSnackBar(context, 'Ya tienes la última versión');
      return;
    }

    _showUpdateDialog(updateInfo);
  }

  void _showUpdateDialog(UpdateInfo info) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nueva versión disponible'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('v${info.latestVersion} disponible (tienes v${info.currentVersion})'),
            if (info.changelog.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text('Cambios:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(info.changelog),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Más tarde'),
          ),
          FilledButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _downloadAndInstall(info.downloadUrl);
            },
            icon: const Icon(Icons.download),
            label: const Text('Descargar'),
          ),
        ],
      ),
    );
  }

  Future<void> _downloadAndInstall(String url) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 20),
            Text('Descargando...'),
          ],
        ),
      ),
    );

    final success = await UpdateService.downloadAndInstall(url);

    if (!mounted) return;
    Navigator.pop(context);

    if (!success) {
      showAppSnackBar(context, 'Error al descargar la actualización. Verifica tu conexión e intenta de nuevo.', backgroundColor: AppColors.rojoCautela);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Acerca de'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Image.asset(
                  'assets/icons/el_papeleo_ico.png',
                  height: 80,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 16),
              Image.asset(
                'assets/images/el_papeleo.png',
                height: 100,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 24),
              const Text(
                'El Papeleo',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.grisOscuro,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Guía de trámites en Cuba',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 32),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      _buildInfoRow(
                        icon: Icons.person_outline,
                        label: 'Creada por',
                        value: 'Qvasoft',
                      ),
                      const Divider(height: 24),
                      _buildInfoRow(
                        icon: Icons.info_outline,
                        label: 'Versión',
                        value: '1.0.3',
                      ),
                      const Divider(height: 24),
                      _buildInfoRow(
                        icon: Icons.email_outlined,
                        label: 'Contacto',
                        value: 'qvasoft.cu@gmail.com',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: _checking ? null : _checkForUpdates,
                  icon: _checking
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.system_update_outlined),
                  label: Text(_checking ? 'Buscando...' : 'Buscar actualizaciones'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, color: AppColors.azulConfianza, size: 22),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.grisOscuro,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
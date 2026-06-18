import 'package:flutter/material.dart';
import '../../config/constants.dart';
import '../../models/sugerencia.dart';
import '../../services/sugerencia_service.dart';

class SugerenciaDetailScreen extends StatefulWidget {
  final int sugerenciaId;

  const SugerenciaDetailScreen({super.key, required this.sugerenciaId});

  @override
  State<SugerenciaDetailScreen> createState() => _SugerenciaDetailScreenState();
}

class _SugerenciaDetailScreenState extends State<SugerenciaDetailScreen> {
  Sugerencia? _sugerencia;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadSugerencia();
  }

  Future<void> _loadSugerencia() async {
    try {
      final sugerencia = await SugerenciaService.getById(widget.sugerenciaId);
      if (mounted) {
        setState(() {
          _sugerencia = sugerencia;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _sugerencia == null
              ? const Center(child: Text('No se pudo cargar la sugerencia'))
              : _buildContent(context, _sugerencia!),
    );
  }

  Widget _buildContent(BuildContext context, Sugerencia sugerencia) {
    final estadoColor = _getEstadoColor(sugerencia.estado);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: estadoColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: estadoColor.withValues(alpha: 0.5)),
              ),
              child: Text(
                _getEstadoLabel(sugerencia.estado),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: estadoColor,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getTipoColor(sugerencia.tipo).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(_getTipoIcon(sugerencia.tipo), size: 16, color: _getTipoColor(sugerencia.tipo)),
                    const SizedBox(width: 6),
                    Text(
                      _getTipoLabel(sugerencia.tipo),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _getTipoColor(sugerencia.tipo),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            sugerencia.titulo,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.grisOscuro,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            sugerencia.descripcion,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade700,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),
          _buildInfoRow(
            icon: Icons.favorite_outline,
            label: 'Votos',
            value: '${sugerencia.likes}',
            valueColor: AppColors.rojoCautela,
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            icon: Icons.calendar_today_outlined,
            label: 'Creada',
            value: _formatDateTime(sugerencia.createdAt),
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            icon: Icons.update_outlined,
            label: 'Última actualización',
            value: _formatDateTime(sugerencia.updatedAt),
          ),
          const SizedBox(height: 24),
          if (sugerencia.estado == 'finalizado' || sugerencia.estado == 'rechazado')
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: estadoColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: estadoColor.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: estadoColor, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        sugerencia.estado == 'finalizado' ? 'Sugerencia implementada' : 'Sugerencia no procedente',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: estadoColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    sugerencia.estado == 'finalizado'
                        ? 'Gracias por tu aportación. Esta sugerencia ha sido implementada.'
                        : 'Esta sugerencia ha sido revisada y no se puede implementar en este momento.',
                    style: TextStyle(
                      fontSize: 13,
                      color: estadoColor,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.azulConfianza),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: valueColor ?? AppColors.grisOscuro,
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _getEstadoLabel(String estado) {
    switch (estado) {
      case 'pendiente': return 'Pendiente';
      case 'en_revision': return 'En Revisión';
      case 'finalizado': return 'Finalizado';
      case 'rechazado': return 'Rechazado';
      default: return estado;
    }
  }

  Color _getEstadoColor(String estado) {
    switch (estado) {
      case 'pendiente': return Colors.grey;
      case 'en_revision': return AppColors.amarilloSol;
      case 'finalizado': return AppColors.verdeEsperanza;
      case 'rechazado': return AppColors.rojoCautela;
      default: return Colors.grey;
    }
  }

  String _getTipoLabel(String tipo) {
    switch (tipo) {
      case 'mejora': return 'Mejora de app';
      case 'nuevo_tramite': return 'Nuevo trámite';
      case 'modificar_tramite': return 'Modificar trámite';
      default: return tipo;
    }
  }

  IconData _getTipoIcon(String tipo) {
    switch (tipo) {
      case 'mejora': return Icons.lightbulb_outline;
      case 'nuevo_tramite': return Icons.add_circle_outline;
      case 'modificar_tramite': return Icons.edit_outlined;
      default: return Icons.comment_outlined;
    }
  }

  Color _getTipoColor(String tipo) {
    switch (tipo) {
      case 'mejora': return AppColors.amarilloSol;
      case 'nuevo_tramite': return AppColors.verdeEsperanza;
      case 'modificar_tramite': return AppColors.azulConfianza;
      default: return Colors.grey;
    }
  }

  String _formatDateTime(DateTime? date) {
    if (date == null) return 'No disponible';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
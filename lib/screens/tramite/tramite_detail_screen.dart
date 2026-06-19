import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import '../../config/constants.dart';
import '../../models/tramite.dart';
import '../../services/hive_service.dart';
import '../../widgets/requirement_item.dart';
import '../../widgets/app_snackbar.dart';

class TramiteDetailScreen extends ConsumerStatefulWidget {
  final String tramiteId;

  const TramiteDetailScreen({super.key, required this.tramiteId});

  @override
  ConsumerState<TramiteDetailScreen> createState() =>
      _TramiteDetailScreenState();
}

class _TramiteDetailScreenState extends ConsumerState<TramiteDetailScreen> {
  Tramite? _tramite;
  bool _isLoading = true;
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _loadTramite();
  }

  Future<void> _loadTramite() async {
    final tramite = HiveService.getTramiteById(widget.tramiteId);
    if (mounted) {
      setState(() {
        _tramite = tramite;
        _isLoading = false;
        _isFavorite = HiveService.isFavorito(widget.tramiteId);
      });
    }
  }

  void _toggleFavorite() async {
    HapticFeedback.mediumImpact();
    if (_isFavorite) {
      await HiveService.removeFavorito(widget.tramiteId);
    } else {
      await HiveService.addFavorito(widget.tramiteId);
    }
    setState(() => _isFavorite = !_isFavorite);

    if (mounted) {
      showAppSnackBar(
        context,
        _isFavorite ? 'Agregado a Favoritos' : 'Eliminado de Favoritos',
        backgroundColor: _isFavorite ? AppColors.verdeEsperanza : Colors.grey,
      );
    }
  }

  Future<void> _openMap() async {
    if (_tramite?.dondeHacerlo == null || _tramite!.dondeHacerlo.isEmpty) return;

    final query = Uri.encodeComponent(_tramite!.dondeHacerlo);
    final url = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=$query');

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Cargando...')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_tramite == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: const Center(
          child: Text('No se pudo cargar el trámite'),
        ),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Header with gradient and title + favorite
          SliverAppBar(
            expandedHeight: 140,
            pinned: true,
            actions: [
              IconButton(
                icon: Icon(
                  _isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: _isFavorite ? AppColors.rojoCautela : Colors.white,
                  size: 28,
                ),
                onPressed: _toggleFavorite,
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                _tramite!.nombre,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
              background: Hero(
                tag: 'tramite_icon_${_tramite!.id}',
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.azulConfianza,
                        AppColors.azulConfianzaDark,
                      ],
                    ),
                  ),
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Icon(
                        Icons.description_outlined,
                        size: 60,
                        color: Colors.white.withValues(alpha: 0.15),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Descripción
                  if (_tramite!.descripcion.isNotEmpty)
                    _buildSection(
                      icon: Icons.info_outline,
                      iconColor: AppColors.azulConfianza,
                      title: 'Descripción',
                      child: Text(
                        _tramite!.descripcion,
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey.shade700,
                          height: 1.5,
                        ),
                      ),
                    ),

                  // Requisitos
                  if (_tramite!.requisitos.isNotEmpty)
                    _buildSection(
                      icon: Icons.checklist_outlined,
                      iconColor: AppColors.verdeEsperanza,
                      title: 'Requisitos',
                      child: Column(
                        children: _tramite!.requisitos
                            .map((r) => RequirementItem(text: r))
                            .toList(),
                      ),
                    ),

                  // ¿Dónde Hacerlo?
                  if (_tramite!.dondeHacerlo.isNotEmpty)
                    _buildSection(
                      icon: Icons.location_on_outlined,
                      iconColor: AppColors.rojoCautela,
                      title: '¿Dónde Hacerlo?',
                      child: InkWell(
                        onTap: _openMap,
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                _tramite!.dondeHacerlo,
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.grey.shade700,
                                  height: 1.4,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              Icons.open_in_new_outlined,
                              size: 18,
                              color: AppColors.azulConfianza.withValues(alpha: 0.6),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // Horarios
                  if (_tramite!.horarios.isNotEmpty)
                    _buildSection(
                      icon: Icons.access_time_outlined,
                      iconColor: AppColors.amarilloSol,
                      title: 'Horarios',
                      child: Text(
                        _tramite!.horarios,
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey.shade700,
                          height: 1.4,
                        ),
                      ),
                    ),

                  // Costo CUP
                  if (_tramite!.costoCup > 0)
                    _buildSection(
                      icon: Icons.attach_money_outlined,
                      iconColor: AppColors.verdeEsperanza,
                      title: 'Costo CUP',
                      child: Text(
                        '${_tramite!.costoCup.toStringAsFixed(0)} CUP',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.verdeEsperanza,
                        ),
                      ),
                    ),

                  // Plazo de Días
                  if (_tramite!.plazoDias > 0)
                    _buildSection(
                      icon: Icons.timer_outlined,
                      iconColor: AppColors.azulConfianza,
                      title: 'Plazo de Días',
                      child: Text(
                        '${_tramite!.plazoDias} días hábiles',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.azulConfianza,
                        ),
                      ),
                    ),

                  // Fecha de Actualización
                  if (_tramite!.fechaActualizacion != null)
                    _buildSection(
                      icon: Icons.calendar_today_outlined,
                      iconColor: Colors.grey.shade600,
                      title: 'Fecha de Actualización',
                      child: Text(
                        _formatDate(_tramite!.fechaActualizacion!),
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required IconData icon,
    required Color iconColor,
    required String title,
    required Widget child,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: iconColor, size: 22),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: AppColors.grisOscuro,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

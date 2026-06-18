import 'dart:async';
import 'package:flutter/material.dart';
import '../../config/constants.dart';
import '../../models/sugerencia.dart';
import '../../services/sugerencia_service.dart';
import '../../services/hive_service.dart';
import '../../services/novedades_service.dart';
import 'sugerencia_detail_screen.dart';

class SugerenciasScreen extends StatefulWidget {
  const SugerenciasScreen({super.key});

  @override
  State<SugerenciasScreen> createState() => _SugerenciasScreenState();
}

class _SugerenciasScreenState extends State<SugerenciasScreen> {
  List<Sugerencia> _sugerencias = [];
  List<Sugerencia> _filteredSugerencias = [];
  bool _isLoading = true;
  int _remainingSuggestions = 3;
  String _estadoFilter = 'todos';
  late StreamSubscription<List<Sugerencia>> _novedadesSubscription;

  @override
  void initState() {
    super.initState();
    _loadData();
    _subscribeNovedades();
  }

  @override
  void dispose() {
    _novedadesSubscription.cancel();
    super.dispose();
  }

  void _subscribeNovedades() {
    _novedadesSubscription = NovedadesService.stream.listen((novedades) {
      if (mounted) setState(() {});
    });
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final sugerencias = await SugerenciaService.getSugerencias();
    final remaining = await SugerenciaService.getRemainingSuggestions();
    if (mounted) {
      setState(() {
        _sugerencias = sugerencias;
        _remainingSuggestions = remaining;
        _isLoading = false;
        _applyFilter();
      });
    }
  }

  void _applyFilter() {
    if (_estadoFilter == 'todos') {
      _filteredSugerencias = _sugerencias;
    } else {
      _filteredSugerencias = _sugerencias.where((s) => s.estado == _estadoFilter).toList();
    }
  }

  void _onFilterChanged(String? value) {
    if (value != null && mounted) {
      setState(() {
        _estadoFilter = value;
        _applyFilter();
      });
    }
  }

  void _showCreateDialog() {
    if (_remainingSuggestions <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Has alcanzado el límite de 3 sugerencias'),
          backgroundColor: AppColors.rojoCautela,
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _CreateSugerenciaSheet(
        remaining: _remainingSuggestions,
        onCreated: () {
          Navigator.pop(context);
          _loadData();
        },
      ),
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

  Widget _buildEstadoBadge(String estado) {
    final color = _getEstadoColor(estado);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        _getEstadoLabel(estado),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sugerencias'),
        actions: [
          PopupMenuButton<String>(
            initialValue: _estadoFilter,
            onSelected: _onFilterChanged,
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'todos', child: Text('Todos')),
              const PopupMenuItem(value: 'pendiente', child: Text('Pendiente')),
              const PopupMenuItem(value: 'en_revision', child: Text('En Revisión')),
              const PopupMenuItem(value: 'finalizado', child: Text('Finalizado')),
              const PopupMenuItem(value: 'rechazado', child: Text('Rechazado')),
            ],
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.filter_list, size: 20, color: Colors.white),
                  const SizedBox(width: 4),
                  Text(
                    _estadoFilter == 'todos' ? 'Todos' : _getEstadoLabel(_estadoFilter),
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.arrow_drop_down, size: 18, color: Colors.white),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: _remainingSuggestions > 0
                      ? AppColors.verdeEsperanza.withValues(alpha: 0.1)
                      : AppColors.rojoCautela.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _remainingSuggestions > 0
                        ? AppColors.verdeEsperanza.withValues(alpha: 0.3)
                        : AppColors.rojoCautela.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  '$_remainingSuggestions/3',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: _remainingSuggestions > 0
                        ? AppColors.verdeEsperanza
                        : AppColors.rojoCautela,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _filteredSugerencias.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredSugerencias.length,
                    itemBuilder: (context, index) {
                      return _buildSugerenciaCard(_filteredSugerencias[index]);
                    },
                  ),
                ),
      floatingActionButton: Stack(
        clipBehavior: Clip.none,
        children: [
          FloatingActionButton.extended(
            onPressed: _showCreateDialog,
            backgroundColor: AppColors.verdeEsperanza,
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text(
              'Nueva sugerencia',
              style: TextStyle(color: Colors.white),
            ),
          ),
          if (NovedadesService.hasNovedades)
            Positioned(
              right: -8,
              top: -8,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.rojoCautela,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                child: Text(
                  '${NovedadesService.count}',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSugerenciaCard(Sugerencia sugerencia) {
    final tipoColor = _getTipoColor(sugerencia.tipo);
    final timeAgo = sugerencia.createdAt != null
        ? _formatTimeAgo(sugerencia.createdAt!)
        : '';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SugerenciaDetailScreen(sugerenciaId: sugerencia.id!),
          ),
        ),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: tipoColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(_getTipoIcon(sugerencia.tipo), size: 14, color: tipoColor),
                        const SizedBox(width: 4),
                        Text(
                          _getTipoLabel(sugerencia.tipo),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: tipoColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildEstadoBadge(sugerencia.estado),
                  const Spacer(),
                  Text(
                    timeAgo,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                sugerencia.titulo,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.grisOscuro,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                sugerencia.descripcion,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.person_outline, size: 16, color: Colors.grey.shade400),
                  const SizedBox(width: 4),
                  Text(
                    'Anónimo',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                  ),
                  const Spacer(),
                  Builder(
                    builder: (context) {
                      final hasLiked = HiveService.hasLikedSugerencia(sugerencia.id!);
                      return InkWell(
                        onTap: hasLiked ? null : () async {
                          await SugerenciaService.likeSugerencia(sugerencia.id!);
                          _loadData();
                        },
                        child: Row(
                          children: [
                            Icon(
                              hasLiked ? Icons.favorite : Icons.favorite_outline,
                              size: 18,
                              color: hasLiked ? AppColors.rojoCautela : tipoColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${sugerencia.likes}',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: hasLiked ? AppColors.rojoCautela : tipoColor,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    String message;
    if (_estadoFilter != 'todos') {
      message = 'No hay sugerencias con estado "${_getEstadoLabel(_estadoFilter)}"';
    } else if (_sugerencias.isEmpty) {
      message = 'Sin sugerencias aún';
    } else {
      message = 'No hay sugerencias que coincidan';
    }
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.forum_outlined, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 8),
          Text(
            _sugerencias.isEmpty ? 'Sé el primero en dejar tu opinión' : 'Intenta con otro filtro',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }

  String _formatTimeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'Ahora';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';
    return '${(diff.inDays / 7).floor()}sem';
  }
}

class _CreateSugerenciaSheet extends StatefulWidget {
  final int remaining;
  final VoidCallback onCreated;

  const _CreateSugerenciaSheet({
    required this.remaining,
    required this.onCreated,
  });

  @override
  State<_CreateSugerenciaSheet> createState() => _CreateSugerenciaSheetState();
}

class _CreateSugerenciaSheetState extends State<_CreateSugerenciaSheet> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _descripcionController = TextEditingController();
  String _tipo = 'mejora';
  bool _isSubmitting = false;

  @override
  void dispose() {
    _tituloController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final sugerencia = await SugerenciaService.createSugerencia(
      titulo: _tituloController.text.trim(),
      descripcion: _descripcionController.text.trim(),
      tipo: _tipo,
    );

    if (sugerencia != null) {
      widget.onCreated();
    } else {
      setState(() => _isSubmitting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al crear sugerencia'),
            backgroundColor: AppColors.rojoCautela,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Nueva sugerencia (${widget.remaining} restantes)',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _tipo,
              decoration: const InputDecoration(
                labelText: 'Tipo de sugerencia',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'mejora', child: Text('Mejora de la app')),
                DropdownMenuItem(value: 'nuevo_tramite', child: Text('Nuevo trámite')),
                DropdownMenuItem(value: 'modificar_tramite', child: Text('Modificar trámite existente')),
              ],
              onChanged: (value) => setState(() => _tipo = value!),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _tituloController,
              decoration: const InputDecoration(
                labelText: 'Título',
                hintText: 'Ej: Mejorar búsqueda de pasaportes',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Ingresa un título';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descripcionController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Descripción',
                hintText: 'Describe tu sugerencia en detalle...',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Ingresa una descripción';
                }
                if (value.trim().length < 10) {
                  return 'Mínimo 10 caracteres';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.verdeEsperanza,
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Enviar sugerencia',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
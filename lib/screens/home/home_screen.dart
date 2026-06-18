import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../config/constants.dart';
import '../../services/sync_service.dart';
import '../../models/tramite.dart';
import '../../models/categoria.dart';
import '../../services/hive_service.dart';
import '../../widgets/tramite_card.dart';
import '../../widgets/search_bar.dart';
import '../../widgets/sync_status_indicator.dart';
import '../sugerencias/sugerencias_screen.dart';
import '../about/about_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String _searchQuery = '';
  String? _selectedCategoriaId;
  List<Tramite> _tramites = [];
  List<Categoria> _categorias = [];
  bool _isLoading = true;
  int _currentTab = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      await SyncService.waitForInitialSync();

      final categorias = HiveService.getAllCategorias();
      final tramites = _currentTab == 1
          ? HiveService.getFavoritos()
          : HiveService.getAllTramites();

      if (mounted) {
        setState(() {
          _categorias = categorias;
          _tramites = tramites;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _searchTramites(String query) async {
    setState(() => _searchQuery = query);

    if (query.isEmpty) {
      _loadData();
      return;
    }

    final results = await SyncService.searchTramites(query);
    if (mounted) {
      setState(() => _tramites = results);
    }
  }

  void _selectCategoria(String? categoriaId) {
    setState(() => _selectedCategoriaId = categoriaId);
    Navigator.pop(context);
    _loadData();
  }

  List<Tramite> get _filteredTramites {
    if (_selectedCategoriaId == null) return _tramites;
    return _tramites
        .where((t) => t.categoriaId == _selectedCategoriaId)
        .toList();
  }

  void _onTabChanged(int index) {
    setState(() {
      _currentTab = index;
      _selectedCategoriaId = null;
    });
    _loadData();
  }

  IconData _getCategoryIcon(String categoryId) {
    switch (categoryId) {
      case 'identidad-y-migracion-en-cuba':
        return Icons.badge_outlined;
      case 'salud-e-higiene':
        return Icons.local_hospital_outlined;
      case 'vivienda-en-cuba':
        return Icons.home_outlined;
      case 'trabajo-en-cuba':
        return Icons.work_outlined;
      case 'educacion-en-cuba':
        return Icons.school_outlined;
      case 'comercio-interior-y-exterior':
        return Icons.store_outlined;
      case 'registros-en-cuba':
        return Icons.list_alt_outlined;
      case 'transito-en-cuba':
        return Icons.directions_car_outlined;
      case 'aduana-de-cuba':
        return Icons.inventory_outlined;
      case 'agricultura-en-cuba':
        return Icons.agriculture_outlined;
      case 'comunicaciones-y-correo-postal-en-cuba':
        return Icons.mail_outlined;
      case 'electricidad-y-combustible-en-cuba':
        return Icons.bolt_outlined;
      case 'juridicos-notariales-y-legales-en-cuba':
        return Icons.gavel_outlined;
      case 'seguridad-social-en-cuba':
        return Icons.shield_outlined;
      case 'seguros-en-cuba':
        return Icons.health_and_safety_outlined;
      case 'servicios-bancarios-y-financieros-en-cuba':
        return Icons.account_balance_outlined;
      case 'servicios-comunales-en-cuba':
        return Icons.location_city_outlined;
      case 'servicio-militar-y-defensa-en-cuba':
        return Icons.security_outlined;
      case 'transporte-en-cuba':
        return Icons.train_outlined;
      case 'tramites-exterior':
        return Icons.flight_outlined;
      case 'tramites-en-linea':
        return Icons.wifi_outlined;
      case 'visas-en-cuba':
        return Icons.flight_outlined;
      case 'directorios-en-cuba':
        return Icons.contacts_outlined;
      case 'aplicaciones-de-uso-en-cuba':
        return Icons.phone_android_outlined;
      case 'tarifas-de-tramites-y-servicios':
        return Icons.receipt_outlined;
      default:
        return Icons.folder_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _currentTab == 0 ? 'El Papeleo' : 'Favoritos',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          const Padding(
            padding: EdgeInsets.only(right: 12),
            child: SyncStatusIndicator(),
          ),
        ],
      ),
      drawer: _buildDrawer(),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: AppSearchBar(
              onChanged: _searchTramites,
            ),
          ),

          // Active category filter chip
          if (_selectedCategoriaId != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Chip(
                    label: Text(
                      _categorias
                          .firstWhere((c) => c.id == _selectedCategoriaId,
                              orElse: () => Categoria(
                                  id: '',
                                  nombre: '',
                                  icono: '',
                                  color: '',
                                  orden: 0))
                          .nombre,
                    ),
                    deleteIcon: const Icon(Icons.close, size: 18),
                    onDeleted: () {
                      setState(() => _selectedCategoriaId = null);
                      _loadData();
                    },
                    backgroundColor: AppColors.azulConfianza.withValues(alpha: 0.1),
                    labelStyle: const TextStyle(color: AppColors.azulConfianza),
                  ),
                ],
              ),
            ),

          // Tramites list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredTramites.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: () async {
                          await SyncService.forceSync();
                          await _loadData();
                        },
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _filteredTramites.length,
                          itemBuilder: (context, index) {
                            final tramite = _filteredTramites[index];
                            return TramiteCard(
                              tramite: tramite,
                              onTap: () => context
                                  .push('/tramite/${tramite.id}')
                                  .then((_) => _loadData()),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentTab,
        onDestinationSelected: _onTabChanged,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Inicio',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_outline),
            selectedIcon: Icon(Icons.favorite),
            label: 'Favoritos',
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drawer header
            SizedBox(
              width: double.infinity,
              child: Image.asset(
                'assets/images/el_papeleo.png',
                fit: BoxFit.cover,
              ),
            ),

            // All categories
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                'Categorías',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade600,
                  letterSpacing: 1,
                ),
              ),
            ),

            // "Todos" option
            ListTile(
              leading: const Icon(Icons.all_inclusive),
              title: const Text('Todos los trámites'),
              selected: _selectedCategoriaId == null && _currentTab == 0,
              selectedTileColor: AppColors.azulConfianza.withValues(alpha: 0.1),
              onTap: () => _selectCategoria(null),
            ),

            // Category list
            Expanded(
              child: ListView.builder(
                itemCount: _categorias.length,
                itemBuilder: (context, index) {
                  final cat = _categorias[index];
                  final isSelected = _selectedCategoriaId == cat.id;
                  return ListTile(
                    leading: Icon(
                      _getCategoryIcon(cat.id),
                      color: isSelected ? AppColors.azulConfianza : Colors.grey.shade600,
                    ),
                    title: Text(
                      cat.nombre,
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        color: isSelected ? AppColors.azulConfianza : AppColors.grisOscuro,
                      ),
                    ),
                    selected: isSelected,
                    selectedTileColor: AppColors.azulConfianza.withValues(alpha: 0.1),
                    onTap: () => _selectCategoria(cat.id),
                  );
                },
              ),
            ),

            // Footer
            const Divider(),
            ListTile(
              leading: const Icon(Icons.forum_outlined),
              title: const Text('Sugerencias'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SugerenciasScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('Acerca de'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AboutScreen(),
                  ),
                );
              },
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'v1.0.0',
                style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _currentTab == 1 ? Icons.favorite_outline : Icons.search_off_outlined,
            size: 80,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            _currentTab == 1
                ? 'No tienes favoritos'
                : 'No se encontraron trámites',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _currentTab == 1
                ? 'Agrega trámites desde la pantalla de detalle'
                : _searchQuery.isNotEmpty
                    ? 'Intenta con otra búsqueda'
                    : 'Desliza hacia abajo para actualizar',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );
  }
}

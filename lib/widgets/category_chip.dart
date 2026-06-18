import 'package:flutter/material.dart';
import '../config/constants.dart';
import '../models/categoria.dart';

class CategoryChip extends StatelessWidget {
  final Categoria categoria;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryChip({
    super.key,
    required this.categoria,
    required this.isSelected,
    required this.onTap,
  });

  IconData _getIcon(String categoryId) {
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
      case 'aduana-de-cuba':
        return Icons.inventory_outlined;
      case 'agricultura-en-cuba':
        return Icons.agriculture_outlined;
      case 'comercio-interior-y-exterior':
        return Icons.store_outlined;
      case 'comunicaciones-y-correo-postal-en-cuba':
        return Icons.mail_outlined;
      case 'electricidad-y-combustible-en-cuba':
        return Icons.bolt_outlined;
      case 'juridicos-notariales-y-legales-en-cuba':
        return Icons.gavel_outlined;
      case 'registros-en-cuba':
        return Icons.list_alt_outlined;
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
      case 'transito-en-cuba':
        return Icons.directions_car_outlined;
      case 'transporte-en-cuba':
        return Icons.train_outlined;
      case 'visas-en-cuba':
        return Icons.flight_outlined;
      case 'tramites-en-linea':
        return Icons.wifi_outlined;
      case 'tramites-exterior':
        return Icons.flight_outlined;
      case 'tramites-en-consulados-extranjeros-en-cuba':
        return Icons.flight_land_outlined;
      case 'directorios-en-cuba':
        return Icons.contacts_outlined;
      case 'tarifas-de-tramites-y-servicios':
        return Icons.receipt_outlined;
      case 'aplicaciones-de-uso-en-cuba':
        return Icons.phone_android_outlined;
      default:
        return Icons.folder_outlined;
    }
  }

  Color _getColor(String categoryId) {
    switch (categoryId) {
      case 'identidad-y-migracion-en-cuba':
        return AppColors.azulConfianza;
      case 'salud-e-higiene':
        return AppColors.rojoCautela;
      case 'vivienda-en-cuba':
        return AppColors.amarilloSol;
      case 'trabajo-en-cuba':
        return AppColors.verdeEsperanza;
      case 'educacion-en-cuba':
        return const Color(0xFF8E44AD);
      case 'aduana-de-cuba':
        return const Color(0xFFE67E22);
      case 'comercio-interior-y-exterior':
        return const Color(0xFF27AE60);
      case 'registros-en-cuba':
        return const Color(0xFF2980B9);
      case 'transito-en-cuba':
        return const Color(0xFFC0392B);
      case 'visas-en-cuba':
        return const Color(0xFFE74C3C);
      case 'tramites-exterior':
        return const Color(0xFF2ECC71);
      default:
        return AppColors.azulConfianza;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColor(categoria.id);
    final icon = _getIcon(categoria.id);

    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 80,
          decoration: BoxDecoration(
            color: isSelected ? color : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? color : Colors.grey.shade300,
              width: 2,
            ),
            boxShadow: [
              if (isSelected)
                BoxShadow(
                  color: color.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 28,
                color: isSelected ? Colors.white : color,
              ),
              const SizedBox(height: 8),
              Text(
                categoria.nombre,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : AppColors.grisOscuro,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

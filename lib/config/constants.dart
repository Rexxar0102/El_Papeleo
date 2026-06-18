import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Paleta de colores principal - Evoca la bandera cubana
  static const verdeEsperanza = Color(0xFF2E8B57);
  static const amarilloSol = Color(0xFFF4D03F);
  static const azulConfianza = Color(0xFF1F618D);
  static const grisClaro = Color(0xFFF5F5F5);
  static const grisOscuro = Color(0xFF333333);
  static const rojoCautela = Color(0xFFC0392B);
  static const blancoPuro = Color(0xFFFFFFFF);

  // Variantes para states
  static const verdeEsperanzaLight = Color(0xFF5DAE8B);
  static const verdeEsperanzaDark = Color(0xFF1E5631);
  static const amarilloSolLight = Color(0xFFF8E6A0);
  static const azulConfianzaLight = Color(0xFF4A90B8);
  static const azulConfianzaDark = Color(0xFF0D3B5E);

  // Colores de estado
  static const exito = verdeEsperanza;
  static const advertencia = amarilloSol;
  static const error = rojoCautela;
  static const info = azulConfianza;

  // Fondos
  static const fondoPrincipal = grisClaro;
  static const fondoTarjeta = blancoPuro;
  static const fondoOscuro = grisOscuro;
}

class AppConstants {
  AppConstants._();

  // Tiempo de caché local (1 hora)
  static const cacheDuration = Duration(hours: 1);

  // Límite de trámites en caché
  static const maxCachedTramites = 50;

  // Estados de trámite
  static const estadoEnProgreso = 'en_progreso';
  static const estadoCompletado = 'completado';
  static const estadoCancelado = 'cancelado';

  // Pasos por defecto del checklist
  static const pasosDefault = [
    'Reunir documentos',
    'Ir a ventanilla',
    'Pagar tasa',
    'Recibir comprobante',
  ];

  // Nombres de las boxes de Hive
  static const boxTramites = 'tramites';
  static const boxCategorias = 'categorias';
  static const boxFavoritos = 'favoritos';
  static const boxConfig = 'config';
}

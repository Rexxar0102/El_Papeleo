import 'dart:convert';
import 'package:hive/hive.dart';

part 'tramite.g.dart';

@HiveType(typeId: 0)
class Tramite extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String nombre;

  @HiveField(2)
  final String categoriaId;

  @HiveField(3)
  final String descripcion;

  @HiveField(4)
  final List<String> requisitos;

  @HiveField(5)
  final String dondeHacerlo;

  @HiveField(6)
  final String horarios;

  @HiveField(7)
  final double costoCup;

  @HiveField(8)
  final int plazoDias;

  @HiveField(9)
  final String? imagenUrl;

  @HiveField(10)
  final DateTime? fechaActualizacion;

  Tramite({
    required this.id,
    required this.nombre,
    required this.categoriaId,
    required this.descripcion,
    required this.requisitos,
    required this.dondeHacerlo,
    required this.horarios,
    required this.costoCup,
    required this.plazoDias,
    this.imagenUrl,
    this.fechaActualizacion,
  });

  factory Tramite.fromJson(Map<String, dynamic> json) {
    List<String> parseRequisitos(dynamic value) {
      if (value == null) return [];
      if (value is List) return List<String>.from(value);
      if (value is String) {
        if (value.isEmpty || value == '[]') return [];
        try {
          final decoded = jsonDecode(value);
          if (decoded is List) return List<String>.from(decoded);
        } catch (_) {}
        return [];
      }
      return [];
    }

    return Tramite(
      id: json['id'] as String,
      nombre: json['nombre'] as String,
      categoriaId: json['categoria_id'] as String,
      descripcion: json['descripcion'] as String? ?? '',
      requisitos: parseRequisitos(json['requisitos']),
      dondeHacerlo: json['donde_hacerlo'] as String? ?? '',
      horarios: json['horarios'] as String? ?? '',
      costoCup: (json['costo_cup'] as num?)?.toDouble() ?? 0,
      plazoDias: json['plazo_dias'] as int? ?? 0,
      imagenUrl: json['imagen_url'] as String?,
      fechaActualizacion: json['fecha_actualizacion'] != null
          ? DateTime.parse(json['fecha_actualizacion'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'categoria_id': categoriaId,
      'descripcion': descripcion,
      'requisitos': requisitos,
      'donde_hacerlo': dondeHacerlo,
      'horarios': horarios,
      'costo_cup': costoCup,
      'plazo_dias': plazoDias,
      'imagen_url': imagenUrl,
      'fecha_actualizacion': fechaActualizacion?.toIso8601String(),
    };
  }
}

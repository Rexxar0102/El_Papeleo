import 'package:hive/hive.dart';

part 'categoria.g.dart';

@HiveType(typeId: 1)
class Categoria extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String nombre;

  @HiveField(2)
  final String icono;

  @HiveField(3)
  final String color;

  @HiveField(4)
  final int orden;

  Categoria({
    required this.id,
    required this.nombre,
    required this.icono,
    required this.color,
    required this.orden,
  });

  factory Categoria.fromJson(Map<String, dynamic> json) {
    return Categoria(
      id: json['id'] as String,
      nombre: json['nombre'] as String,
      icono: json['icono'] as String? ?? 'folder',
      color: json['color'] as String? ?? '#1F618D',
      orden: json['orden'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'icono': icono,
      'color': color,
      'orden': orden,
    };
  }
}

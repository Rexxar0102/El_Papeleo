import 'package:hive/hive.dart';

part 'favorito.g.dart';

@HiveType(typeId: 4)
class Favorito extends HiveObject {
  @HiveField(0)
  final String tramiteId;

  @HiveField(1)
  final DateTime fechaAgregado;

  Favorito({
    required this.tramiteId,
    DateTime? fechaAgregado,
  }) : fechaAgregado = fechaAgregado ?? DateTime.now();

  factory Favorito.fromJson(Map<String, dynamic> json) {
    return Favorito(
      tramiteId: json['tramite_id'] as String,
      fechaAgregado: json['fecha_agregado'] != null
          ? DateTime.parse(json['fecha_agregado'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tramite_id': tramiteId,
      'fecha_agregado': fechaAgregado.toIso8601String(),
    };
  }
}

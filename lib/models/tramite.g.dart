// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tramite.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TramiteAdapter extends TypeAdapter<Tramite> {
  @override
  final int typeId = 0;

  @override
  Tramite read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Tramite(
      id: fields[0] as String,
      nombre: fields[1] as String,
      categoriaId: fields[2] as String,
      descripcion: fields[3] as String,
      requisitos: (fields[4] as List).cast<String>(),
      dondeHacerlo: fields[5] as String,
      horarios: fields[6] as String,
      costoCup: fields[7] as double,
      plazoDias: fields[8] as int,
      imagenUrl: fields[9] as String?,
      fechaActualizacion: fields[10] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, Tramite obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.nombre)
      ..writeByte(2)
      ..write(obj.categoriaId)
      ..writeByte(3)
      ..write(obj.descripcion)
      ..writeByte(4)
      ..write(obj.requisitos)
      ..writeByte(5)
      ..write(obj.dondeHacerlo)
      ..writeByte(6)
      ..write(obj.horarios)
      ..writeByte(7)
      ..write(obj.costoCup)
      ..writeByte(8)
      ..write(obj.plazoDias)
      ..writeByte(9)
      ..write(obj.imagenUrl)
      ..writeByte(10)
      ..write(obj.fechaActualizacion);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TramiteAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

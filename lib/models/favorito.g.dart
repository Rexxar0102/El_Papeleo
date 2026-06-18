// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'favorito.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FavoritoAdapter extends TypeAdapter<Favorito> {
  @override
  final int typeId = 4;

  @override
  Favorito read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Favorito(
      tramiteId: fields[0] as String,
      fechaAgregado: fields[1] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, Favorito obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.tramiteId)
      ..writeByte(1)
      ..write(obj.fechaAgregado);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FavoritoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

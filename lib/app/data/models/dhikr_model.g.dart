// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dhikr_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DhikrModelAdapter extends TypeAdapter<DhikrModel> {
  @override
  final int typeId = 0;

  @override
  DhikrModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DhikrModel(
      id: fields[0] as String,
      arabicText: fields[1] as String,
      persianTranslation: fields[2] as String,
      meaning: fields[3] as String,
      category: fields[4] as String,
      defaultCount: fields[5] as int,
      isFavorite: fields[6] as bool,
      createdAt: fields[7] as DateTime,
      updatedAt: fields[8] as DateTime,
      audioPath: fields[9] as String?,
      tags: (fields[10] as List).cast<String>(),
      priority: fields[11] as int,
      isCustom: fields[12] as bool,
      overallGoal: fields[13] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, DhikrModel obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.arabicText)
      ..writeByte(2)
      ..write(obj.persianTranslation)
      ..writeByte(3)
      ..write(obj.meaning)
      ..writeByte(4)
      ..write(obj.category)
      ..writeByte(5)
      ..write(obj.defaultCount)
      ..writeByte(6)
      ..write(obj.isFavorite)
      ..writeByte(7)
      ..write(obj.createdAt)
      ..writeByte(8)
      ..write(obj.updatedAt)
      ..writeByte(9)
      ..write(obj.audioPath)
      ..writeByte(10)
      ..write(obj.tags)
      ..writeByte(11)
      ..write(obj.priority)
      ..writeByte(12)
      ..write(obj.isCustom)
      ..writeByte(13)
      ..write(obj.overallGoal);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DhikrModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

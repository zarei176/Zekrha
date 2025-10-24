// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dhikr_session_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DhikrSessionModelAdapter extends TypeAdapter<DhikrSessionModel> {
  @override
  final int typeId = 1;

  @override
  DhikrSessionModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DhikrSessionModel(
      id: fields[0] as String,
      dhikrId: fields[1] as String,
      targetCount: fields[2] as int,
      currentCount: fields[3] as int,
      startTime: fields[4] as DateTime,
      endTime: fields[5] as DateTime?,
      isCompleted: fields[6] as bool,
      duration: fields[7] as Duration,
      date: fields[8] as DateTime,
      clickTimes: (fields[9] as List).cast<DateTime>(),
      metadata: (fields[10] as Map).cast<String, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, DhikrSessionModel obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.dhikrId)
      ..writeByte(2)
      ..write(obj.targetCount)
      ..writeByte(3)
      ..write(obj.currentCount)
      ..writeByte(4)
      ..write(obj.startTime)
      ..writeByte(5)
      ..write(obj.endTime)
      ..writeByte(6)
      ..write(obj.isCompleted)
      ..writeByte(7)
      ..write(obj.duration)
      ..writeByte(8)
      ..write(obj.date)
      ..writeByte(9)
      ..write(obj.clickTimes)
      ..writeByte(10)
      ..write(obj.metadata);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DhikrSessionModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

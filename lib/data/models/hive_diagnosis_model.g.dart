// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hive_diagnosis_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HiveDiagnosisModelAdapter extends TypeAdapter<HiveDiagnosisModel> {
  @override
  final int typeId = 0;

  @override
  HiveDiagnosisModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HiveDiagnosisModel(
      result: fields[0] as String,
      confidence: fields[1] as double,
      symptoms: (fields[2] as List).cast<String>(),
      recommendations: (fields[3] as List).cast<String>(),
      createdAt: fields[4] as DateTime,
      userId: fields[5] as String,
      
    );
  }

  @override
  void write(BinaryWriter writer, HiveDiagnosisModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.result)
      ..writeByte(1)
      ..write(obj.confidence)
      ..writeByte(2)
      ..write(obj.symptoms)
      ..writeByte(3)
      ..write(obj.recommendations)
      ..writeByte(4)
      ..write(obj.createdAt)
      ..writeByte(5)
      ..write(obj.userId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HiveDiagnosisModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

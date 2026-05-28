// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'model_transaction.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ModelTransactionAdapter extends TypeAdapter<Model_Transaction> {
  @override
  final int typeId = 0;

  @override
  Model_Transaction read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Model_Transaction(
      id: fields[0] as String,
      type: fields[1] as String,
      amount: fields[2] as double,
      category: fields[3] as String,
      date: fields[4] as DateTime,
      comment: fields[5] as String,
      dollarSum: fields[6] as double,
      balanceAtPoint: fields[7] as double?,
    );
  }

  @override
  void write(BinaryWriter writer, Model_Transaction obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.type)
      ..writeByte(2)
      ..write(obj.amount)
      ..writeByte(3)
      ..write(obj.category)
      ..writeByte(4)
      ..write(obj.date)
      ..writeByte(5)
      ..write(obj.comment)
      ..writeByte(6)
      ..write(obj.dollarSum)
      ..writeByte(7)
      ..write(obj.balanceAtPoint);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is ModelTransactionAdapter &&
              runtimeType == other.runtimeType &&
              typeId == other.typeId;
}


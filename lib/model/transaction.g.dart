// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TransactionAdapter extends TypeAdapter<Transaction> {
  @override
  final int typeId = 0;

  @override
  Transaction read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Transaction()
      ..senderName = fields[0] as String
      ..senderAddress = fields[1] as String
      ..receiverName = fields[2] as String
      ..receiverAddress = fields[3] as String
      ..createdDate = fields[4] as DateTime
      ..isRegistered = fields[5] as bool
      ..value = fields[6] as double
      ..content = fields[7] as String;
  }

  @override
  void write(BinaryWriter writer, Transaction obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.senderName)
      ..writeByte(1)
      ..write(obj.senderAddress)
      ..writeByte(2)
      ..write(obj.receiverName)
      ..writeByte(3)
      ..write(obj.receiverAddress)
      ..writeByte(4)
      ..write(obj.createdDate)
      ..writeByte(5)
      ..write(obj.isRegistered)
      ..writeByte(6)
      ..write(obj.value)
      ..writeByte(7)
      ..write(obj.content);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransactionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

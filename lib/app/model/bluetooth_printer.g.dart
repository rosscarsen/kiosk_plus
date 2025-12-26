// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bluetooth_printer.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BluetoothPrinterAdapter extends TypeAdapter<BluetoothPrinter> {
  @override
  final typeId = 10;

  @override
  BluetoothPrinter read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BluetoothPrinter(
      deviceName: fields[0] as String?,
      address: fields[1] as String?,
      port: fields[2] == null ? '9100' : fields[2] as String?,
      vendorId: fields[3] as String?,
      productId: fields[4] as String?,
      isBle: fields[5] == null ? false : fields[5] as bool?,
      state: fields[6] as bool?,
    );
  }

  @override
  void write(BinaryWriter writer, BluetoothPrinter obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.deviceName)
      ..writeByte(1)
      ..write(obj.address)
      ..writeByte(2)
      ..write(obj.port)
      ..writeByte(3)
      ..write(obj.vendorId)
      ..writeByte(4)
      ..write(obj.productId)
      ..writeByte(5)
      ..write(obj.isBle)
      ..writeByte(6)
      ..write(obj.state);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BluetoothPrinterAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

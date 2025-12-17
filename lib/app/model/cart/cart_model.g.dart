// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cart_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CartModelAdapter extends TypeAdapter<CartModel> {
  @override
  final typeId = 8;

  @override
  CartModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CartModel(
      product: fields[1] as Product?,
      remarkList: (fields[2] as List?)?.cast<ProductRemark>(),
      setMealList: (fields[3] as List?)?.cast<SetMealList>(),
    );
  }

  @override
  void write(BinaryWriter writer, CartModel obj) {
    writer
      ..writeByte(3)
      ..writeByte(1)
      ..write(obj.product)
      ..writeByte(2)
      ..write(obj.remarkList)
      ..writeByte(3)
      ..write(obj.setMealList);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CartModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SetMealListAdapter extends TypeAdapter<SetMealList> {
  @override
  final typeId = 9;

  @override
  SetMealList read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SetMealList(
      tProductId: (fields[1] as num?)?.toInt(),
      mName: fields[2] as String?,
      mBarcode: fields[3] as String?,
      mPrice: fields[4] as String?,
      mPrice2: fields[5] as String?,
      mQty: fields[6] as String?,
      mRemarks: fields[7] as String?,
      mProductCode: fields[8] as String?,
      mId: (fields[9] as num?)?.toInt(),
      mFlag: (fields[10] as num?)?.toInt(),
      mTime: fields[11] as String?,
      mPCode: fields[12] as String?,
      mStep: (fields[13] as num?)?.toInt(),
      mDefault: (fields[14] as num?)?.toInt(),
      mSort: (fields[15] as num?)?.toInt(),
      soldOut: (fields[16] as num?)?.toInt(),
    );
  }

  @override
  void write(BinaryWriter writer, SetMealList obj) {
    writer
      ..writeByte(16)
      ..writeByte(1)
      ..write(obj.tProductId)
      ..writeByte(2)
      ..write(obj.mName)
      ..writeByte(3)
      ..write(obj.mBarcode)
      ..writeByte(4)
      ..write(obj.mPrice)
      ..writeByte(5)
      ..write(obj.mPrice2)
      ..writeByte(6)
      ..write(obj.mQty)
      ..writeByte(7)
      ..write(obj.mRemarks)
      ..writeByte(8)
      ..write(obj.mProductCode)
      ..writeByte(9)
      ..write(obj.mId)
      ..writeByte(10)
      ..write(obj.mFlag)
      ..writeByte(11)
      ..write(obj.mTime)
      ..writeByte(12)
      ..write(obj.mPCode)
      ..writeByte(13)
      ..write(obj.mStep)
      ..writeByte(14)
      ..write(obj.mDefault)
      ..writeByte(15)
      ..write(obj.mSort)
      ..writeByte(16)
      ..write(obj.soldOut);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SetMealListAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

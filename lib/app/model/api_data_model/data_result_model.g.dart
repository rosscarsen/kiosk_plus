// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'data_result_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DataResultModelAdapter extends TypeAdapter<DataResultModel> {
  @override
  final typeId = 3;

  @override
  DataResultModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DataResultModel(
      calendarDiscount: fields[1] as String?,
      categoryTreeProduct: (fields[2] as List?)?.cast<CategoryTreeProduct>(),
      productRemarks: (fields[3] as List?)?.cast<ProductRemark>(),
      productSetMeal: (fields[4] as List?)?.cast<ProductSetMeal>(),
      productSetMealLimit: (fields[5] as List?)?.cast<ProductSetMealLimit>(),
      companyInfo: fields[6] as CompanyInfo?,
    );
  }

  @override
  void write(BinaryWriter writer, DataResultModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(1)
      ..write(obj.calendarDiscount)
      ..writeByte(2)
      ..write(obj.categoryTreeProduct)
      ..writeByte(3)
      ..write(obj.productRemarks)
      ..writeByte(4)
      ..write(obj.productSetMeal)
      ..writeByte(5)
      ..write(obj.productSetMealLimit)
      ..writeByte(6)
      ..write(obj.companyInfo);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DataResultModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class CompanyInfoAdapter extends TypeAdapter<CompanyInfo> {
  @override
  final typeId = 9;

  @override
  CompanyInfo read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CompanyInfo(
      mNameEnglish: fields[1] as String?,
      mNameChinese: fields[2] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, CompanyInfo obj) {
    writer
      ..writeByte(2)
      ..writeByte(1)
      ..write(obj.mNameEnglish)
      ..writeByte(2)
      ..write(obj.mNameChinese);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CompanyInfoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class CategoryTreeProductAdapter extends TypeAdapter<CategoryTreeProduct> {
  @override
  final typeId = 4;

  @override
  CategoryTreeProduct read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CategoryTreeProduct(
      mCategory: fields[1] as String?,
      mParent: fields[2] as String?,
      mDescription: fields[3] as String?,
      tCategoryId: (fields[4] as num?)?.toInt(),
      mSort: (fields[5] as num?)?.toInt(),
      children: (fields[6] as List?)?.cast<CategoryTreeProduct>(),
      products: (fields[7] as List?)?.cast<Product>(),
    );
  }

  @override
  void write(BinaryWriter writer, CategoryTreeProduct obj) {
    writer
      ..writeByte(7)
      ..writeByte(1)
      ..write(obj.mCategory)
      ..writeByte(2)
      ..write(obj.mParent)
      ..writeByte(3)
      ..write(obj.mDescription)
      ..writeByte(4)
      ..write(obj.tCategoryId)
      ..writeByte(5)
      ..write(obj.mSort)
      ..writeByte(6)
      ..write(obj.children)
      ..writeByte(7)
      ..write(obj.products);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CategoryTreeProductAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ProductAdapter extends TypeAdapter<Product> {
  @override
  final typeId = 5;

  @override
  Product read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Product(
      mCode: fields[1] as String?,
      mDesc1: fields[2] as String?,
      mDesc2: fields[3] as String?,
      mRemarks: fields[4] as String?,
      mCategory1: fields[5] as String?,
      mCategory2: fields[6] as String?,
      mCategory3: fields[7] as String?,
      tProductId: (fields[8] as num?)?.toInt(),
      mPrice: fields[9] as String?,
      mSoldOut: (fields[10] as num?)?.toInt(),
      productRemarks: fields[11] as String?,
      imagesPath: fields[12] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Product obj) {
    writer
      ..writeByte(12)
      ..writeByte(1)
      ..write(obj.mCode)
      ..writeByte(2)
      ..write(obj.mDesc1)
      ..writeByte(3)
      ..write(obj.mDesc2)
      ..writeByte(4)
      ..write(obj.mRemarks)
      ..writeByte(5)
      ..write(obj.mCategory1)
      ..writeByte(6)
      ..write(obj.mCategory2)
      ..writeByte(7)
      ..write(obj.mCategory3)
      ..writeByte(8)
      ..write(obj.tProductId)
      ..writeByte(9)
      ..write(obj.mPrice)
      ..writeByte(10)
      ..write(obj.mSoldOut)
      ..writeByte(11)
      ..write(obj.productRemarks)
      ..writeByte(12)
      ..write(obj.imagesPath);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ProductSetMealAdapter extends TypeAdapter<ProductSetMeal> {
  @override
  final typeId = 6;

  @override
  ProductSetMeal read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ProductSetMeal(
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
  void write(BinaryWriter writer, ProductSetMeal obj) {
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
      other is ProductSetMealAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ProductRemarkAdapter extends TypeAdapter<ProductRemark> {
  @override
  final typeId = 8;

  @override
  ProductRemark read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ProductRemark(
      mId: (fields[1] as num?)?.toInt(),
      mDetail: fields[2] as String?,
      mPrice: fields[3] as String?,
      mRemark: fields[4] as String?,
      tId: (fields[5] as num?)?.toInt(),
      mOverwrite: (fields[6] as num?)?.toInt(),
      mSort: fields[7] as dynamic,
      mRemarkType: (fields[8] as num?)?.toInt(),
      mSoldOut: (fields[9] as num?)?.toInt(),
      mType: (fields[10] as num?)?.toInt(),
    );
  }

  @override
  void write(BinaryWriter writer, ProductRemark obj) {
    writer
      ..writeByte(10)
      ..writeByte(1)
      ..write(obj.mId)
      ..writeByte(2)
      ..write(obj.mDetail)
      ..writeByte(3)
      ..write(obj.mPrice)
      ..writeByte(4)
      ..write(obj.mRemark)
      ..writeByte(5)
      ..write(obj.tId)
      ..writeByte(6)
      ..write(obj.mOverwrite)
      ..writeByte(7)
      ..write(obj.mSort)
      ..writeByte(8)
      ..write(obj.mRemarkType)
      ..writeByte(9)
      ..write(obj.mSoldOut)
      ..writeByte(10)
      ..write(obj.mType);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductRemarkAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ProductSetMealLimitAdapter extends TypeAdapter<ProductSetMealLimit> {
  @override
  final typeId = 7;

  @override
  ProductSetMealLimit read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ProductSetMealLimit(
      setLimitId: (fields[1] as num?)?.toInt(),
      tProductId: (fields[2] as num?)?.toInt(),
      mStep: (fields[3] as num?)?.toInt(),
      limitMax: (fields[4] as num?)?.toInt(),
      obligatory: (fields[5] as num?)?.toInt(),
      zhtw: fields[6] as String?,
      enus: fields[7] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ProductSetMealLimit obj) {
    writer
      ..writeByte(7)
      ..writeByte(1)
      ..write(obj.setLimitId)
      ..writeByte(2)
      ..write(obj.tProductId)
      ..writeByte(3)
      ..write(obj.mStep)
      ..writeByte(4)
      ..write(obj.limitMax)
      ..writeByte(5)
      ..write(obj.obligatory)
      ..writeByte(6)
      ..write(obj.zhtw)
      ..writeByte(7)
      ..write(obj.enus);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductSetMealLimitAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

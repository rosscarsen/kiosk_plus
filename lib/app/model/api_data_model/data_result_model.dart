// To parse this JSON data, do
//
//     final dataResultModel = dataResultModelFromJson(jsonString);

import 'dart:convert';

import 'package:hive_ce/hive.dart';

import '../../../hive_type_ids.dart';

part 'data_result_model.g.dart';

DataResultModel dataResultModelFromJson(String str) => DataResultModel.fromJson(json.decode(str));

String dataResultModelToJson(DataResultModel data) => json.encode(data.toJson());

@HiveType(typeId: HiveTypeIds.dataResultModel)
class DataResultModel {
  @HiveField(1)
  final String? calendarDiscount;
  @HiveField(2)
  final List<CategoryTreeProduct>? categoryTreeProduct;
  @HiveField(3)
  final List<ProductRemark>? productRemarks;
  @HiveField(4)
  final List<ProductSetMeal>? productSetMeal;
  @HiveField(5)
  final List<ProductSetMealLimit>? productSetMealLimit;
  @HiveField(6)
  final CompanyInfo? companyInfo;

  DataResultModel({
    this.calendarDiscount,
    this.categoryTreeProduct,
    this.productRemarks,
    this.productSetMeal,
    this.productSetMealLimit,
    this.companyInfo,
  });

  factory DataResultModel.fromJson(Map<String, dynamic> json) => DataResultModel(
    calendarDiscount: json["calendarDiscount"],
    categoryTreeProduct: json["categoryTreeProduct"] == null
        ? []
        : List<CategoryTreeProduct>.from(json["categoryTreeProduct"]!.map((x) => CategoryTreeProduct.fromJson(x))),
    productRemarks: json["productRemarks"] == null
        ? []
        : List<ProductRemark>.from(json["productRemarks"]!.map((x) => ProductRemark.fromJson(x))),
    productSetMeal: json["productSetMeal"] == null
        ? []
        : List<ProductSetMeal>.from(json["productSetMeal"]!.map((x) => ProductSetMeal.fromJson(x))),
    productSetMealLimit: json["productSetMealLimit"] == null
        ? []
        : List<ProductSetMealLimit>.from(json["productSetMealLimit"]!.map((x) => ProductSetMealLimit.fromJson(x))),
    companyInfo: json["companyInfo"] == null ? null : CompanyInfo.fromJson(json["companyInfo"]),
  );

  Map<String, dynamic> toJson() => {
    "calendarDiscount": calendarDiscount,
    "companyInfo": companyInfo?.toJson(),
    "categoryTreeProduct": categoryTreeProduct == null
        ? []
        : List<dynamic>.from(categoryTreeProduct!.map((x) => x.toJson())),
    "productRemarks": productRemarks == null ? [] : List<dynamic>.from(productRemarks!.map((x) => x.toJson())),
    "productSetMeal": productSetMeal == null ? [] : List<dynamic>.from(productSetMeal!.map((x) => x.toJson())),
    "productSetMealLimit": productSetMealLimit == null
        ? []
        : List<dynamic>.from(productSetMealLimit!.map((x) => x.toJson())),
  };
}

@HiveType(typeId: HiveTypeIds.company)
class CompanyInfo {
  @HiveField(1)
  final String? mNameEnglish;
  @HiveField(2)
  final String? mNameChinese;

  CompanyInfo({this.mNameEnglish, this.mNameChinese});

  factory CompanyInfo.fromJson(Map<String, dynamic> json) =>
      CompanyInfo(mNameEnglish: json["mName_English"], mNameChinese: json["mName_Chinese"]);

  Map<String, dynamic> toJson() => {"mName_English": mNameEnglish, "mName_Chinese": mNameChinese};
}

@HiveType(typeId: HiveTypeIds.catProductTreeModel)
class CategoryTreeProduct {
  @HiveField(1)
  final String? mCategory;
  @HiveField(2)
  final String? mParent;
  @HiveField(3)
  final String? mDescription;
  @HiveField(4)
  final int? tCategoryId;
  @HiveField(5)
  final int? mSort;
  @HiveField(6)
  final List<CategoryTreeProduct>? children;
  @HiveField(7)
  final List<Product>? products;

  CategoryTreeProduct({
    this.mCategory,
    this.mParent,
    this.mDescription,
    this.tCategoryId,
    this.mSort,
    this.children,
    this.products,
  });

  factory CategoryTreeProduct.fromJson(Map<String, dynamic> json) => CategoryTreeProduct(
    mCategory: json["mCategory"],
    mParent: json["mParent"],
    mDescription: json["mDescription"],
    tCategoryId: json["T_Category_ID"],
    mSort: json["mSort"],
    children: json["children"] == null
        ? []
        : List<CategoryTreeProduct>.from(json["children"]!.map((x) => CategoryTreeProduct.fromJson(x))),
    products: json["products"] == null ? [] : List<Product>.from(json["products"]!.map((x) => Product.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "mCategory": mCategory,
    "mParent": mParent,
    "mDescription": mDescription,
    "T_Category_ID": tCategoryId,
    "mSort": mSort,
    "children": children == null ? [] : List<dynamic>.from(children!.map((x) => x.toJson())),
    "products": products == null ? [] : List<dynamic>.from(products!.map((x) => x.toJson())),
  };
}

@HiveType(typeId: HiveTypeIds.productModel)
class Product {
  @HiveField(1)
  final String? mCode;
  @HiveField(2)
  final String? mDesc1;
  @HiveField(3)
  final String? mDesc2;
  @HiveField(4)
  final String? mRemarks;
  @HiveField(5)
  final String? mCategory1;
  @HiveField(6)
  final String? mCategory2;
  @HiveField(7)
  final String? mCategory3;
  @HiveField(8)
  final int? tProductId;
  @HiveField(9)
  final String? mPrice;
  @HiveField(10)
  final int? mSoldOut;
  @HiveField(11)
  final String? productRemarks;
  @HiveField(12)
  final String? imagesPath;

  Product({
    this.mCode,
    this.mDesc1,
    this.mDesc2,
    this.mRemarks,
    this.mCategory1,
    this.mCategory2,
    this.mCategory3,
    this.tProductId,
    this.mPrice,
    this.mSoldOut,
    this.productRemarks,
    this.imagesPath,
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
    mCode: json["mCode"],
    mDesc1: json["mDesc1"],
    mDesc2: json["mDesc2"],
    mRemarks: json["mRemarks"],
    mCategory1: json["mCategory1"],
    mCategory2: json["mCategory2"],
    mCategory3: json["mCategory3"],
    tProductId: json["T_Product_ID"],
    mPrice: json["mPrice"],
    mSoldOut: json["mSoldOut"],
    productRemarks: json["productRemarks"],
    imagesPath: json["imagesPath"],
  );

  Map<String, dynamic> toJson() => {
    "mCode": mCode,
    "mDesc1": mDesc1,
    "mDesc2": mDesc2,
    "mRemarks": mRemarks,
    "mCategory1": mCategory1,
    "mCategory2": mCategory2,
    "mCategory3": mCategory3,
    "T_Product_ID": tProductId,
    "mPrice": mPrice,
    "mSoldOut": mSoldOut,
    "productRemarks": productRemarks,
    "imagesPath": imagesPath,
  };
}

@HiveType(typeId: HiveTypeIds.productSetMealModel)
class ProductSetMeal {
  @HiveField(1)
  final int? tProductId;
  @HiveField(2)
  final String? mName;
  @HiveField(3)
  final String? mBarcode;
  @HiveField(4)
  final String? mPrice;
  @HiveField(5)
  final String? mPrice2;
  @HiveField(6)
  final String? mQty;
  @HiveField(7)
  final String? mRemarks;
  @HiveField(8)
  final String? mProductCode;
  @HiveField(9)
  final int? mId;
  @HiveField(10)
  final int? mFlag;
  @HiveField(11)
  final String? mTime;
  @HiveField(12)
  final String? mPCode;
  @HiveField(13)
  final int? mStep;
  @HiveField(14)
  final int? mDefault;
  @HiveField(15)
  final int? mSort;
  @HiveField(16)
  final int? soldOut;

  ProductSetMeal({
    this.tProductId,
    this.mName,
    this.mBarcode,
    this.mPrice,
    this.mPrice2,
    this.mQty,
    this.mRemarks,
    this.mProductCode,
    this.mId,
    this.mFlag,
    this.mTime,
    this.mPCode,
    this.mStep,
    this.mDefault,
    this.mSort,
    this.soldOut,
  });

  factory ProductSetMeal.fromJson(Map<String, dynamic> json) => ProductSetMeal(
    tProductId: json["T_Product_ID"],
    mName: json["mName"],
    mBarcode: json["mBarcode"],
    mPrice: json["mPrice"],
    mPrice2: json["mPrice2"],
    mQty: json["mQty"],
    mRemarks: json["mRemarks"],
    mProductCode: json["mProduct_Code"],
    mId: json["mID"],
    mFlag: json["mFlag"],
    mTime: json["mTime"],
    mPCode: json["mPCode"],
    mStep: json["mStep"],
    mDefault: json["mDefault"],
    mSort: json["mSort"],
    soldOut: json["Sold_out"],
  );

  Map<String, dynamic> toJson() => {
    "T_Product_ID": tProductId,
    "mName": mName,
    "mBarcode": mBarcode,
    "mPrice": mPrice,
    "mPrice2": mPrice2,
    "mQty": mQty,
    "mRemarks": mRemarks,
    "mProduct_Code": mProductCode,
    "mID": mId,
    "mFlag": mFlag,
    "mTime": mTime,
    "mPCode": mPCode,
    "mStep": mStep,
    "mDefault": mDefault,
    "mSort": mSort,
    "Sold_out": soldOut,
  };
}

@HiveType(typeId: HiveTypeIds.productRemarksModel)
class ProductRemark {
  @HiveField(1)
  final int? mId;
  @HiveField(2)
  final String? mDetail;
  @HiveField(3)
  final String? mPrice;
  @HiveField(4)
  final String? mRemark;
  @HiveField(5)
  final int? tId;
  @HiveField(6)
  final int? mOverwrite;
  @HiveField(7)
  final dynamic mSort;
  @HiveField(8)
  final int? mRemarkType;
  @HiveField(9)
  final int? mSoldOut;
  @HiveField(10)
  final int? mType;

  ProductRemark({
    this.mId,
    this.mDetail,
    this.mPrice,
    this.mRemark,
    this.tId,
    this.mOverwrite,
    this.mSort,
    this.mRemarkType,
    this.mSoldOut,
    this.mType,
  });

  factory ProductRemark.fromJson(Map<String, dynamic> json) => ProductRemark(
    mId: json["m_id"],
    mDetail: json["m_detail"],
    mPrice: json["m_price"],
    mRemark: json["m_remark"],
    tId: json["t_id"],
    mOverwrite: json["mOverwrite"],
    mSort: json["mSort"],
    mRemarkType: json["mRemark_Type"],
    mSoldOut: json["mSoldOut"],
    mType: json["m_type"],
  );

  Map<String, dynamic> toJson() => {
    "m_id": mId,
    "m_detail": mDetail,
    "m_price": mPrice,
    "m_remark": mRemark,
    "t_id": tId,
    "mOverwrite": mOverwrite,
    "mSort": mSort,
    "mRemark_Type": mRemarkType,
    "mSoldOut": mSoldOut,
    "m_type": mType,
  };
}

@HiveType(typeId: HiveTypeIds.productSetMealLimitModel)
class ProductSetMealLimit {
  @HiveField(1)
  final int? setLimitId;
  @HiveField(2)
  final int? tProductId;
  @HiveField(3)
  final int? mStep;
  @HiveField(4)
  final int? limitMax;
  @HiveField(5)
  final int? obligatory;
  @HiveField(6)
  final String? zhtw;
  @HiveField(7)
  final String? enus;

  ProductSetMealLimit({
    this.setLimitId,
    this.tProductId,
    this.mStep,
    this.limitMax,
    this.obligatory,
    this.zhtw,
    this.enus,
  });

  factory ProductSetMealLimit.fromJson(Map<String, dynamic> json) => ProductSetMealLimit(
    setLimitId: json["set_limit_id"],
    tProductId: json["t_product_id"],
    mStep: json["mStep"],
    limitMax: json["limit_max"],
    obligatory: json["obligatory"],
    zhtw: json["zhtw"],
    enus: json["enus"],
  );

  Map<String, dynamic> toJson() => {
    "set_limit_id": setLimitId,
    "t_product_id": tProductId,
    "mStep": mStep,
    "limit_max": limitMax,
    "obligatory": obligatory,
    "zhtw": zhtw,
    "enus": enus,
  };
}

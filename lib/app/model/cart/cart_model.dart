// To parse this JSON data, do
//
//     final cartModel = cartModelFromJson(jsonString);

import 'dart:convert';

import 'package:hive_ce/hive.dart';

import '../../../hive_type_ids.dart';
import '../api_data_model/data_result_model.dart';

part 'cart_model.g.dart';

List<CartModel> cartModelFromJson(String str) =>
    List<CartModel>.from(json.decode(str).map((x) => CartModel.fromJson(x)));

String cartModelToJson(List<CartModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

@HiveType(typeId: HiveTypeIds.cartModel)
class CartModel {
  @HiveField(1)
  final Product? product;
  @HiveField(2)
  final List<ProductRemark>? remarkList;
  @HiveField(3)
  final List<SetMealList>? setMealList;

  CartModel({this.product, this.remarkList, this.setMealList});

  factory CartModel.fromJson(Map<String, dynamic> json) => CartModel(
    product: json["product"] == null ? null : Product.fromJson(json["product"]),
    remarkList: json["remarkList"] == null
        ? []
        : List<ProductRemark>.from(json["remarkList"]!.map((x) => ProductRemark.fromJson(x))),
    setMealList: json["setMealList"] == null
        ? []
        : List<SetMealList>.from(json["setMealList"]!.map((x) => SetMealList.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "product": product?.toJson(),
    "remarkList": remarkList == null ? [] : List<dynamic>.from(remarkList!.map((x) => x.toJson())),
    "setMealList": setMealList == null ? [] : List<dynamic>.from(setMealList!.map((x) => x.toJson())),
  };
}

@HiveType(typeId: HiveTypeIds.setMealList)
class SetMealList {
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

  SetMealList({
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

  factory SetMealList.fromJson(Map<String, dynamic> json) => SetMealList(
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

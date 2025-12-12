// To parse this JSON data, do
//
//     final singleProductExtraInfoModel = singleProductExtraInfoModelFromJson(jsonString);

import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

part 'single_product_extra_info_model.g.dart';

List<SingleProductExtraInfoModel> singleProductExtraInfoModelFromJson(String str) =>
    List<SingleProductExtraInfoModel>.from(json.decode(str).map((x) => SingleProductExtraInfoModel.fromJson(x)));

String singleProductExtraInfoModelToJson(List<SingleProductExtraInfoModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

@JsonSerializable(explicitToJson: true)
class SingleProductExtraInfoModel {
  @JsonKey(name: "setMealLimit")
  final SetMealLimit? setMealLimit;

  SingleProductExtraInfoModel({this.setMealLimit});

  factory SingleProductExtraInfoModel.fromJson(Map<String, dynamic> json) =>
      _$SingleProductExtraInfoModelFromJson(json);

  Map<String, dynamic> toJson() => _$SingleProductExtraInfoModelToJson(this);
}

@JsonSerializable(explicitToJson: true)
class SetMealLimit {
  @JsonKey(name: "set_limit_id")
  final int? setLimitId;
  @JsonKey(name: "t_product_id")
  final int? tProductId;
  @JsonKey(name: "mStep")
  final int? mStep;
  @JsonKey(name: "limit_max")
  final int? limitMax;
  @JsonKey(name: "obligatory")
  final int? obligatory;
  @JsonKey(name: "zhtw")
  final String? zhtw;
  @JsonKey(name: "enus")
  final String? enus;
  @JsonKey(name: "setMealData")
  final List<SetMealDatum>? setMealData;

  SetMealLimit({
    this.setLimitId,
    this.tProductId,
    this.mStep,
    this.limitMax,
    this.obligatory,
    this.zhtw,
    this.enus,
    this.setMealData,
  });

  factory SetMealLimit.fromJson(Map<String, dynamic> json) => _$SetMealLimitFromJson(json);

  Map<String, dynamic> toJson() => _$SetMealLimitToJson(this);
}

@JsonSerializable(explicitToJson: true)
class SetMealDatum {
  @JsonKey(name: "T_Product_ID")
  final int? tProductId;
  @JsonKey(name: "mName")
  final String? mName;
  @JsonKey(name: "mBarcode")
  final String? mBarcode;
  @JsonKey(name: "mPrice")
  final String? mPrice;
  @JsonKey(name: "mPrice2")
  final String? mPrice2;
  @JsonKey(name: "mQty")
  final String? mQty;
  @JsonKey(name: "mRemarks")
  final String? mRemarks;
  @JsonKey(name: "mProduct_Code")
  final String? mProductCode;
  @JsonKey(name: "mID")
  final int? mId;
  @JsonKey(name: "mFlag")
  final int? mFlag;
  @JsonKey(name: "mTime")
  final String? mTime;
  @JsonKey(name: "mPCode")
  final String? mPCode;
  @JsonKey(name: "mStep")
  final int? mStep;
  @JsonKey(name: "mDefault")
  final int? mDefault;
  @JsonKey(name: "mSort")
  final int? mSort;
  @JsonKey(name: "Sold_out")
  final int? soldOut;

  SetMealDatum({
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

  factory SetMealDatum.fromJson(Map<String, dynamic> json) => _$SetMealDatumFromJson(json);

  Map<String, dynamic> toJson() => _$SetMealDatumToJson(this);
}

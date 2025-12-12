// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'single_product_extra_info_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SingleProductExtraInfoModel _$SingleProductExtraInfoModelFromJson(
  Map<String, dynamic> json,
) => SingleProductExtraInfoModel(
  setMealLimit: json['setMealLimit'] == null
      ? null
      : SetMealLimit.fromJson(json['setMealLimit'] as Map<String, dynamic>),
);

Map<String, dynamic> _$SingleProductExtraInfoModelToJson(
  SingleProductExtraInfoModel instance,
) => <String, dynamic>{'setMealLimit': instance.setMealLimit?.toJson()};

SetMealLimit _$SetMealLimitFromJson(Map<String, dynamic> json) => SetMealLimit(
  setLimitId: (json['set_limit_id'] as num?)?.toInt(),
  tProductId: (json['t_product_id'] as num?)?.toInt(),
  mStep: (json['mStep'] as num?)?.toInt(),
  limitMax: (json['limit_max'] as num?)?.toInt(),
  obligatory: (json['obligatory'] as num?)?.toInt(),
  zhtw: json['zhtw'] as String?,
  enus: json['enus'] as String?,
  setMealData: (json['setMealData'] as List<dynamic>?)
      ?.map((e) => SetMealDatum.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$SetMealLimitToJson(SetMealLimit instance) =>
    <String, dynamic>{
      'set_limit_id': instance.setLimitId,
      't_product_id': instance.tProductId,
      'mStep': instance.mStep,
      'limit_max': instance.limitMax,
      'obligatory': instance.obligatory,
      'zhtw': instance.zhtw,
      'enus': instance.enus,
      'setMealData': instance.setMealData?.map((e) => e.toJson()).toList(),
    };

SetMealDatum _$SetMealDatumFromJson(Map<String, dynamic> json) => SetMealDatum(
  tProductId: (json['T_Product_ID'] as num?)?.toInt(),
  mName: json['mName'] as String?,
  mBarcode: json['mBarcode'] as String?,
  mPrice: json['mPrice'] as String?,
  mPrice2: json['mPrice2'] as String?,
  mQty: json['mQty'] as String?,
  mRemarks: json['mRemarks'] as String?,
  mProductCode: json['mProduct_Code'] as String?,
  mId: (json['mID'] as num?)?.toInt(),
  mFlag: (json['mFlag'] as num?)?.toInt(),
  mTime: json['mTime'] as String?,
  mPCode: json['mPCode'] as String?,
  mStep: (json['mStep'] as num?)?.toInt(),
  mDefault: (json['mDefault'] as num?)?.toInt(),
  mSort: (json['mSort'] as num?)?.toInt(),
  soldOut: (json['Sold_out'] as num?)?.toInt(),
);

Map<String, dynamic> _$SetMealDatumToJson(SetMealDatum instance) =>
    <String, dynamic>{
      'T_Product_ID': instance.tProductId,
      'mName': instance.mName,
      'mBarcode': instance.mBarcode,
      'mPrice': instance.mPrice,
      'mPrice2': instance.mPrice2,
      'mQty': instance.mQty,
      'mRemarks': instance.mRemarks,
      'mProduct_Code': instance.mProductCode,
      'mID': instance.mId,
      'mFlag': instance.mFlag,
      'mTime': instance.mTime,
      'mPCode': instance.mPCode,
      'mStep': instance.mStep,
      'mDefault': instance.mDefault,
      'mSort': instance.mSort,
      'Sold_out': instance.soldOut,
    };

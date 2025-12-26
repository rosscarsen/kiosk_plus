// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'receipt_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReceiptModel _$ReceiptModelFromJson(Map<String, dynamic> json) => ReceiptModel(
  company: json['company'] == null
      ? null
      : Company.fromJson(json['company'] as Map<String, dynamic>),
  invoice: json['invoice'] == null
      ? null
      : Invoice.fromJson(json['invoice'] as Map<String, dynamic>),
  invoiceDetail: (json['invoiceDetail'] as List<dynamic>?)
      ?.map((e) => InvoiceDetail.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$ReceiptModelToJson(ReceiptModel instance) =>
    <String, dynamic>{
      'company': instance.company,
      'invoice': instance.invoice,
      'invoiceDetail': instance.invoiceDetail,
    };

Company _$CompanyFromJson(Map<String, dynamic> json) => Company(
  mNameChinese: Functions.asString(json['mName_Chinese']),
  mNameEnglish: Functions.asString(json['mName_English']),
  mAddress: Functions.asString(json['mAddress']),
  mPointDisplay: Functions.asString(json['mPointDisplay']),
);

Map<String, dynamic> _$CompanyToJson(Company instance) => <String, dynamic>{
  'mName_Chinese': instance.mNameChinese,
  'mName_English': instance.mNameEnglish,
  'mAddress': instance.mAddress,
  'mPointDisplay': instance.mPointDisplay,
};

Invoice _$InvoiceFromJson(Map<String, dynamic> json) => Invoice(
  mInvoiceNo: Functions.asString(json['mInvoice_No']),
  mRemarks: Functions.asString(json['mRemarks']),
  mDeposit2: Functions.asString(json['mDeposit2']),
  mDeposit: Functions.asString(json['mDeposit']),
  mPayAmount: Functions.asString(json['mPayAmount']),
  mChange: Functions.asString(json['mChange']),
  mAmount: Functions.asString(json['mAmount']),
  mNetAmt: Functions.asString(json['mNet_Amt']),
  mDiscRate: Functions.asString(json['mDisc_Rate']),
  mDiscAmt: Functions.asString(json['mDisc_Amt']),
  mCharge: Functions.asString(json['mCharge']),
  tInvoiceId: Functions.asString(json['T_Invoice_ID']),
  mTableNo: Functions.asString(json['mTableNo']),
  mTableName: Functions.asString(json['mTableName']),
  mPnum: Functions.asString(json['mPnum']),
  mStationCode: Functions.asString(json['mStation_Code']),
  mSalesmanCode: Functions.asString(json['mSalesman_Code']),
  mPayType: Functions.asString(json['mPayType']),
  mCustomerCode: Functions.asString(json['mCustomer_Code']),
  mInvoiceDate: Functions.asString(json['mInvoice_Date']),
);

Map<String, dynamic> _$InvoiceToJson(Invoice instance) => <String, dynamic>{
  'mInvoice_No': instance.mInvoiceNo,
  'mRemarks': instance.mRemarks,
  'mDeposit2': instance.mDeposit2,
  'mDeposit': instance.mDeposit,
  'mPayAmount': instance.mPayAmount,
  'mChange': instance.mChange,
  'mAmount': instance.mAmount,
  'mNet_Amt': instance.mNetAmt,
  'mDisc_Rate': instance.mDiscRate,
  'mDisc_Amt': instance.mDiscAmt,
  'mCharge': instance.mCharge,
  'T_Invoice_ID': instance.tInvoiceId,
  'mTableNo': instance.mTableNo,
  'mTableName': instance.mTableName,
  'mPnum': instance.mPnum,
  'mStation_Code': instance.mStationCode,
  'mSalesman_Code': instance.mSalesmanCode,
  'mPayType': instance.mPayType,
  'mCustomer_Code': instance.mCustomerCode,
  'mInvoice_Date': instance.mInvoiceDate,
};

InvoiceDetail _$InvoiceDetailFromJson(Map<String, dynamic> json) =>
    InvoiceDetail(
      mPrintName: Functions.asString(json['mPrintName']),
      mQty: Functions.asString(json['mQty']),
      mAmount: Functions.asString(json['mAmount']),
      mRemarks: Functions.asString(json['mRemarks']),
    );

Map<String, dynamic> _$InvoiceDetailToJson(InvoiceDetail instance) =>
    <String, dynamic>{
      'mPrintName': instance.mPrintName,
      'mQty': instance.mQty,
      'mAmount': instance.mAmount,
      'mRemarks': instance.mRemarks,
    };

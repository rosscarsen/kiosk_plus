// To parse this JSON data, do
//
//     final receiptModel = receiptModelFromJson(jsonString);

import 'package:json_annotation/json_annotation.dart';
import 'dart:convert';

import '../utils/functions.dart';

part 'receipt_model.g.dart';

ReceiptModel receiptModelFromJson(String str) => ReceiptModel.fromJson(json.decode(str));

String receiptModelToJson(ReceiptModel data) => json.encode(data.toJson());

@JsonSerializable()
class ReceiptModel {
  @JsonKey(name: "company")
  final Company? company;
  @JsonKey(name: "invoice")
  final Invoice? invoice;
  @JsonKey(name: "invoiceDetail")
  final List<InvoiceDetail>? invoiceDetail;

  ReceiptModel({this.company, this.invoice, this.invoiceDetail});

  ReceiptModel copyWith({Company? company, Invoice? invoice, List<InvoiceDetail>? invoiceDetail}) => ReceiptModel(
    company: company ?? this.company,
    invoice: invoice ?? this.invoice,
    invoiceDetail: invoiceDetail ?? this.invoiceDetail,
  );

  factory ReceiptModel.fromJson(Map<String, dynamic> json) => _$ReceiptModelFromJson(json);

  Map<String, dynamic> toJson() => _$ReceiptModelToJson(this);
}

@JsonSerializable(explicitToJson: true)
class Company {
  @JsonKey(name: "mName_Chinese", fromJson: Functions.asString)
  final String? mNameChinese;
  @JsonKey(name: "mName_English", fromJson: Functions.asString)
  final String? mNameEnglish;
  @JsonKey(name: "mAddress", fromJson: Functions.asString)
  final String? mAddress;
  @JsonKey(name: "mPointDisplay", fromJson: Functions.asString)
  final String? mPointDisplay;

  Company({this.mNameChinese, this.mNameEnglish, this.mAddress, this.mPointDisplay});

  Company copyWith({String? mNameChinese, String? mNameEnglish, String? mAddress, String? mPointDisplay}) => Company(
    mNameChinese: mNameChinese ?? this.mNameChinese,
    mNameEnglish: mNameEnglish ?? this.mNameEnglish,
    mAddress: mAddress ?? this.mAddress,
    mPointDisplay: mPointDisplay ?? this.mPointDisplay,
  );

  factory Company.fromJson(Map<String, dynamic> json) => _$CompanyFromJson(json);

  Map<String, dynamic> toJson() => _$CompanyToJson(this);
}

@JsonSerializable(explicitToJson: true)
class Invoice {
  @JsonKey(name: "mInvoice_No", fromJson: Functions.asString)
  final String? mInvoiceNo;
  @JsonKey(name: "mRemarks", fromJson: Functions.asString)
  final String? mRemarks;
  @JsonKey(name: "mDeposit2", fromJson: Functions.asString)
  final String? mDeposit2;
  @JsonKey(name: "mDeposit", fromJson: Functions.asString)
  final String? mDeposit;
  @JsonKey(name: "mPayAmount", fromJson: Functions.asString)
  final String? mPayAmount;
  @JsonKey(name: "mChange", fromJson: Functions.asString)
  final String? mChange;
  @JsonKey(name: "mAmount", fromJson: Functions.asString)
  final String? mAmount;
  @JsonKey(name: "mNet_Amt", fromJson: Functions.asString)
  final String? mNetAmt;
  @JsonKey(name: "mDisc_Rate", fromJson: Functions.asString)
  final String? mDiscRate;
  @JsonKey(name: "mDisc_Amt", fromJson: Functions.asString)
  final String? mDiscAmt;
  @JsonKey(name: "mCharge", fromJson: Functions.asString)
  final String? mCharge;
  @JsonKey(name: "T_Invoice_ID", fromJson: Functions.asString)
  final String? tInvoiceId;
  @JsonKey(name: "mTableNo", fromJson: Functions.asString)
  final String? mTableNo;
  @JsonKey(name: "mTableName", fromJson: Functions.asString)
  final String? mTableName;
  @JsonKey(name: "mPnum", fromJson: Functions.asString)
  final String? mPnum;
  @JsonKey(name: "mStation_Code", fromJson: Functions.asString)
  final String? mStationCode;
  @JsonKey(name: "mSalesman_Code", fromJson: Functions.asString)
  final String? mSalesmanCode;
  @JsonKey(name: "mPayType", fromJson: Functions.asString)
  final String? mPayType;
  @JsonKey(name: "mCustomer_Code", fromJson: Functions.asString)
  final String? mCustomerCode;
  @JsonKey(name: "mInvoice_Date", fromJson: Functions.asString)
  final String? mInvoiceDate;

  Invoice({
    this.mInvoiceNo,
    this.mRemarks,
    this.mDeposit2,
    this.mDeposit,
    this.mPayAmount,
    this.mChange,
    this.mAmount,
    this.mNetAmt,
    this.mDiscRate,
    this.mDiscAmt,
    this.mCharge,
    this.tInvoiceId,
    this.mTableNo,
    this.mTableName,
    this.mPnum,
    this.mStationCode,
    this.mSalesmanCode,
    this.mPayType,
    this.mCustomerCode,
    this.mInvoiceDate,
  });

  Invoice copyWith({
    String? mInvoiceNo,
    String? mRemarks,
    String? mDeposit2,
    String? mDeposit,
    String? mPayAmount,
    String? mChange,
    String? mAmount,
    String? mNetAmt,
    String? mDiscRate,
    String? mDiscAmt,
    String? mCharge,
    String? tInvoiceId,
    String? mTableNo,
    String? mTableName,
    String? mPnum,
    String? mStationCode,
    String? mSalesmanCode,
    String? mPayType,
    String? mCustomerCode,
    String? mInvoiceDate,
  }) => Invoice(
    mInvoiceNo: mInvoiceNo ?? this.mInvoiceNo,
    mRemarks: mRemarks ?? this.mRemarks,
    mDeposit2: mDeposit2 ?? this.mDeposit2,
    mDeposit: mDeposit ?? this.mDeposit,
    mPayAmount: mPayAmount ?? this.mPayAmount,
    mChange: mChange ?? this.mChange,
    mAmount: mAmount ?? this.mAmount,
    mNetAmt: mNetAmt ?? this.mNetAmt,
    mDiscRate: mDiscRate ?? this.mDiscRate,
    mDiscAmt: mDiscAmt ?? this.mDiscAmt,
    mCharge: mCharge ?? this.mCharge,
    tInvoiceId: tInvoiceId ?? this.tInvoiceId,
    mTableNo: mTableNo ?? this.mTableNo,
    mTableName: mTableName ?? this.mTableName,
    mPnum: mPnum ?? this.mPnum,
    mStationCode: mStationCode ?? this.mStationCode,
    mSalesmanCode: mSalesmanCode ?? this.mSalesmanCode,
    mPayType: mPayType ?? this.mPayType,
    mCustomerCode: mCustomerCode ?? this.mCustomerCode,
    mInvoiceDate: mInvoiceDate ?? this.mInvoiceDate,
  );

  factory Invoice.fromJson(Map<String, dynamic> json) => _$InvoiceFromJson(json);

  Map<String, dynamic> toJson() => _$InvoiceToJson(this);
}

@JsonSerializable(explicitToJson: true)
class InvoiceDetail {
  @JsonKey(name: "mPrintName", fromJson: Functions.asString)
  final String? mPrintName;
  @JsonKey(name: "mQty", fromJson: Functions.asString)
  final String? mQty;
  @JsonKey(name: "mAmount", fromJson: Functions.asString)
  final String? mAmount;
  @JsonKey(name: "mRemarks", fromJson: Functions.asString)
  final String? mRemarks;

  InvoiceDetail({this.mPrintName, this.mQty, this.mAmount, this.mRemarks});

  InvoiceDetail copyWith({String? mPrintName, String? mQty, String? mAmount, String? mRemarks}) => InvoiceDetail(
    mPrintName: mPrintName ?? this.mPrintName,
    mQty: mQty ?? this.mQty,
    mAmount: mAmount ?? this.mAmount,
    mRemarks: mRemarks ?? this.mRemarks,
  );

  factory InvoiceDetail.fromJson(Map<String, dynamic> json) => _$InvoiceDetailFromJson(json);

  Map<String, dynamic> toJson() => _$InvoiceDetailToJson(this);
}

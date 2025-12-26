// To parse this JSON data, do
//
//     final loginDataModel = loginDataModelFromJson(jsonString);

import 'dart:convert';

import 'package:hive_ce_flutter/hive_flutter.dart';

import '../../../hive_type_ids.dart';

part 'login_data_model.g.dart';

LoginDataModel loginDataModelFromJson(String str) => LoginDataModel.fromJson(json.decode(str));

String loginDataModelToJson(LoginDataModel data) => json.encode(data.toJson());

@HiveType(typeId: HiveTypeIds.loginDataModel)
class LoginDataModel {
  @HiveField(1)
  String? company;
  @HiveField(2)
  String? pwd;
  @HiveField(3)
  String? user;
  @HiveField(4)
  Dsn? dsn;
  @HiveField(5)
  String? backgroundImage;

  LoginDataModel({this.company, this.pwd, this.user, this.dsn, this.backgroundImage});

  factory LoginDataModel.fromJson(Map<String, dynamic> json) => LoginDataModel(
    company: json["company"],
    pwd: json["pwd"],
    user: json["user"],
    dsn: json["dsn"] == null ? null : Dsn.fromJson(json["dsn"]),
    backgroundImage: json["backgroundImage"],
  );

  Map<String, dynamic> toJson() => {
    "company": company,
    "pwd": pwd,
    "user": user,
    "dsn": dsn?.toJson(),
    "backgroundImage": backgroundImage,
  };
}

@HiveType(typeId: HiveTypeIds.dsn)
class Dsn {
  @HiveField(1)
  String? type;
  @HiveField(2)
  String? hostname;
  @HiveField(3)
  String? database;
  @HiveField(4)
  String? username;
  @HiveField(5)
  String? password;
  @HiveField(6)
  int? hostport;
  @HiveField(7)
  String? charset;
  @HiveField(8)
  String? prefix;

  Dsn({
    this.type,
    this.hostname,
    this.database,
    this.username,
    this.password,
    this.hostport,
    this.charset,
    this.prefix,
  });

  factory Dsn.fromJson(Map<String, dynamic> json) => Dsn(
    type: json["type"],
    hostname: json["hostname"],
    database: json["database"],
    username: json["username"],
    password: json["password"],
    hostport: json["hostport"],
    charset: json["charset"],
    prefix: json["prefix"],
  );

  Map<String, dynamic> toJson() => {
    "type": type,
    "hostname": hostname,
    "database": database,
    "username": username,
    "password": password,
    "hostport": hostport,
    "charset": charset,
    "prefix": prefix,
  };
}

import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Functions {
  //检测图片是否存在
  static Future<bool> checkImageExists(String imageUrl) async {
    try {
      final dio = Dio();
      final response = await dio.head(imageUrl);
      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  /// 转换为字符串
  static String asString(Object? value) {
    if (value == null) return "";
    if (value is String) {
      final trimmed = value.trim();
      return trimmed.isEmpty ? "" : trimmed;
    }
    return value.toString().trim();
  }

  static String colorToHex(Color color) {
    int alpha = (color.a * 255.0).round() & 0xff;
    int red = (color.r * 255.0).round() & 0xff;
    int green = (color.g * 255.0).round() & 0xff;
    int blue = (color.b * 255.0).round() & 0xff;
    return '${alpha.toRadixString(16).padLeft(2, '0')}${red.toRadixString(16).padLeft(2, '0')}${green.toRadixString(16).padLeft(2, '0')}${blue.toRadixString(16).padLeft(2, '0')}'
        .toUpperCase();
  }

  /// 转换为颜色
  static Color hexToColor(String hex) {
    final buffer = StringBuffer();
    if (hex.length == 6 || hex.length == 7) buffer.write('ff');
    buffer.write(hex.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  /// 格式化金额
  static String formatAmount(Object? value, {String locale = 'en_US'}) {
    final raw = asString(value);
    if (raw.isEmpty) return "0.00";

    // 去掉逗号、空格、货币符号等
    final cleaned = raw.replaceAll(RegExp(r'[,\s\$¥₩₱€£￥]'), '');

    // 安全解析
    final amount = double.tryParse(cleaned);
    if (amount == null || amount.isNaN || amount.isInfinite) {
      return "0.00";
    }

    // 数字格式化
    final formatter = NumberFormat("#,##0.00", locale);
    return formatter.format(amount);
  }

  /// 格式化字符串为bool
  static bool toBool(Object? value) {
    if (value == null) return false;

    if (value is bool) return value;
    if (value is num) return value != 0;

    final raw = asString(value).toLowerCase();
    return raw == "1" || raw == "true" || raw == "yes" || raw == "on";
  }
}

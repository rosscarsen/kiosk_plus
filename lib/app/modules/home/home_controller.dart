import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeController extends GetxController with GetSingleTickerProviderStateMixin {
  late AnimationController animCtrl;
  late Animation<double> scaleAnimation;
  int _secretTapCount = 0;
  Timer? _secretTapTimer;
  final Duration _tapWindow = const Duration(milliseconds: 500);

  @override
  void onInit() {
    super.onInit();
    animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
      lowerBound: 0.5,
      upperBound: 1.0,
    )..repeat();

    scaleAnimation = CurvedAnimation(parent: animCtrl, curve: Curves.elasticInOut);
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    animCtrl.dispose();
    _secretTapTimer?.cancel();
    super.onClose();
  }

  /// 点击5次后触发 secret tap 事件，返回 true 表示触发成功
  bool handleSecretTap() {
    _secretTapTimer?.cancel();
    _secretTapCount++;
    if (_secretTapCount >= 5) {
      _secretTapCount = 0;
      return true;
    }
    _secretTapTimer = Timer(_tapWindow, () {
      _secretTapCount = 0;
    });
    return false;
  }
}

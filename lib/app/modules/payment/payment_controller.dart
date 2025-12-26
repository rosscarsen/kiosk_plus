import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:decimal/decimal.dart';
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pos_printer_platform_image_3_sdt/flutter_pos_printer_platform_image_3_sdt.dart';
import 'package:get/get.dart';
import 'package:hive_ce/hive.dart';
import 'package:intl/intl.dart';
import 'package:kiosk_plus/app/translations/locale_keys.dart';
import 'package:kiosk_plus/app/utils/custom_dialog.dart';

import '../../config.dart';
import '../../model/api_data_model/data_result_model.dart';
import '../../model/bluetooth_printer.dart';
import '../../model/cart/cart_model.dart';
import '../../model/receipt_model.dart';
import '../../routes/app_pages.dart';
import '../../service/dio_api_client.dart';
import '../../service/dio_api_result.dart';
import '../../service/session_service.dart';
import '../../utils/dec_calc.dart';
import '../../utils/esc_handler.dart';
import '../../utils/logger.dart';

class PaymentController extends GetxController {
  final ApiClient apiClient = ApiClient();

  /// 盒子
  final box = IsolatedHive.box(Config.kioskHiveBox);
  //接收传递支付方式
  String? paymentMethod;

  // 卡号输入框焦点节点
  final FocusNode focusNode = FocusNode();
  // 卡号输入框值
  var cardNo = ''.obs;
  // 购物车列表
  List<CartModel>? cartList;
  // 日历折扣
  Decimal calendarDiscount = Decimal.zero;

  /// 购物车金额
  Decimal cartAmount = Decimal.zero;

  /// 蓝牙配置部分
  var defaultPrinterType = PrinterType.bluetooth;
  var printerManager = PrinterManager.instance;
  BluetoothPrinter? bluetoothPrinter;
  BTStatus currentStatus = BTStatus.none;
  StreamSubscription<BTStatus>? _subscriptionBtStatus;
  List<int>? pendingTask;
  EscHandler escHandler = EscHandler();
  RxBool isDataReady = false.obs;
  RxBool hasDiscoveryPrinter = false.obs;

  @override
  void onInit() {
    super.onInit();
    paymentMethod = Get.parameters['paymentMethod'];
    // 监听蓝牙连接状态
    _subscriptionBtStatus = PrinterManager.instance.stateBluetooth.listen((status) {
      currentStatus = status;
      if (status == BTStatus.connected && pendingTask != null) {
        if (Platform.isAndroid) {
          Future.delayed(const Duration(milliseconds: 1000), () {
            logger.i('延迟发送至安卓');
            PrinterManager.instance.send(type: PrinterType.bluetooth, bytes: pendingTask!);
            pendingTask = null;
          });
        } else if (Platform.isIOS) {
          PrinterManager.instance.send(type: PrinterType.bluetooth, bytes: pendingTask!);
          pendingTask = null;
        }
      } else {}
    });
    //监听会话变化，当会话重新激活时，请求焦点
    ever(SessionService.to.isIdle, (value) {
      if (!value) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (focusNode.hasFocus) return;
          focusNode.requestFocus();
        });
      }
    });

    /// 忽略输入框1s内的变化
    debounce(cardNo, (value) async {
      if (value.isEmpty) return;
      if (paymentMethod == 'POINTS') {
        await getUserPoints(value);
      } else {
        await calculateCartAmount();
        await checkout(paymentMethod, value);
      }
    }, time: Duration(seconds: 1));
    checkPrinter();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    focusNode.dispose();
    pendingTask?.clear();
    _subscriptionBtStatus?.cancel();
    super.onClose();
  }

  // 检查积分是否足够
  Future<void> getUserPoints(String value) async {
    CustomDialog.showLoading(LocaleKeys.pleaseWaiting.tr);
    try {
      final DioApiResult response = await apiClient.get(Config.getUserPoints, queryParameters: {'mCardNo': value});
      if (response.success) {
        final remoteDataJson = response.data;
        final remoteData = json.decode(remoteDataJson);
        if (remoteData == null) return;
        if (remoteData['status'] == 201) {
          return CustomDialog.errorMessages(LocaleKeys.cardNumberDoesNotExits.tr);
        }
        final remoteUserPoints = double.tryParse((remoteData['apiResult'] ?? '0.0').toString());
        await calculateCartAmount();
        if (DecUtil.from(cartAmount) > DecUtil.from(remoteUserPoints)) {
          CustomDialog.errorMessages(LocaleKeys.insufficientPoints.tr);
        } else {
          //结账
          await checkout(paymentMethod, value);
        }
      } else {
        CustomDialog.errorMessages(response.error ?? LocaleKeys.networkError.tr);
      }
    } catch (e) {
      CustomDialog.errorMessages(LocaleKeys.networkError.tr);
    } finally {
      CustomDialog.dismissDialog();
    }
  }

  /// 结账
  Future<void> checkout(String? paymentMethod, String card) async {
    CustomDialog.showLoading(LocaleKeys.pleaseWaiting.tr);
    final formData = {
      'paymentMethod': paymentMethod,
      'mCardNo': card,
      'cartList': cartList,
      'cartAmount': cartAmount,
      'calendarDiscount': calendarDiscount,
    };
    try {
      final DioApiResult response = await apiClient.post(Config.checkout, data: formData);
      if (response.success) {
        //打印单据
        final receiptModel = receiptModelFromJson(response.data);
        await printReceipt(receiptModel);
        await box.delete(Config.shoppingCart);
        FocusManager.instance.primaryFocus?.unfocus();
        Get.offAllNamed(Routes.HOME);
      } else {
        CustomDialog.errorMessages(response.error ?? LocaleKeys.networkError.tr);
      }
    } catch (e) {
      logger.i(e);
      CustomDialog.errorMessages(LocaleKeys.networkError.tr);
    } finally {
      CustomDialog.dismissDialog();
    }
  }

  /// 计算购物车数量与金额
  Future<void> calculateCartAmount() async {
    Decimal lastBaseAmount = Decimal.zero; // 商品的基础金额
    Decimal lastRemarksAmount = Decimal.zero; // 备注金额
    Decimal lastSetMealAmount = Decimal.zero; // 套餐金额
    cartList = (await box.get(Config.shoppingCart) as List?)?.cast<CartModel>();
    calendarDiscount = DecUtil.from(await box.get(Config.calendarDiscount) ?? "0");
    if (cartList?.isEmpty ?? true) return;
    for (final item in cartList!) {
      final product = item.product;
      final productPrice = DecUtil.from(product?.mPrice ?? '0.0'); //单价
      final productQty = DecUtil.from(item.product?.qty ?? '1'); //数量
      if (product == null) continue;
      // ✅ 基础金额 = 单价 * 数量
      final baseAmount = DecUtil.mul(productPrice, productQty);
      lastBaseAmount = DecUtil.add(lastBaseAmount, baseAmount);

      /// 备注部分
      final List<ProductRemark> productRemarks = item.remarkList ?? [];
      // ✅ 备注金额 = 备注金额 + 计算备注金额
      lastRemarksAmount = DecUtil.add(
        lastRemarksAmount,
        _calculateRemarksAmount(productRemarks, productQty, productPrice),
      );

      /// 套餐部分
      final List<SetMealList> productSetMeal = item.setMealList ?? [];
      // ✅ 套餐金额 = 套餐金额 + 计算套餐金额
      lastSetMealAmount = DecUtil.add(lastSetMealAmount, _calculateSetMealAmount(productSetMeal, productQty));
    }
    cartAmount = DecUtil.add(DecUtil.add(lastBaseAmount, lastRemarksAmount), lastSetMealAmount);
  }

  /// 计算备注金额
  Decimal _calculateRemarksAmount(List<ProductRemark> productRemarks, Decimal productQty, Decimal productPrice) {
    if (productRemarks.isEmpty) {
      return Decimal.zero;
    }

    Decimal addAmount = Decimal.zero; // 类型 0：加价
    Decimal discountAmount = Decimal.zero; // 类型 1：折扣
    Decimal multiAmount = Decimal.zero; // 类型 2：倍数

    for (final element in productRemarks) {
      final Decimal remarkPrice = DecUtil.from(element.mPrice ?? "0");

      switch (element.mType) {
        case 0:
          // ✅ 加价 = 单价 * 数量
          addAmount = DecUtil.add(addAmount, DecUtil.mul(remarkPrice, productQty));
          break;

        case 1:
          // ✅ 折扣 = (remarkPrice / 100) * 商品单价 * 数量
          final Decimal discount = DecUtil.mul(DecUtil.mul(DecUtil.div(remarkPrice, 100), productPrice), productQty);

          discountAmount = DecUtil.add(discountAmount, discount);
          break;

        case 2:
          // ✅ 倍数 = 基础金额 * remarkPrice
          final Decimal baseAmount = DecUtil.mul(productPrice, productQty);
          multiAmount = DecUtil.add(multiAmount, DecUtil.mul(baseAmount, remarkPrice));
          break;
      }
    }

    // ✅ 最终备注金额 = 加价 - 折扣 + 倍数
    final Decimal finalRemarkAmount = DecUtil.add(DecUtil.sub(addAmount, discountAmount), multiAmount);
    return finalRemarkAmount;
  }

  /// 计算套餐金额
  Decimal _calculateSetMealAmount(List<SetMealList> productSetMeal, Decimal productQty) {
    if (productSetMeal.isEmpty) {
      return Decimal.zero;
    }
    //  套餐金额 = 累加(套餐单价 * 套餐数量)
    final selectedSetMealAmount = productSetMeal.fold(
      Decimal.zero,
      (prev, element) =>
          DecUtil.add(prev, DecUtil.mul(DecUtil.from(element.mPrice ?? "0"), DecUtil.from(element.mQty ?? "0"))),
    );
    // ✅ 最终套餐金额 = 套餐金额 * 商品数量
    final Decimal lastSetMealAmount = DecUtil.mul(selectedSetMealAmount, productQty);
    return lastSetMealAmount;
  }

  /// 检测打印机
  Future<void> checkPrinter() async {
    isDataReady.value = false;
    final innerPrinterInfo = await box.get(Config.innerPrinterInfo) as BluetoothPrinter?;
    if (innerPrinterInfo == null) {
      hasDiscoveryPrinter.value = false;
    } else {
      bluetoothPrinter = innerPrinterInfo;
      hasDiscoveryPrinter.value = true;
    }
    isDataReady.value = true;
  }

  /// 打印收據
  Future<void> printReceipt(ReceiptModel printData) async {
    if (bluetoothPrinter == null) {
      hasDiscoveryPrinter.value = false;
      return;
    }

    await printerManager.connect(
      type: PrinterType.bluetooth,
      model: BluetoothPrinterInput(
        name: bluetoothPrinter!.deviceName,
        address: bluetoothPrinter!.address!,
        isBle: false,
        autoConnect: false,
      ),
    );
    final profile = await CapabilityProfile.load(name: 'XP-N160I');
    final generator = Generator(PaperSize.mm58, profile);
    List<int> bytes = generatorReceiptData(generator, printData);
    pendingTask = null;
    if (Platform.isAndroid) pendingTask = bytes;
    if (currentStatus == BTStatus.connected) {
      try {
        if (Platform.isAndroid) {
          printerManager.send(type: PrinterType.bluetooth, bytes: bytes);
          pendingTask = null;
        } else {
          printerManager.send(type: PrinterType.bluetooth, bytes: bytes);
        }
      } catch (e, st) {
        debugPrint('Failed to send print data: $e\n$st');
      }
    }
  }

  ///生成收據数据
  List<int> generatorReceiptData(Generator generator, ReceiptModel printData) {
    final company = printData.company;
    final now = DateTime.now();
    List<int> bytes = [];
    bytes += generator.setGlobalCodeTable('CP1252');
    if (company != null) {
      if (company.mNameEnglish?.isNotEmpty ?? false) {
        bytes += generator.text(
          "${EscHandler.setBold()}${EscHandler.setAlgin(algin: 1)}${EscHandler.setSize(size: 1)}${company.mNameEnglish}",
          containsChinese: true,
        );
      }
      if (company.mNameChinese?.isNotEmpty ?? false) {
        bytes += generator.text(
          "${EscHandler.setBold()}${EscHandler.setAlgin(algin: 1)}${EscHandler.setSize(size: 1)}${company.mNameChinese}",
          containsChinese: true,
        );
      }
      if (company.mAddress?.isNotEmpty ?? false) {
        bytes += generator.text(
          "${EscHandler.setBold()}${EscHandler.setAlgin(algin: 1)}${EscHandler.setSize(size: 1)}${company.mAddress}",
          containsChinese: true,
        );
      }
      bytes += generator.text("${EscHandler.resetBold()}${"-" * 48}");
    }

    bytes += generator.text(
      "${EscHandler.setBold()}${EscHandler.setAlgin(algin: 1)}${EscHandler.setSize(size: 1)}${LocaleKeys.receipt.tr}",
      containsChinese: true,
    );
    final invoice = printData.invoice;
    bytes += generator.text(
      "${EscHandler.setSize()}${EscHandler.setAlgin()}${LocaleKeys.station.tr}:${invoice?.mStationCode ?? "01"}",
      containsChinese: true,
    );
    bytes += generator.text(
      "${EscHandler.setSize()}${EscHandler.setAlgin()}${LocaleKeys.orderNo.tr}:#${invoice?.mInvoiceNo ?? ""}",
      containsChinese: true,
    );

    bytes += generator.text(
      "${EscHandler.setSize()}${EscHandler.setAlgin()}${LocaleKeys.time.tr}:${DateFormat("yyyy/MM/dd HH:mm").format(now)}",
      containsChinese: true,
    );

    bytes += generator.feed(1);
    bytes += generator.text(
      "${EscHandler.setSize()}${EscHandler.columnMaker(LocaleKeys.item.tr, 34)}${EscHandler.columnMaker(LocaleKeys.quantity.tr, 6, algin: 1)}${EscHandler.columnMaker(LocaleKeys.amount.tr, 8, algin: 2)}",
      containsChinese: true,
    );
    bytes += generator.hr();

    final List<InvoiceDetail>? invoiceDetail = printData.invoiceDetail;
    if (invoiceDetail != null && invoiceDetail.isNotEmpty) {
      for (var item in invoiceDetail) {
        final String? mRemarks = item.mRemarks;
        final List mPrintNameList = EscHandler.strToList(str: item.mPrintName ?? "", splitLength: 34);

        //名称
        bytes += generator.text(
          "${EscHandler.setSize()}${EscHandler.columnMaker(mPrintNameList.isNotEmpty ? "${mPrintNameList[0]}" : "", 34)}${EscHandler.columnMaker(double.parse(item.mQty ?? "1").toInt().toString(), 6, algin: 1)}${EscHandler.columnMaker("${item.mAmount}", 8, algin: 2)}",
          containsChinese: true,
        );
        if (mPrintNameList.isNotEmpty) {
          mPrintNameList.removeAt(0);
        }
        if (mPrintNameList.isNotEmpty) {
          for (var mPrintNameItem in mPrintNameList) {
            bytes += generator.text(
              "${EscHandler.setSize()}${EscHandler.columnMaker("$mPrintNameItem", 34)}${EscHandler.columnMaker("", 14)}",
              containsChinese: true,
            );
          }
        }
        if (mRemarks != null && mRemarks.isNotEmpty) {
          bytes += generator.text(
            " ${EscHandler.setSize()}${EscHandler.columnMaker(mRemarks, 34)}${EscHandler.columnMaker("", 14)}",
            containsChinese: true,
          );
        }
      }
    }
    bytes += generator.hr();
    bytes += generator.text(
      "${EscHandler.setSize()}${EscHandler.columnMaker(LocaleKeys.subtotal.tr, 24)}${EscHandler.columnMaker(invoice?.mAmount ?? "0.00", 24, algin: 2)}",
      containsChinese: true,
    );
    final double mDiscRate = double.parse(invoice?.mDiscRate ?? '0.00');
    if (mDiscRate > 0) {
      bytes += generator.text(
        "${EscHandler.setSize()}${EscHandler.columnMaker(LocaleKeys.discount.tr, 24)}${EscHandler.columnMaker("${invoice?.mDiscRate ?? '0.00'}%", 24, algin: 2)}",
        containsChinese: true,
      );
    }

    bytes += generator.text(
      "${EscHandler.setBold()}${EscHandler.columnMaker(LocaleKeys.total.tr, 24)}${EscHandler.columnMaker(invoice?.mAmount ?? "0.00", 24, algin: 2)}",
      containsChinese: true,
    );
    bytes += generator.text(
      "${EscHandler.columnMaker(LocaleKeys.paymentAmount.tr, 24)}${EscHandler.columnMaker(invoice?.mPayAmount ?? "0.00", 24, algin: 2)}",
      containsChinese: true,
    );
    bytes += generator.text(
      "${EscHandler.columnMaker(LocaleKeys.paymentMethod.tr, 24)}${EscHandler.columnMaker(invoice?.mPayType ?? "0.00", 24, algin: 2)}",
      containsChinese: true,
    );
    bytes += generator.emptyLines(2);
    bytes += generator.text(
      "${EscHandler.setBold()}${EscHandler.setAlgin(algin: 1)}${Get.locale.toString() == "en_US" ? LocaleKeys.thankYou.tr : "${LocaleKeys.thankYou.tr}(Thank You)"}",
      containsChinese: true,
    );
    bytes += generator.text(
      "${EscHandler.setBold()}${EscHandler.setAlgin(algin: 1)}${Get.locale.toString() == "en_US" ? LocaleKeys.customerCopy.tr : '*** 客戶存根(Customer Copy) ***'}",
      containsChinese: true,
    );
    bytes += generator.cut();
    return bytes;
  }
}

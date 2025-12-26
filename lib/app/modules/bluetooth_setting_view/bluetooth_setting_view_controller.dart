import 'dart:async';
import 'dart:io';

import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_pos_printer_platform_image_3_sdt/flutter_pos_printer_platform_image_3_sdt.dart';
import 'package:get/get.dart';
import 'package:hive_ce/hive.dart';

import '../../config.dart';
import '../../model/bluetooth_printer.dart';

class BluetoothSettingViewController extends GetxController {
  var devices = <BluetoothPrinter>[].obs;
  final box = IsolatedHive.box(Config.kioskHiveBox);

  var defaultPrinterType = PrinterType.bluetooth;
  var printerManager = PrinterManager.instance;
  BluetoothPrinter? selectedPrinter;
  BTStatus currentStatus = BTStatus.none;
  StreamSubscription<BTStatus>? _subscriptionBtStatus;
  List<int>? pendingTask;
  @override
  void onInit() {
    super.onInit();
    scanDevices();
    _subscriptionBtStatus = PrinterManager.instance.stateBluetooth.listen((status) async {
      currentStatus = status;
      if (status == BTStatus.connected && pendingTask != null) {
        await box.put(Config.innerPrinterInfo, selectedPrinter);
        if (Platform.isAndroid) {
          Future.delayed(const Duration(milliseconds: 1000), () {
            printerManager.send(type: PrinterType.bluetooth, bytes: pendingTask!);
            pendingTask = null;
          });
        } else if (Platform.isIOS) {
          printerManager.send(type: PrinterType.bluetooth, bytes: pendingTask!);
          pendingTask = null;
        }
      }
    });
  }

  @override
  void onClose() {
    _subscriptionBtStatus?.cancel();
    super.onClose();
  }

  void scanDevices() {
    devices.clear();
    printerManager.discovery(type: defaultPrinterType, isBle: false).listen((device) {
      if (device.address?.isEmpty ?? true) {
        return;
      }
      devices.add(
        BluetoothPrinter(
          deviceName: device.name,
          address: device.address,
          vendorId: device.vendorId,
          productId: device.productId,
        ),
      );
      update(['searchDevices']);
    });
  }

  Future<void> innerPrinter(BluetoothPrinter device) async {
    box.delete(Config.innerPrinterInfo);
    if (selectedPrinter != null) {
      if ((device.address != selectedPrinter!.address)) {
        await printerManager.disconnect(type: PrinterType.bluetooth);
      }
    }
    selectedPrinter = device;
    await printerManager.connect(
      type: PrinterType.bluetooth,
      model: BluetoothPrinterInput(
        name: selectedPrinter!.deviceName,
        address: selectedPrinter!.address!,
        isBle: false,
        autoConnect: false,
      ),
    );
    final profile = await CapabilityProfile.load(name: 'XP-N160I');
    final generator = Generator(PaperSize.mm58, profile);
    List<int> bytes = innerPrinterData(generator);
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
        await box.put(Config.innerPrinterInfo, selectedPrinter);
      } catch (e, st) {
        debugPrint('Failed to send print data: $e\n$st');
      }
    }
  }

  List<int> innerPrinterData(Generator generator) {
    List<int> bytes = [];
    bytes += generator.setGlobalCodeTable('CP1252');
    bytes += generator.text('Test Print', styles: const PosStyles(align: PosAlign.center));
    bytes += generator.qrcode('https://www.pericles.net', size: QRSize.size4, align: PosAlign.center);
    bytes += generator.feed(1);
    final List<int> barData = [1, 2, 3, 4, 5, 6, 7, 8, 9, 0, 4];
    bytes += generator.barcode(Barcode.upcA(barData), height: 30, align: PosAlign.center);
    bytes += generator.feed(1);
    bytes += generator.cut();
    return bytes;
  }
}

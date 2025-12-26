import 'package:hive_ce/hive.dart';

import '../../hive_type_ids.dart';

part 'bluetooth_printer.g.dart';

@HiveType(typeId: HiveTypeIds.innerPrinterInfo)
class BluetoothPrinter {
  @HiveField(0)
  String? deviceName;
  @HiveField(1)
  String? address;
  @HiveField(2, defaultValue: "9100")
  String? port;
  @HiveField(3)
  String? vendorId;
  @HiveField(4)
  String? productId;
  @HiveField(5, defaultValue: false)
  bool? isBle;
  @HiveField(6)
  bool? state;
  BluetoothPrinter({this.deviceName, this.address, this.port, this.vendorId, this.productId, this.isBle, this.state});

  factory BluetoothPrinter.fromJson(Map<String, dynamic> json) => BluetoothPrinter(
    deviceName: json["deviceName"] as String?,
    address: json["address"] as String?,
    port: json["port"] as String?,
    vendorId: json["vendorId"] as String?,
    productId: json["productId"] as String?,
    isBle: json["isBle"] as bool?,
    state: json["state"] as bool?,
  );

  Map<String, dynamic> toJson() => {
    "deviceName": deviceName,
    "address": address,
    "port": port,
    "vendorId": vendorId,
    "productId": productId,
    "isBle": isBle,
    "state": state,
  };
}

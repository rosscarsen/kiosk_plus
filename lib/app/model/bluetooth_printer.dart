import 'package:json_annotation/json_annotation.dart';

part 'bluetooth_printer.g.dart';

@JsonSerializable(explicitToJson: true)
class BluetoothPrinter {
  @JsonKey(name: "deviceName")
  String? deviceName;
  @JsonKey(name: "address")
  String? address;
  BluetoothPrinter({this.deviceName, this.address});

  factory BluetoothPrinter.fromJson(Map<String, dynamic> json) => _$BluetoothPrinterFromJson(json);

  Map<String, dynamic> toJson() => _$BluetoothPrinterToJson(this);
}

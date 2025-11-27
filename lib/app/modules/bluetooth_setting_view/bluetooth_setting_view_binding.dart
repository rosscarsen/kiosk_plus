import 'package:get/get.dart';

import 'bluetooth_setting_view_controller.dart';

class BluetoothSettingViewBinding extends Binding {
  @override
  List<Bind> dependencies() => [Bind.lazyPut<BluetoothSettingViewController>(() => BluetoothSettingViewController())];
}

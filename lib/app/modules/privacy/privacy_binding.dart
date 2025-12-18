import 'package:get/get.dart';

import 'privacy_controller.dart';

class PrivacyBinding extends Binding {
  @override
  List<Bind> dependencies() {
    return [Bind.lazyPut<PrivacyController>(() => PrivacyController())];
  }
}

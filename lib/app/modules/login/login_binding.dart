import 'package:get/get.dart';

import 'login_controller.dart';

class LoginBinding extends Binding {
  @override
  List<Bind> dependencies() {
    return [Bind.lazyPut<LoginController>(() => LoginController())];
  }
}

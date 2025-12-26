import 'package:get/get.dart';

import 'payment_controller.dart';

class PaymentBinding extends Binding {
  @override
  List<Bind> dependencies() {
    return [Bind.lazyPut<PaymentController>(() => PaymentController())];
  }
}

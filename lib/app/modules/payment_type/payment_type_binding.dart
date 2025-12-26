import 'package:get/get.dart';

import 'payment_type_controller.dart';

class PaymentTypeBinding extends Binding {
  @override
  List<Bind> dependencies() => [Bind.lazyPut<PaymentTypeController>(() => PaymentTypeController())];
}

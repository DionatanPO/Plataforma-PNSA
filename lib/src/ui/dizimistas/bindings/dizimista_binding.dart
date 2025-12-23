import 'package:get/get.dart';
import '../controllers/dizimista_controller.dart';

class DizimistaBinding extends Bindings {
  @override
  void dependencies() {
    // Controller is already created in HomeBinding (fenix: true)
    // Only create if not already registered (for edge cases)
    if (!Get.isRegistered<DizimistaController>()) {
      Get.lazyPut<DizimistaController>(() => DizimistaController(),
          fenix: true);
    }
  }
}

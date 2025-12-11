import 'package:get/get.dart';
import '../controllers/contribuicao_controller.dart';

class ContribuicaoBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ContribuicaoController>(() => ContribuicaoController());
  }
}
import 'package:get/get.dart';
import '../controllers/contribuicao_controller.dart';
import '../../dizimistas/controllers/dizimista_controller.dart';

class ContribuicaoBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ContribuicaoController>(() => ContribuicaoController());
    Get.lazyPut<DizimistaController>(() => DizimistaController());
  }
}

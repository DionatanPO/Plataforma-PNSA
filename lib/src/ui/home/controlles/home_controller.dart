import 'package:get/get.dart';

class HomeController extends GetxController {
  /// Mensagem de boas-vindas observável
  var welcomeMessage = "Bem-vindo ao Sistema de Dízimo da Paróquia NS Auxiliadora!".obs;

  /// Índice da aba atualmente selecionada
  var selectedIndex = 0.obs;

  /// Atualiza a mensagem de boas-vindas
  void changeMessage(String newMessage) {
    welcomeMessage.value = newMessage;
  }

  /// Muda a aba selecionada
  void changeIndex(int index) {
    selectedIndex.value = index;
  }
}

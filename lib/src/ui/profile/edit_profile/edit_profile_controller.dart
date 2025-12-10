import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EditProfileController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();

  final avatarUrl = 'https://i.pravatar.cc/150?img=12'.obs; // Fictional avatar URL
  final isLoading = false.obs;

  @override
  void onInit() {
    // Load initial user data
    nameController.text = 'Dionatan Oliveira';
    emailController.text = 'dionatan@email.com';
    super.onInit();
  }

  void pickImage() {
    // Simulate image picking
    // In a real app, you would use an image picker package
    Get.snackbar('Em Breve', 'Seleção de imagem ainda não implementada.');
    avatarUrl.value = 'https://i.pravatar.cc/150?img=${DateTime.now().second}';
  }

  Future<void> saveProfile() async {
    if (formKey.currentState!.validate()) {
      isLoading.value = true;
      try {
        // Simulate saving profile data
        await Future.delayed(const Duration(seconds: 2));
        Get.snackbar('Sucesso', 'Perfil atualizado com sucesso!');
        Get.back();
      } finally {
        isLoading.value = false;
      }
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    super.onClose();
  }
}

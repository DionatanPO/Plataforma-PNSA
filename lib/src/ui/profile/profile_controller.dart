import 'package:get/get.dart';
import '../../routes/app_routes.dart';
import '../../data/services/auth_service.dart';

class ProfileController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();

  // User data (would come from auth service in production)
  final name = 'Dionatan Oliveira'.obs;
  final email = 'dionatan@email.com'.obs;
  final avatarUrl = 'https://i.pravatar.cc/150?img=12'.obs;

  // Stats
  final tasksCompleted = 127.obs;
  final projectsActive = 8.obs;
  final achievements = 24.obs;

  void editProfile() {
    // Navigate to edit profile or show dialog
    Get.snackbar('Edit Profile', 'Feature coming soon');
  }

  void changePassword() {
    Get.snackbar('Change Password', 'Feature coming soon');
  }

  void toggleNotifications() {
    Get.snackbar('Notifications', 'Feature coming soon');
  }

  void openThemeSettings() {
    Get.toNamed('/theme_settings');
  }

  void openFAQ() {
    Get.snackbar('FAQ', 'Feature coming soon');
  }

  void openSupport() {
    Get.toNamed('/help');
  }

  void logout() async {
    // Chama o método de logout do serviço de autenticação
    // que cuida de limpar a sessão e fazer o logout do Firebase
    await _authService.logout();

    // Redireciona para a tela de login
    Get.offAllNamed(AppRoutes.login);
  }
}

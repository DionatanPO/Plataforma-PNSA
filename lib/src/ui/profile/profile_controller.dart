import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../routes/app_routes.dart';
import '../../data/services/auth_service.dart';

class ProfileController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();

  // User data
  final name = ''.obs;
  final email = ''.obs;
  final avatarUrl = ''.obs;
  final cpf = ''.obs;
  final telefone = ''.obs;
  final endereco = ''.obs;
  final funcao = ''.obs;
  final status = ''.obs;

  // Stats
  final tasksCompleted = 0.obs;
  final projectsActive = 0.obs;
  final achievements = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadUserData();
  }

  Future<void> loadUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Preenche com dados básicos do Firebase Auth
        name.value = user.displayName ?? user.email?.split('@')[0] ?? 'Usuário';
        email.value = user.email ?? '';
        avatarUrl.value = user.photoURL ?? 'https://i.pravatar.cc/150?img=12';

        // Busca dados completos do Firestore
        final userData = await _authService.getUserData(user.uid);
        if (userData != null) {
          name.value = userData.nome;
          cpf.value = userData.cpf;
          telefone.value = userData.telefone;
          endereco.value = userData.endereco;
          funcao.value = userData.funcao;
          status.value = userData.status;
        }
      }
    } catch (e) {
      // Tratar erro ao carregar dados do usuário
    }
  }

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

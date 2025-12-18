import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../routes/app_routes.dart';
import 'auth_service.dart';
import 'session_service.dart';
import '../../ui/auth/login/login_controller.dart';

class AuthGuard extends GetxService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final AuthService _authService = Get.find<AuthService>();

  @override
  void onInit() {
    super.onInit();

    // Ouvinte de estado de autenticação do Firebase
    // Removido o skip(1) para garantir que logins em navegadores com persistência
    // não sejam ignorados. A flag isInitialCheckComplete já protege o splash.
    _auth.authStateChanges().listen(_onAuthStateChanged);

    // Executar verificação inicial imediatamente
    _checkInitialAuthState();
  }

  // Método para verificar o estado inicial de autenticação
  void _checkInitialAuthState() {
    // Não faz nada na inicialização, pois o SplashScreen já gerencia isso
    // 1O AuthGuard é usado principalmente para monitorar mudanças após o login inicial
  }

  // Método chamado quando o estado de autenticação muda
  void _onAuthStateChanged(User? user) async {
    // Aguarda a verificação inicial do splash ser concluída antes de agir.
    if (!Get.find<SessionService>().isInitialCheckComplete.value) {
      return;
    }

    // NOTA: Com a nova implementação usando instância secundária do Firebase para criar usuários,
    // a criação de novos usuários NUNCA afeta a sessão do admin principal.
    // Portanto, não precisamos mais verificar flags de "criando novo usuário".

    if (user != null) {
      try {
        // Verificar se o token de autenticação é válido
        await user.getIdToken(true); // Força a renovação se necessário
        // Usuário está autenticado e token é válido
        _checkUserStatus(user.uid);
      } catch (e) {
        // Se o token não for válido, fazer logout
        print('Token de autenticação inválido: $e');
        await _authService.logout();
        Get.offAllNamed(AppRoutes.login);
      }
    } else {
      // Usuário não está autenticado - redirecionar para login
      Get.offAllNamed(AppRoutes.login);
    }
  }

  // Verifica o status do usuário (pendências, status ativo, etc.)
  Future<void> _checkUserStatus(String uid) async {
    try {
      // Verificar se o usuário está ativo
      final isActive = await _authService.isUserActiveWithRetry(uid);
      if (!isActive) {
        // Deslogar o usuário e redirecionar para login com mensagem
        await _authService.logout();
        Get.find<LoginController>().loginError.value =
            'Sua conta foi desativada pelo administrador.';
        Get.find<LoginController>().isLoading.value = false;
        Get.offAllNamed(AppRoutes.login);
        return;
      }
      // Verificar se o usuário tem pendências
      final userData = await _authService.getUserDataWithRetry(uid);
      if (userData != null && userData.pendencia) {
        Get.offAllNamed(AppRoutes.password_reset);
      } else {
        Get.offAllNamed(AppRoutes.home);
      }

      // Desativar loading após navegação bem-sucedida
      if (Get.isRegistered<LoginController>()) {
        Get.find<LoginController>().isLoading.value = false;
      }
    } catch (e) {
      // Em caso de erro, redireciona para o login
      if (Get.isRegistered<LoginController>()) {
        Get.find<LoginController>().isLoading.value = false;
      }
      Get.offAllNamed(AppRoutes.login);
    }
  }
}

import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../routes/app_routes.dart';
import 'auth_service.dart';
import '../../core/services/access_service.dart';


class AuthGuard extends GetxService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final AuthService _authService = Get.find<AuthService>();

  @override
  void onInit() {
    super.onInit();

    // Ouvinte de estado de autenticação do Firebase
    _auth.authStateChanges().listen(_onAuthStateChanged);

    // Executar verificação inicial imediatamente
    _checkInitialAuthState();
  }

  // Método para verificar o estado inicial de autenticação
  void _checkInitialAuthState() {
    // Não faz nada na inicialização, pois o SplashScreen já gerencia isso
    // O AuthGuard é usado principalmente para monitorar mudanças após o login inicial
  }

  // Método chamado quando o estado de autenticação muda
  void _onAuthStateChanged(User? user) async {
    // Verificar se estamos atualmente criando um novo usuário via AccessService
    // Se estivermos, ignorar temporariamente essa mudança de estado para evitar redirecionamento indesejado
    if (AccessService.isCreatingNewUser) {
      // Apenas retornar sem fazer nenhuma ação de navegação
      return;
    }

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
      // Usuário não está autenticado
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
        Get.offAllNamed(AppRoutes.login);
        Get.snackbar('Acesso Negado', 'Sua conta foi desativada pelo administrador.');
        return;
      }

      // Verificar se o usuário tem pendências
      final userData = await _authService.getUserDataWithRetry(uid);
      if (userData != null && userData.pendencia) {
        Get.offAllNamed(AppRoutes.password_reset);
      } else {
        Get.offAllNamed(AppRoutes.home);
      }
    } catch (e) {
      // Em caso de erro, redireciona para o login
      Get.offAllNamed(AppRoutes.login);
    }
  }
}
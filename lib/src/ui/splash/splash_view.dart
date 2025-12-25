import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'web_utils.dart' as web_utils;
import '../../routes/app_routes.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/session_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();

    // Remover splash do Web imediatamente quando o Flutter estiver desenhando
    if (kIsWeb) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        try {
          web_utils.removeSplash();
        } catch (e) {
          debugPrint('Erro ao remover splash web: $e');
        }
      });
    }

    // Mantemos o controller apenas para o efeito de "pulso" constante
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _checkAuthState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _checkAuthState() async {
    final sessionService = Get.find<SessionService>();
    try {
      final auth = FirebaseAuth.instance;
      User? user = auth.currentUser;

      // Se não houver usuário logado imediatamente, aguarda um pouco mais para ver se o Firebase restaura a sessão
      // Isso é crucial para Web onde a persistência pode demorar alguns milissegundos para carregar
      if (user == null) {
        try {
          print('Aguardando restauração de sessão...');
          user = await auth
              .authStateChanges()
              .firstWhere((u) => u != null)
              .timeout(const Duration(seconds: 3));
          print('Sessão restaurada: ${user?.email}');
        } catch (_) {
          print('Nenhuma sessão restaurada após timeout.');
          // Timeout: realmente não há usuário logado ou persistência falhou
        }
      }

      AuthService authService;
      try {
        authService = Get.find<AuthService>();
      } catch (e) {
        authService = Get.put(AuthService());
      }

      if (user != null) {
        // Verificar se o token de autenticação é válido
        try {
          // Forçar a renovação do token de ID para verificar sua validade
          await user!.getIdToken(true); // Força a renovação se necessário

          final userData = await authService.getUserDataWithRetry(user.uid);
          if (userData != null) {
            // Verificar se o usuário está ativo
            final isActive = await authService.isUserActiveWithRetry(user.uid);
            if (!isActive) {
              // Deslogar o usuário e redirecionar para login com mensagem
              await authService.logout();
              Get.offAllNamed(AppRoutes.login);
              Get.snackbar(
                'Acesso Negado',
                'Sua conta foi desativada pelo administrador.',
              );
              return;
            }

            if (userData.pendencia) {
              Get.offAllNamed(AppRoutes.password_reset);
            } else {
              Get.offAllNamed(AppRoutes.home);
            }
          } else {
            // Se não encontrar os dados do usuário, deslogar e ir para login
            await authService.logout();
            Get.offAllNamed(AppRoutes.login);
          }
        } catch (e) {
          // Se houver erro na validação do token (ex: token expirado), deslogar e ir para login
          print('Erro na validação do token de autenticação: $e');
          await authService.logout();
          Get.offAllNamed(AppRoutes.login);
        }
      } else {
        Get.offAllNamed(AppRoutes.login);
      }
    } finally {
      sessionService.isInitialCheckComplete.value = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    // Usando as mesmas cores do index.html para transição zero
    final bgColor = isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF8F9FB);

    return Scaffold(
      backgroundColor: bgColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(
                  colorScheme.secondary,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Carregando dados...',
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: 12,
                color: colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

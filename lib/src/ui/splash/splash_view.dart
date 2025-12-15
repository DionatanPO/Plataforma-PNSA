import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../routes/app_routes.dart';
import '../../data/services/auth_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Animação de entrada
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    _animationController.forward();

    _checkAuthState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _checkAuthState() async {
    await Future.delayed(const Duration(seconds: 3));

    final auth = FirebaseAuth.instance;

    AuthService authService;
    try {
      authService = Get.find<AuthService>();
    } catch (e) {
      authService = Get.put(AuthService());
    }

    if (auth.currentUser != null) {
      // Verificar se o token de autenticação é válido
      try {
        // Forçar a renovação do token de ID para verificar sua validade
        await auth.currentUser!.getIdToken(true); // Força a renovação se necessário

        final userData = await authService.getUserDataWithRetry(auth.currentUser!.uid);
        if (userData != null) {
          // Verificar se o usuário está ativo
          final isActive = await authService.isUserActiveWithRetry(auth.currentUser!.uid);
          if (!isActive) {
            // Deslogar o usuário e redirecionar para login com mensagem
            await authService.logout();
            Get.offAllNamed(AppRoutes.login);
            Get.snackbar('Acesso Negado', 'Sua conta foi desativada pelo administrador.');
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
  }

  @override
  Widget build(BuildContext context) {
    // Acessa as cores do tema atual (Seja Claro ou Escuro)
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      // Fundo: Pega a cor de fundo definida no seu AppTheme (Claro ou Escuro)
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          // --- CONTEÚDO CENTRAL ---
          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Círculo do Ícone
                    Container(
                      padding: const EdgeInsets.all(30),
                      decoration: BoxDecoration(
                        // Fundo do ícone: Cor Primária com baixa opacidade (fica suave no claro e no escuro)
                        color: colorScheme.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.church_rounded,
                        size: 80,
                        // Ícone: Cor Primária (Azul do seu tema)
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Título
                    Text(
                      'Plataforma PNSA',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        // Cor do texto: Primária para dar identidade
                        color: colorScheme.primary,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Subtítulo
                    Text(
                      'Paróquia Nossa Senhora Auxiliadora',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        // Cor do texto: Cor padrão do tema (Preto no Claro, Branco no Escuro)
                        // onSurface garante legibilidade em cima do fundo
                        color: colorScheme.onSurface.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // --- RODAPÉ (LOADER) ---
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Center(
              child: Column(
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      // Loader: Cor Secundária (Dourado/Verde Médio do seu tema)
                      valueColor: AlwaysStoppedAnimation<Color>(colorScheme.secondary),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Carregando...',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
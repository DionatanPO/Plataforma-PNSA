import 'dart:ui'; // Necessário para ImageFilter
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../routes/app_routes.dart';
import 'login_controller.dart';

class LoginView extends StatelessWidget {
  LoginView({super.key});

  final controller = Get.find<LoginController>();

  // Imagem de fundo local
  final String heroImage = 'assets/images/paroquia.png';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 900;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Row(
        children: [
          // =================================================
          // LADO ESQUERDO: BRANDING & INSPIRAÇÃO
          // =================================================
          if (isDesktop)
            Expanded(
              flex: 5, // 5/12 da tela
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // 1. Imagem de Fundo
                  Image.asset(
                    heroImage,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        Container(color: const Color(0xFF1B4B29)),
                  ),

                  // 2. Overlay Escuro (Gradiente)
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          const Color(0xFF1B4B29).withOpacity(0.3),
                          Colors.black.withOpacity(0.8),
                        ],
                      ),
                    ),
                  ),

                  // 3. Conteúdo Sobreposto (Vidro)
                  Padding(
                    padding: const EdgeInsets.all(60.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Logo / Nome
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Circular logo image centered above the name
                            Align(
                              alignment: Alignment.center,
                              child: Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.3),
                                    width: 2,
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(50),
                                  child: Image.asset(
                                    'assets/images/logo.jpg',
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => Container(
                                      color: Colors.grey,
                                      child: const Icon(
                                        Icons.image_not_supported_outlined,
                                        color: Colors.white,
                                        size: 28,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0.0, end: 1.0),
                              duration: const Duration(milliseconds: 1200),
                              curve: Curves.elasticOut,
                              builder: (context, value, child) {
                                return Transform.scale(
                                  scale: value,
                                  child: Align(
                                    alignment: Alignment.center,
                                    child: Text(
                                      "PARÓQUIA\nN. S. AUXILIADORA",
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.outfit(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w900,
                                        fontSize: 32,
                                        letterSpacing: 1.2,
                                        shadows: [
                                          Shadow(
                                            color: Colors.black.withOpacity(0.7),
                                            offset: const Offset(2, 2),
                                            blurRadius: 4,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),

                        const Spacer(),

                        // Card de Citação com Glassmorphism
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Container(
                              padding: const EdgeInsets.all(32),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                border: Border.all(color: Colors.white.withOpacity(0.2)),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '"Cada ato de generosidade é um degrau rumo ao céu."',
                                    style: GoogleFonts.outfit(
                                      color: Colors.white,
                                      fontSize: 28,
                                      height: 1.2,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      Container(
                                          height: 2,
                                          width: 40,
                                          color: Colors.white.withOpacity(0.5)
                                      ),

                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          // =================================================
          // LADO DIREITO: LOGIN FORM
          // =================================================
          Expanded(
            flex: 7, // 7/12 da tela
            child: Container(
              color: theme.colorScheme.surface,
              child: Column(
                children: [
                  // Header Mobile (Só aparece se tela for pequena)
                  if (!isDesktop)
                    Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1B4B29),
                        image: DecorationImage(
                          image: AssetImage(heroImage),
                          fit: BoxFit.cover,
                          colorFilter: ColorFilter.mode(
                              Colors.black.withOpacity(0.6), BlendMode.darken),
                        ),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Circular logo image for mobile
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 2,
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(30),
                                child: Image.asset(
                                  'assets/images/logo.jpg',
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => Container(
                                    color: Colors.grey,
                                    child: const Icon(
                                      Icons.image_not_supported_outlined,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Paróquia NS Auxiliadora",
                              style: GoogleFonts.outfit(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20
                              ),
                            )
                          ],
                        ),
                      ),
                    ),

                  // Área do Form
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 420),
                          child: TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0.0, end: 1.0),
                            duration: const Duration(milliseconds: 800),
                            curve: Curves.easeOutQuart,
                            builder: (context, value, child) {
                              return Transform.translate(
                                offset: Offset(0, 30 * (1 - value)), // Slide Up
                                child: Opacity(
                                  opacity: value, // Fade In
                                  child: child,
                                ),
                              );
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Bem-vindo de volta',
                                  style: GoogleFonts.outfit(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Digite seus dados para acessar o painel administrativo.',
                                  style: GoogleFonts.inter(
                                      fontSize: 15,
                                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                                      height: 1.5
                                  ),
                                ),
                                const SizedBox(height: 40),

                                // Inputs
                                Form(
                                  key: controller.formKey,
                                  child: Column(
                                    children: [
                                      Obx(() => _ModernInput(
                                        label: "E-mail",
                                        controller: controller.emailController,
                                        hint: "ex: tesouraria@paroquia.com",
                                        icon: Icons.email_outlined,
                                        errorText: controller.emailError.value,
                                        validator: controller.validateEmail,
                                      )),
                                      const SizedBox(height: 24),
                                      Obx(() => _ModernInput(
                                        label: "Senha",
                                        controller: controller.passwordController,
                                        hint: "Digite sua senha",
                                        icon: Icons.lock_outline,
                                        isPassword: true,
                                        obscureText: controller.obscurePassword.value,
                                        onToggleVisibility: controller.togglePasswordVisibility,
                                        errorText: controller.passwordError.value,
                                        validator: controller.validatePassword,
                                      )),
                                    ],
                                  ),
                                ),



                                const SizedBox(height: 32),

                                // Botão Principal
                                Obx(() => SizedBox(
                                  width: double.infinity,
                                  height: 56,
                                  child: ElevatedButton(
                                    onPressed: controller.isLoading.value ? null : controller.login,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: controller.isLoading.value
                                        ? theme.colorScheme.onSurface.withOpacity(0.4) // Gray state when loading
                                        : theme.colorScheme.primary, // Use theme primary color when not loading
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      shadowColor: theme.colorScheme.primary.withOpacity(0.4),
                                    ).copyWith(
                                      elevation: MaterialStateProperty.resolveWith((states) {
                                        if (states.contains(MaterialState.hovered)) return 10;
                                        return 0;
                                      }),
                                    ),
                                    child: controller.isLoading.value
                                        ? const SizedBox(
                                        height: 24, width: 24,
                                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5)
                                    )
                                        : Text(
                                      'Acessar Sistema',
                                      style: GoogleFonts.outfit(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 0.5
                                      ),
                                    ),
                                  ),
                                )),

                                const SizedBox(height: 40),

                                // Rodapé
                                Center(
                                  child: Text(
                                    "© 2025 - Paroquia Nossa Senhora Auxiliadora",
                                    style: GoogleFonts.inter(
                                        fontSize: 12,
                                        color: theme.colorScheme.onSurface.withOpacity(0.4)
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
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

// =================================================
// INPUT MODERNO (Com animação de foco)
// =================================================
class _ModernInput extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool isPassword;
  final bool obscureText;
  final VoidCallback? onToggleVisibility;
  final String? errorText;
  final String? Function(String?)? validator;

  const _ModernInput({
    required this.label,
    required this.controller,
    required this.hint,
    required this.icon,
    this.isPassword = false,
    this.obscureText = false,
    this.onToggleVisibility,
    this.errorText,
    this.validator,
  });

  @override
  State<_ModernInput> createState() => _ModernInputState();
}

class _ModernInputState extends State<_ModernInput> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasError = widget.errorText != null;
    final primaryColor = const Color(0xFF1B4B29);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface.withOpacity(0.8),
          ),
        ),
        const SizedBox(height: 8),
        Focus(
          onFocusChange: (hasFocus) => setState(() => _isFocused = hasFocus),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: _isFocused ? Colors.white : theme.colorScheme.surfaceVariant.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: hasError
                    ? Colors.red
                    : (_isFocused ? primaryColor : Colors.transparent),
                width: 1.5,
              ),
              boxShadow: _isFocused && !hasError
                  ? [BoxShadow(color: primaryColor.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 4))]
                  : [],
            ),
            child: TextFormField(
              controller: widget.controller,
              obscureText: widget.obscureText,
              validator: widget.validator,
              style: GoogleFonts.inter(fontSize: 15, color: theme.colorScheme.onSurface),
              cursorColor: primaryColor,
              decoration: InputDecoration(
                hintText: widget.hint,
                hintStyle: GoogleFonts.inter(color: theme.colorScheme.onSurface.withOpacity(0.3)),
                prefixIcon: Icon(
                    widget.icon,
                    size: 20,
                    color: hasError ? Colors.red : (_isFocused ? primaryColor : theme.colorScheme.onSurface.withOpacity(0.4))
                ),
                suffixIcon: widget.isPassword
                    ? IconButton(
                  icon: Icon(
                    widget.obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    size: 20,
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                  ),
                  onPressed: widget.onToggleVisibility,
                )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              ),
            ),
          ),
        ),
        // Espaço para mensagem de erro (animação opcional)
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 4),
            child: Text(
              widget.errorText!,
              style: GoogleFonts.inter(color: Colors.red, fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ),
      ],
    );
  }
}
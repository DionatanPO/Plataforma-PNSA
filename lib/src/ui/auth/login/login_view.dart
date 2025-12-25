import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'login_controller.dart';

class LoginView extends StatelessWidget {
  LoginView({super.key});

  final controller = Get.find<LoginController>();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 900) {
          return _DesktopLayout(controller: controller);
        }
        return _MobileLayout(controller: controller);
      },
    );
  }
}

// =================================================
// LAYOUT MOBILE (Clean & Full Width)
// =================================================
class _MobileLayout extends StatelessWidget {
  final LoginController controller;
  const _MobileLayout({required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // No mobile, usamos o fundo puro (branco ou preto) para maximizar espaço
    // em vez de cinza, dando uma aparência de "App Nativo".
    final bgColor = isDark ? const Color(0xFF121212) : Colors.white;

    // Obtém a altura do teclado
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: bgColor,
        // Impede que o Scaffold seja espremido/empurrado para cima
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              // Adiciona padding na parte inferior igual à altura do teclado
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 24,
                bottom: 24 + bottomPadding,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment:
                    CrossAxisAlignment.stretch, // Força ocupar largura total
                children: [
                  const SizedBox(height: 20),
                  // Logo
                  Center(
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(Icons.church,
                          size: 32, color: theme.colorScheme.primary),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Textos de Boas-vindas (Centralizados)
                  Text(
                    'Bem-vindo',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Faça login para continuar',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Formulário direto na tela (Sem Card/BoxDecoration)
                  // Isso remove a sensação de "apertado"
                  _LoginFormBody(controller: controller),

                  const SizedBox(height: 40),

                  // Footer
                  Center(
                    child: Text(
                      "© 2025 Paróquia Nossa Sra. Auxiliadora",
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: theme.colorScheme.onSurface.withOpacity(0.4),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// =================================================
// LAYOUT DESKTOP (Split Screen - Mantido igual)
// =================================================
class _DesktopLayout extends StatelessWidget {
  final LoginController controller;
  const _DesktopLayout({required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      body: Row(
        children: [
          // Lado Esquerdo (Branding)
          Expanded(
            flex: 5,
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0A0A0A) : colorScheme.primary,
                image: !isDark
                    ? DecorationImage(
                        image: const NetworkImage(
                            "https://images.unsplash.com/photo-1438232992991-995b7058bbb3?q=80&w=1920&auto=format&fit=crop"),
                        fit: BoxFit.cover,
                        colorFilter: ColorFilter.mode(
                          colorScheme.primary.withOpacity(0.85),
                          BlendMode.multiply,
                        ),
                      )
                    : null,
              ),
              child: Padding(
                padding: const EdgeInsets.all(60.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.church_rounded,
                            color: Colors.white, size: 32),
                        const SizedBox(width: 12),
                        Text("PNSA Digital",
                            style: GoogleFonts.outfit(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Gestão Paroquial\nSimplificada.",
                            style: GoogleFonts.outfit(
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                height: 1.1)),
                        const SizedBox(height: 20),
                        Text("Acesse o painel administrativo.",
                            style: GoogleFonts.inter(
                                fontSize: 18,
                                color: Colors.white.withOpacity(0.8))),
                      ],
                    ),
                    Text("© 2025 Sistema PNSA",
                        style: GoogleFonts.inter(
                            color: Colors.white.withOpacity(0.5))),
                  ],
                ),
              ),
            ),
          ),
          // Lado Direito (Formulário)
          Expanded(
            flex: 4,
            child: Container(
              color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              alignment: Alignment.center,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(48),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Acessar Sistema',
                          style: GoogleFonts.outfit(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface)),
                      const SizedBox(height: 12),
                      Text('Insira suas credenciais abaixo.',
                          style: GoogleFonts.inter(
                              fontSize: 15,
                              color: theme.colorScheme.onSurface
                                  .withOpacity(0.6))),
                      const SizedBox(height: 40),
                      _LoginFormBody(controller: controller),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =================================================
// FORMULÁRIO (Componente Comum)
// =================================================
class _LoginFormBody extends StatelessWidget {
  final LoginController controller;
  const _LoginFormBody({required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Form(
      key: controller.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Obx(() => _ModernInput(
                label: "E-mail",
                controller: controller.emailController,
                hint: "seu@email.com",
                icon: Icons.alternate_email_rounded,
                errorText: controller.emailError.value,
                validator: controller.validateEmail,
                inputType: TextInputType.emailAddress,
              )),
          const SizedBox(height: 20),
          Obx(() => _ModernInput(
                label: "Senha",
                controller: controller.passwordController,
                hint: "Sua senha",
                icon: Icons.lock_outline_rounded,
                isPassword: true,
                obscureText: controller.obscurePassword.value,
                onToggleVisibility: controller.togglePasswordVisibility,
                errorText: controller.passwordError.value,
                validator: controller.validatePassword,
              )),

          const SizedBox(height: 24),

          Obx(() => SizedBox(
                width: double.infinity,
                height: 54, // Altura confortável para o dedo
                child: ElevatedButton(
                  onPressed:
                      controller.isLoading.value ? null : controller.login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: controller.isLoading.value
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2.5))
                      : Text('Entrar',
                          style: GoogleFonts.inter(
                              fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              )),

          // Botão discreto para Agente Dizimo no Windows
          if (!kIsWeb && GetPlatform.isWindows)
            Obx(() => Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: TextButton(
                      onPressed: controller.isLoading.value
                          ? null
                          : controller.loginAsAgent,
                      style: TextButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                      ),
                      child: Text(
                        'Agente Dizimo',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: theme.colorScheme.primary.withOpacity(0.6),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                )),

          // Erro
          Obx(() {
            if (controller.loginError.value == null)
              return const SizedBox.shrink();
            return Container(
              margin: const EdgeInsets.only(top: 20),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber_rounded,
                      color: Colors.red[700], size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                      child: Text(controller.loginError.value!,
                          style: GoogleFonts.inter(
                              color: Colors.red[800], fontSize: 13))),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

// =================================================
// INPUT MODERNO (Refinado para Mobile)
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
  final TextInputType inputType;

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
    this.inputType = TextInputType.text,
  });

  @override
  State<_ModernInput> createState() => _ModernInputState();
}

class _ModernInputState extends State<_ModernInput> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final hasError = widget.errorText != null;

    // Ajuste de cores para contraste melhor sem o card branco
    final fillColor =
        isDark ? const Color(0xFF1F1F1F) : const Color(0xFFF3F4F6);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface.withOpacity(0.8),
          ),
        ),
        const SizedBox(height: 8),
        Focus(
          onFocusChange: (focus) => setState(() => _isFocused = focus),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: fillColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: hasError
                    ? Colors.red
                    : (_isFocused ? colorScheme.primary : Colors.transparent),
                width: 1.5,
              ),
            ),
            child: TextFormField(
              controller: widget.controller,
              obscureText: widget.obscureText,
              keyboardType: widget.inputType,
              autofillHints: const [],
              enableSuggestions: false,
              autocorrect: false,
              style: GoogleFonts.inter(fontSize: 16), // Fonte maior para mobile
              decoration: InputDecoration(
                isDense: true,
                hintText: widget.hint,
                hintStyle: GoogleFonts.inter(
                    color: colorScheme.onSurface.withOpacity(0.35),
                    fontSize: 15),
                prefixIcon: Icon(widget.icon,
                    size: 22,
                    color: _isFocused
                        ? colorScheme.primary
                        : colorScheme.onSurface.withOpacity(0.4)),
                suffixIcon: widget.isPassword
                    ? IconButton(
                        icon: Icon(
                          widget.obscureText
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          size: 22,
                        ),
                        onPressed: widget.onToggleVisibility,
                        color: colorScheme.onSurface.withOpacity(0.5),
                      )
                    : null,
                border: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              ),
              validator: widget.validator,
            ),
          ),
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 4),
            child: Text(widget.errorText!,
                style: GoogleFonts.inter(
                    color: Colors.red,
                    fontSize: 12,
                    fontWeight: FontWeight.w500)),
          ),
      ],
    );
  }
}

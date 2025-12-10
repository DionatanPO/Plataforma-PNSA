// import 'dart:ui'; // Necessário para ImageFilter
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:google_fonts/google_fonts.dart';
// import '../../../routes/app_routes.dart';
// import 'login_controller.dart';
//
// class LoginView extends StatelessWidget {
//   LoginView({super.key});
//
//   final controller = Get.find<LoginController>();
//
//   // Imagem de fundo/lateral
//   final String bgImage = 'https://images.unsplash.com/photo-1521737604893-d14cc237f11d?ixlib=rb-1.2.1&auto=format&fit=crop&w=1920&q=80';
//
//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final isDark = theme.brightness == Brightness.dark;
//
//     return Scaffold(
//       body: Stack(
//         children: [
//           // 1. Fundo Global (Wallpaper)
//           Positioned.fill(
//             child: Container(
//               decoration: BoxDecoration(
//                 image: DecorationImage(
//                   image: NetworkImage(bgImage),
//                   fit: BoxFit.cover,
//                   colorFilter: ColorFilter.mode(
//                       Colors.black.withOpacity(0.3),
//                       BlendMode.darken
//                   ),
//                 ),
//               ),
//             ),
//           ),
//
//           // 2. Blur Effect (Vidro Fosco)
//           Positioned.fill(
//             child: BackdropFilter(
//               filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
//               child: Container(
//                 color: theme.scaffoldBackgroundColor.withOpacity(isDark ? 0.85 : 0.90),
//               ),
//             ),
//           ),
//
//           // 3. Conteúdo Centralizado
//           Center(
//             child: LayoutBuilder(
//               builder: (context, constraints) {
//                 if (constraints.maxWidth > 900) {
//                   return _buildDesktopCard(context, theme);
//                 } else {
//                   return _buildMobileLayout(context, theme);
//                 }
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // =========================================================
//   // LAYOUT DESKTOP (Card Flutuante)
//   // =========================================================
//   Widget _buildDesktopCard(BuildContext context, ThemeData theme) {
//     return Container(
//       width: 950,
//       height: 650,
//       decoration: BoxDecoration(
//         color: theme.colorScheme.surface,
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: theme.dividerColor.withOpacity(0.2)),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.2),
//             blurRadius: 40,
//             offset: const Offset(0, 20),
//           ),
//         ],
//       ),
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(16),
//         child: Row(
//           children: [
//             // Esquerda: Imagem e Branding
//             Expanded(
//               flex: 5,
//               child: Container(
//                 decoration: BoxDecoration(
//                   image: DecorationImage(
//                     image: NetworkImage(bgImage),
//                     fit: BoxFit.cover,
//                   ),
//                 ),
//                 child: Container(
//                   decoration: BoxDecoration(
//                     gradient: LinearGradient(
//                       begin: Alignment.topCenter,
//                       end: Alignment.bottomCenter,
//                       colors: [
//                         theme.primaryColor.withOpacity(0.4),
//                         Colors.black.withOpacity(0.8),
//                       ],
//                     ),
//                   ),
//                   padding: const EdgeInsets.all(40),
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.end,
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Container(
//                         padding: const EdgeInsets.all(12),
//                         decoration: BoxDecoration(
//                           color: Colors.white.withOpacity(0.2),
//                           borderRadius: BorderRadius.circular(12),
//                           border: Border.all(color: Colors.white.withOpacity(0.3)),
//                         ),
//                         child: const Icon(Icons.auto_awesome, color: Colors.white, size: 32),
//                       ),
//                       const SizedBox(height: 24),
//                       Text(
//                         'Bem-vindo\nde volta.',
//                         style: GoogleFonts.outfit(
//                           fontSize: 42,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.white,
//                           height: 1.1,
//                         ),
//                       ),
//                       const SizedBox(height: 16),
//                       Text(
//                         'Acesse seu painel para continuar gerenciando seus projetos com inteligência.',
//                         style: GoogleFonts.inter(
//                           fontSize: 16,
//                           color: Colors.white.withOpacity(0.9),
//                           height: 1.5,
//                         ),
//                       ),
//                       const SizedBox(height: 20),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//
//             // Direita: Formulário
//             Expanded(
//               flex: 6,
//               child: Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 40),
//                 child: _LoginForm(controller: controller, isDesktop: true),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   // =========================================================
//   // LAYOUT MOBILE
//   // =========================================================
//   Widget _buildMobileLayout(BuildContext context, ThemeData theme) {
//     return Center(
//       child: SingleChildScrollView(
//         padding: const EdgeInsets.all(24),
//         child: Card(
//           elevation: 0,
//           color: Colors.transparent, // No mobile, deixa transparente sobre o blur
//           child: _LoginForm(controller: controller, isDesktop: false),
//         ),
//       ),
//     );
//   }
// }
//
// // =========================================================
// // FORMULÁRIO REUTILIZÁVEL
// // =========================================================
// class _LoginForm extends StatelessWidget {
//   final LoginController controller;
//   final bool isDesktop;
//
//   const _LoginForm({required this.controller, required this.isDesktop});
//
//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final primaryColor = theme.primaryColor;
//
//     return Form(
//       key: controller.formKey,
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Cabeçalho do Form
//           Text(
//             'Login',
//             style: GoogleFonts.outfit(
//               fontSize: 32,
//               fontWeight: FontWeight.bold,
//               color: theme.colorScheme.onSurface,
//             ),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             'Entre com suas credenciais abaixo.',
//             style: GoogleFonts.inter(
//               fontSize: 14,
//               color: theme.colorScheme.onSurface.withOpacity(0.6),
//             ),
//           ),
//           const SizedBox(height: 40),
//
//           // Inputs
//           _DesktopInput(
//             controller: controller.emailController,
//             label: "E-mail",
//             hint: "exemplo@email.com",
//             icon: Icons.email_outlined,
//             validator: (v) => (v == null || !GetUtils.isEmail(v)) ? 'E-mail inválido' : null,
//           ),
//           const SizedBox(height: 20),
//
//           Obx(() => _DesktopInput(
//             controller: controller.passwordController,
//             label: "Senha",
//             hint: "••••••••",
//             icon: Icons.lock_outline,
//             obscureText: controller.obscurePassword.value,
//             validator: (v) => (v == null || v.length < 6) ? 'Mínimo 6 caracteres' : null,
//             suffix: IconButton(
//               icon: Icon(
//                 controller.obscurePassword.value ? Icons.visibility_off_outlined : Icons.visibility_outlined,
//                 size: 20,
//                 color: theme.colorScheme.onSurface.withOpacity(0.5),
//               ),
//               onPressed: controller.togglePasswordVisibility,
//             ),
//           )),
//
//           // Esqueceu a senha
//           Align(
//             alignment: Alignment.centerRight,
//             child: TextButton(
//               onPressed: () => Get.toNamed(AppRoutes.forgotPassword),
//               style: TextButton.styleFrom(
//                 foregroundColor: primaryColor,
//                 padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 12),
//               ),
//               child: Text(
//                 'Esqueceu a senha?',
//                 style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13),
//               ),
//             ),
//           ),
//
//           const SizedBox(height: 24),
//
//           // Botão Login
//           Obx(() => SizedBox(
//             width: double.infinity,
//             height: 50,
//             child: ElevatedButton(
//               onPressed: controller.isLoading.value ? null : controller.login,
//               style: ButtonStyle(
//                 backgroundColor: MaterialStateProperty.resolveWith((states) {
//                   if (states.contains(MaterialState.disabled)) return theme.disabledColor;
//                   if (states.contains(MaterialState.hovered)) return primaryColor.withOpacity(0.9);
//                   return primaryColor;
//                 }),
//                 elevation: MaterialStateProperty.all(0), // Flat style
//                 shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
//                 mouseCursor: MaterialStateProperty.all(SystemMouseCursors.click),
//               ),
//               child: controller.isLoading.value
//                   ? const SizedBox(
//                 width: 20, height: 20,
//                 child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
//               )
//                   : Text(
//                 'Entrar',
//                 style: GoogleFonts.inter(
//                   fontSize: 15,
//                   fontWeight: FontWeight.w600,
//                   color: Colors.white,
//                 ),
//               ),
//             ),
//           )),
//
//           const SizedBox(height: 30),
//
//           // Divisor
//           Row(
//             children: [
//               Expanded(child: Divider(color: theme.dividerColor.withOpacity(0.2))),
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 16),
//                 child: Text('OU', style: GoogleFonts.inter(fontSize: 11, color: theme.disabledColor, fontWeight: FontWeight.bold)),
//               ),
//               Expanded(child: Divider(color: theme.dividerColor.withOpacity(0.2))),
//             ],
//           ),
//
//           const SizedBox(height: 30),
//
//           // Botão Criar Conta
//           SizedBox(
//             width: double.infinity,
//             height: 50,
//             child: OutlinedButton(
//               onPressed: () => Get.toNamed(AppRoutes.register),
//               style: OutlinedButton.styleFrom(
//                 side: BorderSide(color: theme.dividerColor.withOpacity(0.4)),
//                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//                 foregroundColor: theme.colorScheme.onSurface,
//               ),
//               child: Text(
//                 'Criar conta gratuita',
//                 style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// // =========================================================
// // COMPONENTE DE INPUT ESTILO DESKTOP
// // =========================================================
// class _DesktopInput extends StatefulWidget {
//   final TextEditingController controller;
//   final String label;
//   final String hint;
//   final IconData icon;
//   final bool obscureText;
//   final Widget? suffix;
//   final String? Function(String?)? validator;
//
//   const _DesktopInput({
//     required this.controller,
//     required this.label,
//     required this.hint,
//     required this.icon,
//     this.obscureText = false,
//     this.suffix,
//     this.validator,
//   });
//
//   @override
//   State<_DesktopInput> createState() => _DesktopInputState();
// }
//
// class _DesktopInputState extends State<_DesktopInput> {
//   bool _isHovering = false;
//
//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final isDark = theme.brightness == Brightness.dark;
//
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // Label fora do campo (Estilo Desktop Form)
//         Text(
//           widget.label,
//           style: GoogleFonts.inter(
//             fontSize: 13,
//             fontWeight: FontWeight.w500,
//             color: theme.colorScheme.onSurface.withOpacity(0.8),
//           ),
//         ),
//         const SizedBox(height: 8),
//         MouseRegion(
//           onEnter: (_) => setState(() => _isHovering = true),
//           onExit: (_) => setState(() => _isHovering = false),
//           child: TextFormField(
//             controller: widget.controller,
//             obscureText: widget.obscureText,
//             validator: widget.validator,
//             style: GoogleFonts.inter(fontSize: 14),
//             decoration: InputDecoration(
//               hintText: widget.hint,
//               hintStyle: GoogleFonts.inter(
//                 color: theme.colorScheme.onSurface.withOpacity(0.3),
//                 fontSize: 14,
//               ),
//               prefixIcon: Icon(widget.icon, size: 18, color: theme.colorScheme.onSurface.withOpacity(0.5)),
//               suffixIcon: widget.suffix,
//               filled: true,
//               // Fundo sutil que muda no hover
//               fillColor: _isHovering
//                   ? theme.colorScheme.surfaceVariant.withOpacity(0.4)
//                   : theme.colorScheme.surfaceVariant.withOpacity(0.2),
//
//               // Bordas mais finas e discretas
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(8),
//                 borderSide: BorderSide.none,
//               ),
//               enabledBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(8),
//                 borderSide: BorderSide(
//                     color: theme.dividerColor.withOpacity(0.1),
//                     width: 1
//                 ),
//               ),
//               focusedBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(8),
//                 borderSide: BorderSide(
//                     color: theme.primaryColor,
//                     width: 1.5
//                 ),
//               ),
//               contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../routes/app_routes.dart';
import 'login_controller.dart';

class LoginView extends StatelessWidget {
  LoginView({super.key});

  final controller = Get.find<LoginController>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Detecta se é desktop (largura > 1000px)
    final isDesktop = MediaQuery.of(context).size.width > 1000;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Row(
        children: [
          // =================================================
          // LADO ESQUERDO: VISUAL / BRANDING (Apenas Desktop)
          // =================================================
          if (isDesktop)
            Expanded(
              flex: 1, // Ocupa 50% da tela (ou ajuste para mudar a proporção)
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black, // Fundo base caso a imagem falhe
                  image: DecorationImage(
                    // Imagem mais abstrata e arquitetônica
                    image: const NetworkImage(
                      'https://images.unsplash.com/photo-1497366216548-37526070297c?q=80&w=1920&auto=format&fit=crop',
                    ),
                    fit: BoxFit.cover,
                    // Filtro escuro para garantir que textos brancos fiquem legíveis
                    colorFilter: ColorFilter.mode(
                      Colors.black.withOpacity(0.4),
                      BlendMode.darken,
                    ),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(60.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Logo simples no topo
                      Row(
                        children: [
                          Icon(
                            Icons.hexagon_outlined,
                            color: Colors.white,
                            size: 32,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            "Enterprise",
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 24,
                            ),
                          ),
                        ],
                      ),

                      // Citação ou Texto de Marketing no rodapé
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '"A simplicidade é o último grau de sofisticação."',
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.w600,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Gerencie seus projetos com clareza absoluta.',
                            style: GoogleFonts.inter(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // =================================================
          // LADO DIREITO: FORMULÁRIO (Clean & Minimal)
          // =================================================
          Expanded(
            flex: 1,
            child: Container(
              color: theme.scaffoldBackgroundColor, // Cor sólida, sem blur
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(40),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Cabeçalho do Form
                        // No mobile mostramos o logo aqui já que a barra lateral sumiu
                        if (!isDesktop) ...[
                          Icon(
                            Icons.hexagon_rounded,
                            size: 40,
                            color: theme.primaryColor,
                          ),
                          const SizedBox(height: 24),
                        ],

                        Text(
                          'Olá novamente',
                          style: GoogleFonts.outfit(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                            letterSpacing:
                                -1, // Tracking apertado (tendência moderna)
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Digite seus dados para acessar o painel.',
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            color: theme.colorScheme.onSurface.withOpacity(0.5),
                          ),
                        ),
                        const SizedBox(height: 48),

                        // Inputs (Estilo Minimalista)
                        Form(
                          key: controller.formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Obx(() => _MinimalInput(
                                label: "Email",
                                controller: controller.emailController,
                                hint: "nome@empresa.com",
                                icon: Icons.alternate_email_rounded,
                                validator: controller.validateEmail,
                                errorText: controller.emailError.value,
                              )),
                              const SizedBox(height: 24),
                              Obx(() => _MinimalInput(
                                label: "Senha",
                                controller: controller.passwordController,
                                hint: "Sua senha segura",
                                icon: Icons.lock_outline_rounded,
                                isPassword: true,
                                obscureText: controller.obscurePassword.value,
                                onToggleVisibility: controller.togglePasswordVisibility,
                                validator: controller.validatePassword,
                                errorText: controller.passwordError.value,
                              )),
                            ],
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Botão Principal (Full Width)
                        Obx(
                          () => SizedBox(
                            width: double.infinity,
                            height: 56, // Altura confortável para mouse
                            child: ElevatedButton(
                              onPressed:
                                  controller.isLoading.value
                                      ? null
                                      : controller.login,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.primaryColor,
                                foregroundColor: Colors.white,
                                elevation: 0, // Flat design total
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    8,
                                  ), // Bordas levemente arredondadas
                                ),
                              ),
                              child:
                                  controller.isLoading.value
                                      ? const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2.5,
                                        ),
                                      )
                                      : Text(
                                        'Entrar na conta',
                                        style: GoogleFonts.inter(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                            ),
                          ),
                        ),
                      ],
                    ),
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
// INPUT MINIMALISTA (Estilo Notion / Linear)
// =================================================
class _MinimalInput extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool isPassword;
  final bool obscureText;
  final VoidCallback? onToggleVisibility;
  final String? Function(String?)? validator;
  final String? errorText;

  const _MinimalInput({
    required this.label,
    required this.controller,
    required this.hint,
    required this.icon,
    this.isPassword = false,
    this.obscureText = false,
    this.onToggleVisibility,
    this.validator,
    this.errorText,
  });

  @override
  State<_MinimalInput> createState() => _MinimalInputState();
}

class _MinimalInputState extends State<_MinimalInput> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label fora
        Text(
          widget.label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),

        // Campo
        Focus(
          onFocusChange: (hasFocus) => setState(() => _isFocused = hasFocus),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                // Borda muda de cor ao focar (Padrão Desktop)
                color:
                    _isFocused || widget.errorText != null
                        ? (widget.errorText != null ? Colors.red : theme.primaryColor)
                        : theme.dividerColor.withOpacity(0.5),
                width: _isFocused || widget.errorText != null ? 1.5 : 1.0,
              ),
            ),
            child: TextFormField(
              controller: widget.controller,
              obscureText: widget.obscureText,
              style: GoogleFonts.inter(fontSize: 15),
              cursorColor: theme.primaryColor,
              validator: widget.validator,
              decoration: InputDecoration(
                hintText: widget.hint,
                hintStyle: GoogleFonts.inter(
                  color: theme.colorScheme.onSurface.withOpacity(0.3),
                ),
                prefixIcon: Icon(
                  widget.icon,
                  size: 20,
                  color:
                      _isFocused || widget.errorText != null
                          ? (widget.errorText != null ? Colors.red : theme.primaryColor)
                          : theme.colorScheme.onSurface.withOpacity(0.4),
                ),
                suffixIcon:
                    widget.isPassword
                        ? IconButton(
                          icon: Icon(
                            widget.obscureText
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            size: 20,
                            color: theme.colorScheme.onSurface.withOpacity(0.5),
                          ),
                          onPressed: widget.onToggleVisibility,
                        )
                        : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 18,
                  horizontal: 16,
                ),
                errorText: widget.errorText,
                errorStyle: GoogleFonts.inter(
                  fontSize: 12,
                  color: Colors.red,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

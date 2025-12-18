import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

// Importe seu controller e a CustomSliverAppBar aqui

import '../../core/widgets/custom_sliver_app_bar.dart';
import 'edit_profile_controller.dart';

class EditProfileView extends StatelessWidget {
  EditProfileView({super.key});

  final controller = Get.put(EditProfileController());

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width >= 900;

    // === AJUSTE DE CORES ===
    // Dark: 0xFF202020 é mais suave que o preto total
    // Light: 0xFFF3F3F3 garante que os inputs brancos apareçam
    final bgColor = theme.brightness == Brightness.dark
        ? const Color(0xFF202020)
        : const Color(0xFFF3F3F3);

    return Scaffold(
      backgroundColor: bgColor,
      resizeToAvoidBottomInset: true,
      extendBodyBehindAppBar: true,
      // ADICIONADO: Scrollbar é essencial para Desktop
      body: Scrollbar(
        controller: controller.scrollController,
        thumbVisibility: true,
        thickness: 8,
        radius: const Radius.circular(4),
        child: CustomScrollView(
          controller: controller.scrollController,
          physics: const BouncingScrollPhysics(),
          slivers: [
            // 1. APP BAR CUSTOMIZADA
            CustomSliverAppBar(
              title: 'Editar Perfil',
              subtitle: 'Gerencie suas informações pessoais e segurança',
              centerTitle: false,
              // Para garantir que o blur funcione bem com a nova cor de fundo
              backgroundColor: bgColor.withOpacity(0.8),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Obx(
                    () => FilledButton.icon(
                      onPressed: controller.isLoading.value
                          ? null
                          : controller.saveProfile,
                      icon: const Icon(Icons.save_outlined, size: 18),
                      label: const Text("Salvar"),
                      style: FilledButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // 2. CONTEÚDO
            SliverToBoxAdapter(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: Padding(
                    padding: EdgeInsets.only(
                      top: isDesktop ? 100 : 20,
                      left: 24,
                      right: 24,
                      bottom: 40,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Cabeçalho Visual com Avatar
                        Center(
                          child: Column(
                            children: [
                              _ProfileAvatar(
                                controller: controller,
                                theme: theme,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                controller.nameController.text.isEmpty
                                    ? "Nome do Usuário"
                                    : controller.nameController.text,
                                style: GoogleFonts.outfit(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                              Text(
                                "Product Designer",
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: theme.colorScheme.onSurface
                                      .withOpacity(0.6),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 40),

                        // FORMULÁRIO
                        Form(
                          key: controller.formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _SectionHeader(title: "Informações Básicas"),
                              if (isDesktop)
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: _ModernInput(
                                        label: "Nome Completo",
                                        controller: controller.nameController,
                                        icon: Icons.person_outline,
                                        validator: (v) =>
                                            v!.isEmpty ? "Obrigatório" : null,
                                      ),
                                    ),
                                    const SizedBox(width: 24),
                                    Expanded(
                                      child: _ModernInput(
                                        label: "Cargo / Função",
                                        controller: TextEditingController(
                                          text: "Product Designer",
                                        ),
                                        icon: Icons.work_outline,
                                      ),
                                    ),
                                  ],
                                )
                              else ...[
                                _ModernInput(
                                  label: "Nome Completo",
                                  controller: controller.nameController,
                                  icon: Icons.person_outline,
                                  validator: (v) =>
                                      v!.isEmpty ? "Obrigatório" : null,
                                ),
                                const SizedBox(height: 20),
                                _ModernInput(
                                  label: "Cargo / Função",
                                  controller: TextEditingController(
                                    text: "Product Designer",
                                  ),
                                  icon: Icons.work_outline,
                                ),
                              ],
                              const SizedBox(height: 20),
                              _ModernInput(
                                label: "Bio / Sobre",
                                controller: TextEditingController(),
                                hint:
                                    "Escreva uma breve descrição sobre você...",
                                icon: Icons.edit_note,
                                maxLines: 4,
                              ),
                              const SizedBox(height: 40),
                              Divider(
                                color: theme.dividerColor.withOpacity(0.1),
                              ),
                              const SizedBox(height: 40),
                              _SectionHeader(title: "Contato e Segurança"),
                              if (isDesktop)
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: _ModernInput(
                                        label: "E-mail Corporativo",
                                        controller: controller.emailController,
                                        icon: Icons.email_outlined,
                                        validator: (v) => !GetUtils.isEmail(v!)
                                            ? "Inválido"
                                            : null,
                                      ),
                                    ),
                                    const SizedBox(width: 24),
                                    Expanded(
                                      child: _ModernInput(
                                        label: "Telefone",
                                        controller: TextEditingController(),
                                        hint: "(00) 00000-0000",
                                        icon: Icons.phone_outlined,
                                      ),
                                    ),
                                  ],
                                )
                              else ...[
                                _ModernInput(
                                  label: "E-mail Corporativo",
                                  controller: controller.emailController,
                                  icon: Icons.email_outlined,
                                  validator: (v) =>
                                      !GetUtils.isEmail(v!) ? "Inválido" : null,
                                ),
                                const SizedBox(height: 20),
                                _ModernInput(
                                  label: "Telefone",
                                  controller: TextEditingController(),
                                  hint: "(00) 00000-0000",
                                  icon: Icons.phone_outlined,
                                ),
                              ],
                              const SizedBox(height: 60),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =========================================================
// WIDGETS AUXILIARES
// =========================================================

class _ProfileAvatar extends StatelessWidget {
  final EditProfileController controller;
  final ThemeData theme;

  const _ProfileAvatar({required this.controller, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Obx(
          () => Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: theme.dividerColor.withOpacity(0.1),
                width: 1,
              ),
              // Sombra suave para destacar do fundo mais claro
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 50,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              backgroundImage: NetworkImage(controller.avatarUrl.value),
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: Material(
            color: theme.primaryColor,
            shape: const CircleBorder(),
            elevation: 2,
            child: InkWell(
              onTap: controller.pickImage,
              customBorder: const CircleBorder(),
              child: const Padding(
                padding: EdgeInsets.all(8),
                child: Icon(
                  Icons.camera_alt_outlined,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }
}

class _ModernInput extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final IconData icon;
  final String? hint;
  final int maxLines;
  final String? Function(String?)? validator;

  const _ModernInput({
    required this.label,
    required this.controller,
    required this.icon,
    this.hint,
    this.maxLines = 1,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final borderColor = theme.dividerColor.withOpacity(0.3);
    final focusColor = theme.primaryColor;
    final errorColor = theme.colorScheme.error;

    // === AJUSTE DE COR DOS INPUTS ===
    // Dark: 0xFF2C2C2C (Sutilmente mais claro que o fundo 0xFF202020 para criar contraste de "card")
    // Light: White (Sutilmente mais claro que o fundo 0xFFF3F3F3)
    final fillColor = isDark ? const Color(0xFF2C2C2C) : Colors.white;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          maxLines: maxLines,
          style: GoogleFonts.inter(fontSize: 15),
          cursorColor: theme.primaryColor,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.inter(
              color: theme.colorScheme.onSurface.withOpacity(0.3),
            ),
            prefixIcon: Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Icon(
                icon,
                size: 20,
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
            filled: true,
            fillColor: fillColor,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: focusColor, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: errorColor),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: errorColor, width: 1.5),
            ),
            errorStyle: GoogleFonts.inter(fontSize: 12, height: 1.2),
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Barra de busca moderna e reutilizável com animações e efeitos visuais premium.
///
/// Características:
/// - Animações suaves de focus e hover
/// - Ícone de busca estilizado com container animado
/// - Botão de limpar com animação de scale/fade
/// - Adaptação automática para tema claro/escuro
/// - Bordas e sombras que respondem ao estado
class ModernSearchBar extends StatefulWidget {
  /// Controller do campo de texto
  final TextEditingController controller;

  /// Callback chamado quando o texto muda
  final ValueChanged<String> onChanged;

  /// Texto de placeholder
  final String hintText;

  /// Se true, mostra um listener para atualizar o estado quando o texto muda
  final bool autoUpdate;

  const ModernSearchBar({
    Key? key,
    required this.controller,
    required this.onChanged,
    this.hintText = 'Buscar...',
    this.autoUpdate = false,
  }) : super(key: key);

  @override
  State<ModernSearchBar> createState() => _ModernSearchBarState();
}

class _ModernSearchBarState extends State<ModernSearchBar> {
  bool _isFocused = false;
  bool _isHovering = false;

  @override
  void initState() {
    super.initState();
    if (widget.autoUpdate) {
      widget.controller.addListener(_onTextChanged);
    }
  }

  @override
  void dispose() {
    if (widget.autoUpdate) {
      widget.controller.removeListener(_onTextChanged);
    }
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Cores modernas e refinadas
    final surfaceColor = isDark ? const Color(0xFF1A1A1A) : Colors.white;
    final backgroundColor = isDark
        ? const Color(0xFF252525)
        : const Color(0xFFF8FAFC);
    final accentColor = theme.primaryColor;

    // Cores de estado
    final borderColor = _isFocused
        ? accentColor.withOpacity(0.5)
        : (_isHovering
              ? theme.dividerColor.withOpacity(0.2)
              : theme.dividerColor.withOpacity(0.1));

    final iconColor = _isFocused
        ? accentColor
        : theme.colorScheme.onSurface.withOpacity(0.4);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: _isFocused ? 1.5 : 1),
          boxShadow: [
            BoxShadow(
              color: _isFocused
                  ? accentColor.withOpacity(0.08)
                  : Colors.black.withOpacity(isDark ? 0.15 : 0.04),
              blurRadius: _isFocused ? 20 : 12,
              offset: const Offset(0, 4),
              spreadRadius: _isFocused ? 2 : 0,
            ),
          ],
        ),
        child: Row(
          children: [
            // Ícone de busca com container estilizado
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(left: 16),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _isFocused
                    ? accentColor.withOpacity(0.1)
                    : backgroundColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.search_rounded, color: iconColor, size: 18),
            ),

            // Campo de texto
            Expanded(
              child: Focus(
                onFocusChange: (focused) =>
                    setState(() => _isFocused = focused),
                child: TextField(
                  controller: widget.controller,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: theme.colorScheme.onSurface,
                  ),
                  decoration: InputDecoration(
                    hintText: widget.hintText,
                    hintStyle: GoogleFonts.inter(
                      color: theme.colorScheme.onSurface.withOpacity(0.35),
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 16,
                    ),
                  ),
                  onChanged: widget.onChanged,
                ),
              ),
            ),

            // Botão de limpar (aparece apenas quando há texto)
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (child, animation) => ScaleTransition(
                scale: animation,
                child: FadeTransition(opacity: animation, child: child),
              ),
              child: widget.controller.text.isNotEmpty
                  ? Container(
                      key: const ValueKey('clear'),
                      margin: const EdgeInsets.only(right: 8),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            widget.controller.clear();
                            widget.onChanged('');
                            setState(() {});
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.onSurface.withOpacity(
                                0.05,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.close_rounded,
                              color: theme.colorScheme.onSurface.withOpacity(
                                0.4,
                              ),
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    )
                  : const SizedBox(width: 16, key: ValueKey('empty')),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

/// Um widget que monitora se o teclado fechou e força a limpeza do foco
class KeyboardDismissOnCollapse extends StatefulWidget {
  final Widget child;

  const KeyboardDismissOnCollapse({super.key, required this.child});

  @override
  State<KeyboardDismissOnCollapse> createState() => _KeyboardDismissOnCollapseState();
}

class _KeyboardDismissOnCollapseState extends State<KeyboardDismissOnCollapse> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    
    // Verifica se o teclado fechou
    // viewInsets.bottom == 0 significa que não há teclado na tela
    final bottomInset = View.of(context).viewInsets.bottom;
    
    if (bottomInset == 0.0) {
      // Pequeno delay para garantir que não é apenas uma transição de campos
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted && View.of(context).viewInsets.bottom == 0.0) {
          // A MÁGICA: Isso simula o "clicar fora"
          FocusManager.instance.primaryFocus?.unfocus();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

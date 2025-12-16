import 'package:flutter/material.dart';
import '../../core/widgets/modern_header.dart';

class AccessManagementHeader extends StatelessWidget {
  final VoidCallback onAddUserPressed;

  const AccessManagementHeader({Key? key, required this.onAddUserPressed})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ModernHeader(
      title: 'Gestão de Acesso',
      subtitle: 'Administre usuários e permissões do sistema',
      icon: Icons.admin_panel_settings_rounded,
      onActionPressed: onAddUserPressed,
      actionLabel: 'Novo Usuário',
      actionIcon: Icons.add_rounded,
      actionColor: Colors.green,
    );
  }
}

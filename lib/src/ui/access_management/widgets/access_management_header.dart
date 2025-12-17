import 'package:flutter/material.dart';
import '../../core/widgets/modern_header.dart';

class AccessManagementHeader extends StatelessWidget {
  const AccessManagementHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ModernHeader(
      title: 'Gestão de Acesso',
      subtitle: 'Administre usuários e permissões do sistema',
      icon: Icons.admin_panel_settings_rounded,
    );
  }
}

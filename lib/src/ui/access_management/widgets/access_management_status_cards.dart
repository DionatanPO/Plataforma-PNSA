import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/role_info_card.dart';

class AccessManagementStatusCards extends StatelessWidget {
  const AccessManagementStatusCards({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 700) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: RoleInfoCard(title: 'Ativo', description: 'O usuário possui acesso liberado ao sistema conforme seu perfil. Pode realizar login e registrar operações normalmente.', icon: Icons.check_circle_outline_rounded, color: Colors.green)),
              const SizedBox(width: 16),
              Expanded(child: RoleInfoCard(title: 'Inativo', description: 'O acesso ao sistema está bloqueado. O usuário não pode fazer login, mas seu histórico de ações é preservado para auditoria.', icon: Icons.block_rounded, color: Colors.grey)),
            ],
          );
        } else {
          return Column(
            children: [
              RoleInfoCard(title: 'Ativo', description: 'O usuário possui acesso liberado ao sistema conforme seu perfil. Pode realizar login e registrar operações normalmente.', icon: Icons.check_circle_outline_rounded, color: Colors.green),
              const SizedBox(height: 12),
              RoleInfoCard(title: 'Inativo', description: 'O acesso ao sistema está bloqueado. O usuário não pode fazer login, mas seu histórico de ações é preservado para auditoria.', icon: Icons.block_rounded, color: Colors.grey),
            ],
          );
        }
      },
    );
  }
}
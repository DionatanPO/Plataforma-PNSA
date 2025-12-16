import 'package:flutter/material.dart';
import '../widgets/role_info_card.dart';

class AccessManagementFunctionCards extends StatelessWidget {
  const AccessManagementFunctionCards({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 900) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: RoleInfoCard(title: 'Administrador', description: 'Gerencia toda a plataforma, cria novos usuários e tem acesso irrestrito aos relatórios financeiros sensíveis.', icon: Icons.admin_panel_settings_rounded, color: Colors.purple)),
              const SizedBox(width: 16),
              Expanded(child: RoleInfoCard(title: 'Secretaria', description: 'Foca no cadastro e atualização de dados dos dizimistas, além de lançar contribuições do dia a dia.', icon: Icons.support_agent_rounded, color: Colors.blue)),
              const SizedBox(width: 16),
              Expanded(child: RoleInfoCard(title: 'Financeiro', description: 'Visualiza fluxo de caixa, emite relatórios para contabilidade e analisa a saúde financeira da paróquia.', icon: Icons.analytics_rounded, color: Colors.green)),
            ],
          );
        } else {
          return Column(
            children: [
              RoleInfoCard(title: 'Administrador', description: 'Gerencia toda a plataforma, cria novos usuários e tem acesso irrestrito aos relatórios financeiros sensíveis.', icon: Icons.admin_panel_settings_rounded, color: Colors.purple),
              const SizedBox(height: 12),
              RoleInfoCard(title: 'Secretaria', description: 'Foca no cadastro e atualização de dados dos dizimistas, além de lançar contribuições do dia a dia.', icon: Icons.support_agent_rounded, color: Colors.blue),
              const SizedBox(height: 12),
              RoleInfoCard(title: 'Financeiro', description: 'Visualiza fluxo de caixa, emite relatórios para contabilidade e analisa a saúde financeira da paróquia.', icon: Icons.analytics_rounded, color: Colors.green),
            ],
          );
        }
      },
    );
  }
}
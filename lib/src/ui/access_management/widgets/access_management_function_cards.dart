import 'package:flutter/material.dart';
import '../widgets/role_info_card.dart';

class AccessManagementFunctionCards extends StatelessWidget {
  const AccessManagementFunctionCards({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 1100) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                  child: RoleInfoCard(
                      title: 'Administrador',
                      description:
                          'Gerencia toda a plataforma, cria novos usuários e tem acesso irrestrito aos relatórios financeiros sensíveis.',
                      icon: Icons.admin_panel_settings_rounded,
                      color: Colors.purple)),
              const SizedBox(width: 16),
              Expanded(
                  child: RoleInfoCard(
                      title: 'Secretaria',
                      description:
                          'Foca no cadastro e atualização de dados dos dizimistas, além de lançar contribuições do dia a dia.',
                      icon: Icons.support_agent_rounded,
                      color: Colors.blue)),
              const SizedBox(width: 16),
              Expanded(
                  child: RoleInfoCard(
                      title: 'Financeiro',
                      description:
                          'Visualiza fluxo de caixa, emite relatórios para contabilidade e analisa a saúde financeira da paróquia.',
                      icon: Icons.analytics_rounded,
                      color: Colors.green)),
              const SizedBox(width: 16),
              Expanded(
                  child: RoleInfoCard(
                      title: 'Agente de Dízimo',
                      description:
                          'Atua no campo e após celebrações realizando cadastros e recebimentos rápidos.',
                      icon: Icons.badge_rounded,
                      color: Colors.orange)),
            ],
          );
        } else if (constraints.maxWidth > 650) {
          return Column(
            children: [
              Row(
                children: [
                  Expanded(
                      child: RoleInfoCard(
                          title: 'Administrador',
                          description: 'Gerencia toda a plataforma...',
                          icon: Icons.admin_panel_settings_rounded,
                          color: Colors.purple)),
                  const SizedBox(width: 16),
                  Expanded(
                      child: RoleInfoCard(
                          title: 'Secretaria',
                          description: 'Foca no cadastro...',
                          icon: Icons.support_agent_rounded,
                          color: Colors.blue)),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                      child: RoleInfoCard(
                          title: 'Financeiro',
                          description: 'Visualiza fluxo de caixa...',
                          icon: Icons.analytics_rounded,
                          color: Colors.green)),
                  const SizedBox(width: 16),
                  Expanded(
                      child: RoleInfoCard(
                          title: 'Agente de Dízimo',
                          description: 'Atua no campo...',
                          icon: Icons.badge_rounded,
                          color: Colors.orange)),
                ],
              ),
            ],
          );
        } else {
          return Column(
            children: [
              RoleInfoCard(
                  title: 'Administrador',
                  description:
                      'Gerencia toda a plataforma, cria novos usuários e tem acesso irrestrito aos relatórios financeiros sensíveis.',
                  icon: Icons.admin_panel_settings_rounded,
                  color: Colors.purple),
              const SizedBox(height: 12),
              RoleInfoCard(
                  title: 'Secretaria',
                  description:
                      'Foca no cadastro e atualização de dados dos dizimistas, além de lançar contribuições do dia a dia.',
                  icon: Icons.support_agent_rounded,
                  color: Colors.blue),
              const SizedBox(height: 12),
              RoleInfoCard(
                  title: 'Financeiro',
                  description:
                      'Visualiza fluxo de caixa, emite relatórios para contabilidade e analisa a saúde financeira da paróquia.',
                  icon: Icons.analytics_rounded,
                  color: Colors.green),
              const SizedBox(height: 12),
              RoleInfoCard(
                  title: 'Agente de Dízimo',
                  description:
                      'Responsável pela captação e registro de novos dizimistas e contribuições em campo ou após as celebrações.',
                  icon: Icons.badge_rounded,
                  color: Colors.orange),
            ],
          );
        }
      },
    );
  }
}

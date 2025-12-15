import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import '../../../domain/models/acesso_model.dart';
import '../controllers/access_management_controller.dart';

class AccessManagementView extends StatefulWidget {
  const AccessManagementView({Key? key}) : super(key: key);

  @override
  State<AccessManagementView> createState() => _AccessManagementViewState();
}

class _AccessManagementViewState extends State<AccessManagementView> {
  final AccessManagementController controller =
      Get.find<AccessManagementController>();
  final TextEditingController _searchController = TextEditingController();

  // Variáveis de Tema (inicializadas no build)
  late ThemeData theme;
  late bool isDark;
  late Color surfaceColor;
  late Color backgroundColor;
  late Color borderColor;

  @override
  Widget build(BuildContext context) {
    theme = Theme.of(context);
    isDark = theme.brightness == Brightness.dark;
    surfaceColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    backgroundColor = isDark
        ? const Color(0xFF121212)
        : const Color(0xFFF4F6F8);
    borderColor = theme.dividerColor.withOpacity(0.1);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // ========================================================
            // 1. HEADER FIXO
            // ========================================================
            _buildHeader(),

            // ========================================================
            // 2. CORPO COM SCROLL (Busca + Tabela + Cards)
            // ========================================================
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- BARRA DE BUSCA ---
                    _buildSearchBar(),

                    const SizedBox(height: 24),

                    // --- LISTA DE USUÁRIOS (Tabela ou Cards Mobile) ---
                    Obx(() {
                      if (controller.isLoading) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(40),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }
                      if (controller.filteredAcessos.isEmpty) {
                        return _buildEmptyState();
                      }

                      // LayoutBuilder decide se mostra Tabela ou Lista Mobile
                      return LayoutBuilder(
                        builder: (context, constraints) {
                          if (constraints.maxWidth > 850) {
                            return _buildDesktopTable(
                              controller.filteredAcessos,
                            );
                          } else {
                            return _buildMobileList(controller.filteredAcessos);
                          }
                        },
                      );
                    }),

                    const SizedBox(height: 40),

                    // ========================================================
                    // SEÇÃO 1: DEFINIÇÕES DE FUNÇÕES
                    // ========================================================
                    Text(
                      'Definições de Funções',
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // --- CARDS INFORMATIVOS FUNÇÕES (GRID RESPONSIVA) ---
                    LayoutBuilder(
                      builder: (context, constraints) {
                        // Se for tela larga, coloca em linha (Row). Se for estreita, empilha (Column).
                        if (constraints.maxWidth > 900) {
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: _buildRoleInfoCard(
                                  'Administrador',
                                  'Gerencia toda a plataforma, cria novos usuários e tem acesso irrestrito aos relatórios financeiros sensíveis.',
                                  Icons.admin_panel_settings_rounded,
                                  Colors.purple,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildRoleInfoCard(
                                  'Secretaria',
                                  'Foca no cadastro e atualização de dados dos dizimistas, além de lançar contribuições do dia a dia.',
                                  Icons.support_agent_rounded,
                                  Colors.blue,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildRoleInfoCard(
                                  'Financeiro',
                                  'Visualiza fluxo de caixa, emite relatórios para contabilidade e analisa a saúde financeira da paróquia.',
                                  Icons.analytics_rounded,
                                  Colors.green,
                                ),
                              ),
                            ],
                          );
                        } else {
                          return Column(
                            children: [
                              _buildRoleInfoCard(
                                'Administrador',
                                'Gerencia toda a plataforma, cria novos usuários e tem acesso irrestrito aos relatórios financeiros sensíveis.',
                                Icons.admin_panel_settings_rounded,
                                Colors.purple,
                              ),
                              const SizedBox(height: 12),
                              _buildRoleInfoCard(
                                'Secretaria',
                                'Foca no cadastro e atualização de dados dos dizimistas, além de lançar contribuições do dia a dia.',
                                Icons.support_agent_rounded,
                                Colors.blue,
                              ),
                              const SizedBox(height: 12),
                              _buildRoleInfoCard(
                                'Financeiro',
                                'Visualiza fluxo de caixa, emite relatórios para contabilidade e analisa a saúde financeira da paróquia.',
                                Icons.analytics_rounded,
                                Colors.green,
                              ),
                            ],
                          );
                        }
                      },
                    ),

                    const SizedBox(height: 40),

                    // ========================================================
                    // SEÇÃO 2: LEGENDA DE STATUS (ATIVO / INATIVO)
                    // ========================================================
                    Text(
                      'Legenda de Status',
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // --- CARDS INFORMATIVOS STATUS (GRID RESPONSIVA) ---
                    LayoutBuilder(
                      builder: (context, constraints) {
                        // Usa um breakpoint menor (700) pois são apenas 2 cards
                        if (constraints.maxWidth > 700) {
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: _buildRoleInfoCard(
                                  'Ativo',
                                  'O usuário possui acesso liberado ao sistema conforme seu perfil. Pode realizar login e registrar operações normalmente.',
                                  Icons.check_circle_outline_rounded,
                                  Colors.green,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildRoleInfoCard(
                                  'Inativo',
                                  'O acesso ao sistema está bloqueado. O usuário não pode fazer login, mas seu histórico de ações é preservado para auditoria.',
                                  Icons.block_rounded,
                                  Colors.grey,
                                ),
                              ),
                            ],
                          );
                        } else {
                          return Column(
                            children: [
                              _buildRoleInfoCard(
                                'Ativo',
                                'O usuário possui acesso liberado ao sistema conforme seu perfil. Pode realizar login e registrar operações normalmente.',
                                Icons.check_circle_outline_rounded,
                                Colors.green,
                              ),
                              const SizedBox(height: 12),
                              _buildRoleInfoCard(
                                'Inativo',
                                'O acesso ao sistema está bloqueado. O usuário não pode fazer login, mas seu histórico de ações é preservado para auditoria.',
                                Icons.block_rounded,
                                Colors.grey,
                              ),
                            ],
                          );
                        }
                      },
                    ),

                    // Espaço extra no final para não colar na borda
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // WIDGETS DE ESTRUTURA
  // ===========================================================================

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      decoration: BoxDecoration(
        color: surfaceColor,
        border: Border(bottom: BorderSide(color: borderColor)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Gestão de Acesso',
                  style: GoogleFonts.outfit(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                Text(
                  'Administre usuários e permissões do sistema',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton.icon(
            onPressed: _openAddUserDialog,
            icon: const Icon(Icons.add_rounded, size: 20),
            label: const Text('Novo Usuário'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Buscar por nome, CPF ou e-mail...',
          hintStyle: GoogleFonts.inter(
            color: theme.colorScheme.onSurface.withOpacity(0.4),
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: theme.colorScheme.onSurface.withOpacity(0.4),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
        onChanged: (value) => controller.setSearchQuery(value),
      ),
    );
  }

  // ===========================================================================
  // WIDGETS DE LISTAGEM (TABELA vs CARDS)
  // ===========================================================================

  Widget _buildDesktopTable(List<Acesso> lista) {
    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header Tabela
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
            child: Row(
              children: [
                _tableHeader('USUÁRIO', flex: 3),
                _tableHeader('CONTATO / CPF', flex: 2),
                _tableHeader('FUNÇÃO', flex: 2),
                _tableHeader('STATUS', flex: 1),
                _tableHeader('AÇÕES', flex: 1, alignRight: true),
              ],
            ),
          ),
          const Divider(height: 1),
          // Linhas
          ListView.separated(
            shrinkWrap: true,
            // Importante para funcionar dentro do SingleChildScrollView
            physics: const NeverScrollableScrollPhysics(),
            // O scroll é controlado pelo pai
            itemCount: lista.length,
            separatorBuilder: (_, __) =>
                const Divider(height: 1, indent: 24, endIndent: 24),
            itemBuilder: (context, index) {
              final acesso = lista[index];
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Row(
                        children: [
                          _buildAvatar(acesso.nome),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  acesso.nome,
                                  style: GoogleFonts.outfit(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                  ),
                                ),
                                Text(
                                  acesso.email,
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: theme.colorScheme.onSurface
                                        .withOpacity(0.5),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            (acesso as dynamic).cpf ?? '---',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: theme.colorScheme.onSurface.withOpacity(
                                0.7,
                              ),
                            ),
                          ),
                          Text(
                            acesso.telefone.isNotEmpty
                                ? acesso.telefone
                                : '---',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: theme.colorScheme.onSurface.withOpacity(
                                0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        acesso.funcao,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: _StatusBadge(status: acesso.status),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          _actionButton(
                            Icons.edit_outlined,
                            Colors.blue,
                            () => _openEditUserDialog(acesso),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMobileList(List<Acesso> lista) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: lista.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final acesso = lista[index];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      _buildAvatar(acesso.nome, size: 40),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            acesso.nome,
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            acesso.funcao,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: theme.colorScheme.onSurface.withOpacity(
                                0.6,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  _StatusBadge(status: acesso.status, compact: true),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),
              // Dados extras para mobile
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _infoBadge(Icons.email_outlined, acesso.email),
                  _infoBadge(
                    Icons.badge_outlined,
                    (acesso as dynamic).cpf ?? 'CPF N/D',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton.icon(
                    onPressed: () => _openEditUserDialog(acesso),
                    icon: const Icon(Icons.edit, size: 16),
                    label: const Text('Editar'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: theme.colorScheme.onSurface,
                      side: BorderSide(color: theme.dividerColor),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // ===========================================================================
  // WIDGET: CARD DE FUNÇÃO / STATUS (GENÉRICO)
  // ===========================================================================

  Widget _buildRoleInfoCard(
    String title,
    String description,
    IconData icon,
    Color color,
  ) {
    return Container(
      // Altura mínima para alinhar visualmente em desktop
      constraints: const BoxConstraints(minHeight: 140),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: GoogleFonts.inter(
              fontSize: 13,
              height: 1.5,
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // HELPERS GERAIS
  // ===========================================================================

  Widget _tableHeader(
    String text, {
    required int flex,
    bool alignRight = false,
  }) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        textAlign: alignRight ? TextAlign.end : TextAlign.start,
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: theme.colorScheme.onSurface.withOpacity(0.4),
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  Widget _buildAvatar(String nome, {double size = 36}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: theme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Text(
          controller.getInitials(nome),
          style: GoogleFonts.outfit(
            fontSize: size * 0.4,
            fontWeight: FontWeight.bold,
            color: theme.primaryColor,
          ),
        ),
      ),
    );
  }

  void _openEditUserDialog(Acesso acesso) {
    String nome = acesso.nome;
    String email = acesso.email;
    String cpf = _formatarCPF(acesso.cpf);
    String telefone = _formatarTelefone(acesso.telefone);
    String endereco = acesso.endereco;
    String funcao = acesso.funcao;
    String status = acesso.status;

    // Formatters para máscaras
    final cpfFormatter = MaskTextInputFormatter(
      mask: '###.###.###-##',
      filter: {"#": RegExp(r'[0-9]')},
      initialText: _formatarCPF(acesso.cpf),
    );
    final telefoneFormatter = MaskTextInputFormatter(
      mask: '(##) #####-####',
      filter: {"#": RegExp(r'[0-9]')},
      initialText: _formatarTelefone(acesso.telefone),
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: surfaceColor,
              surfaceTintColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Text(
                'Editar Usuário',
                style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
              ),
              content: SizedBox(
                width: 500,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label('Dados Pessoais'),
                      _buildTextField(
                        label: 'Nome Completo',
                        onChanged: (v) => nome = v,
                        inputFormatters: [], // Nome não precisa de formatação
                        keyboardType: TextInputType.text,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        label: 'E-mail Corporativo',
                        onChanged: (v) => email = v,
                        inputFormatters: [],
                        // E-mail não precisa de formatação específica
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              label: 'CPF',
                              onChanged: (v) => cpf = v,
                              inputFormatters: [cpfFormatter],
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildTextField(
                              label: 'Celular',
                              onChanged: (v) => telefone = v,
                              inputFormatters: [telefoneFormatter],
                              keyboardType: TextInputType.phone,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        label: 'Endereço',
                        onChanged: (v) => endereco = v,
                        inputFormatters: [],
                        // Endereço não precisa de formatação específica
                        keyboardType: TextInputType.text,
                      ),
                      const SizedBox(height: 24),
                      _label('Permissões'),
                      Row(
                        children: [
                          Expanded(
                            child: _buildDropdown(
                              label: 'Função',
                              value: funcao,
                              items: controller
                                  .getFuncoes()
                                  .map((f) => f.nome)
                                  .toList(),
                              onChanged: (v) => setState(() => funcao = v!),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildDropdown(
                              label: 'Status',
                              value: status,
                              items: ['Ativo', 'Inativo'],
                              onChanged: (v) => setState(() => status = v!),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Cancelar',
                    style: GoogleFonts.inter(color: Colors.red),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (nome.isNotEmpty && email.isNotEmpty) {
                      // Remove a máscara antes de salvar
                      final cpfSemMascara = cpf.replaceAll(
                        RegExp(r'[^\d]'),
                        '',
                      );
                      final telefoneSemMascara = telefone.replaceAll(
                        RegExp(r'[^\d]'),
                        '',
                      );

                      final acessoAtualizado = Acesso(
                        id: acesso.id,
                        nome: nome,
                        email: email,
                        cpf: cpfSemMascara,
                        telefone: telefoneSemMascara,
                        endereco: endereco,
                        funcao: funcao,
                        status: status,
                        ultimoAcesso: acesso.ultimoAcesso,
                        pendencia: acesso.pendencia,
                      );
                      controller.updateAcesso(acessoAtualizado);
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Salvar Alterações'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Função auxiliar para formatar CPF com máscara
  String _formatarCPF(String cpf) {
    // Remove caracteres não numéricos
    String cpfNumerico = cpf.replaceAll(RegExp(r'[^\d]'), '');

    if (cpfNumerico.length != 11)
      return cpf; // Retorna o valor original se não tiver 11 dígitos
    return "${cpfNumerico.substring(0, 3)}.${cpfNumerico.substring(3, 6)}.${cpfNumerico.substring(6, 9)}-${cpfNumerico.substring(9, 11)}";
  }

  // Função auxiliar para formatar telefone com máscara
  String _formatarTelefone(String telefone) {
    // Remove caracteres não numéricos
    String telefoneNumerico = telefone.replaceAll(RegExp(r'[^\d]'), '');

    if (telefoneNumerico.length < 10)
      return telefone; // Retorna o valor original se não tiver dígitos suficientes

    if (telefoneNumerico.length == 10) {
      // Telefone fixo (8 dígitos + 2 dígitos DDD)
      return "(${telefoneNumerico.substring(0, 2)}) ${telefoneNumerico.substring(2, 6)}-${telefoneNumerico.substring(6, 10)}";
    } else {
      // Celular (9 dígitos + 2 dígitos DDD)
      return "(${telefoneNumerico.substring(0, 2)}) ${telefoneNumerico.substring(2, 7)}-${telefoneNumerico.substring(7, 11)}";
    }
  }

  Widget _actionButton(IconData icon, Color color, [VoidCallback? onTap]) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 16, color: color),
      ),
    );
  }

  Widget _infoBadge(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 11,
              color: theme.colorScheme.onSurface.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 64, color: theme.dividerColor),
          const SizedBox(height: 16),
          Text(
            'Nenhum usuário encontrado',
            style: GoogleFonts.outfit(
              fontSize: 18,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // DIALOGO CADASTRO
  // ===========================================================================

  void _openAddUserDialog() {
    String nome = '';
    String email = '';
    String cpf = '';
    String telefone = '';
    String endereco = '';
    String funcao = 'Administrador';
    String status = 'Ativo';

    // Formatters para máscaras
    final cpfFormatter = MaskTextInputFormatter(
      mask: '###.###.###-##',
      filter: {"#": RegExp(r'[0-9]')},
    );
    final telefoneFormatter = MaskTextInputFormatter(
      mask: '(##) #####-####',
      filter: {"#": RegExp(r'[0-9]')},
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: surfaceColor,
              surfaceTintColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Text(
                'Novo Usuário',
                style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
              ),
              content: SizedBox(
                width: 500,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label('Dados Pessoais'),
                      _buildTextField(
                        label: 'Nome Completo',
                        onChanged: (v) => nome = v,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        label: 'E-mail Corporativo',
                        onChanged: (v) => email = v,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              label: 'CPF',
                              onChanged: (v) => cpf = v,
                              inputFormatters: [cpfFormatter],
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildTextField(
                              label: 'Celular',
                              onChanged: (v) => telefone = v,
                              inputFormatters: [telefoneFormatter],
                              keyboardType: TextInputType.phone,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        label: 'Endereço',
                        onChanged: (v) => endereco = v,
                      ),
                      const SizedBox(height: 24),
                      _label('Permissões'),
                      Row(
                        children: [
                          Expanded(
                            child: _buildDropdown(
                              label: 'Função',
                              value: funcao,
                              items: controller
                                  .getFuncoes()
                                  .map((f) => f.nome)
                                  .toList(),
                              onChanged: (v) => setState(() => funcao = v!),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildDropdown(
                              label: 'Status',
                              value: status,
                              items: ['Ativo', 'Inativo'],
                              onChanged: (v) => setState(() => status = v!),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Cancelar',
                    style: GoogleFonts.inter(color: Colors.red),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (nome.isNotEmpty && email.isNotEmpty) {
                      // Remove a máscara antes de salvar
                      final cpfSemMascara = cpf.replaceAll(
                        RegExp(r'[^\d]'),
                        '',
                      );
                      final telefoneSemMascara = telefone.replaceAll(
                        RegExp(r'[^\d]'),
                        '',
                      );

                      final novoAcesso = Acesso(
                        id: (controller.acessos.length + 1).toString(),
                        nome: nome,
                        email: email,
                        cpf: cpfSemMascara,
                        telefone: telefoneSemMascara,
                        endereco: endereco,
                        funcao: funcao,
                        status: status,
                        ultimoAcesso: DateTime.now(),
                        pendencia: false,
                      );
                      controller.addAcesso(novoAcesso);
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Criar Acesso'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: theme.primaryColor,
      ),
    ),
  );

  Widget _buildTextField({
    required String label,
    required Function(String) onChanged,
    List<TextInputFormatter>? inputFormatters,
    TextInputType? keyboardType,
  }) => TextField(
    decoration: InputDecoration(
      labelText: label,
      filled: true,
      fillColor: backgroundColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    style: GoogleFonts.inter(fontSize: 14),
    onChanged: onChanged,
    inputFormatters: inputFormatters,
    keyboardType: keyboardType,
  );

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
  }) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 11,
          color: theme.colorScheme.onSurface.withOpacity(0.6),
        ),
      ),
      const SizedBox(height: 6),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            isExpanded: true,
            value: value,
            items: items
                .map(
                  (s) => DropdownMenuItem(
                    value: s,
                    child: Text(s, style: GoogleFonts.inter(fontSize: 14)),
                  ),
                )
                .toList(),
            onChanged: onChanged,
          ),
        ),
      ),
    ],
  );
}

class _StatusBadge extends StatelessWidget {
  final String status;
  final bool compact;

  const _StatusBadge({required this.status, this.compact = false});

  @override
  Widget build(BuildContext context) {
    Color color = status == 'Ativo'
        ? Colors.green
        : (status == 'Inativo' ? Colors.grey : Colors.blue);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 12,
        vertical: compact ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Text(
        status.toUpperCase(),
        style: GoogleFonts.inter(
          color: color,
          fontSize: compact ? 10 : 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

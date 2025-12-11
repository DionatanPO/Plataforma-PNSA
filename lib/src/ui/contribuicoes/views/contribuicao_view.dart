import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import '../controllers/contribuicao_controller.dart';
import '../../dizimistas/models/dizimista_model.dart';
import '../models/contribuicao_model.dart';

class ContribuicaoView extends StatefulWidget {
  const ContribuicaoView({Key? key}) : super(key: key);

  @override
  State<ContribuicaoView> createState() => _ContribuicaoViewState();
}

class _ContribuicaoViewState extends State<ContribuicaoView> {
  final ContribuicaoController controller = Get.find<ContribuicaoController>();
  final TextEditingController _valorController = TextEditingController();

  // Cores e Estilos Locais
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
    backgroundColor = isDark ? const Color(0xFF121212) : const Color(0xFFF4F6F8);
    borderColor = theme.dividerColor.withOpacity(0.1);

    return Scaffold(
      backgroundColor: backgroundColor,
      // Header Minimalista
      appBar: AppBar(
        backgroundColor: backgroundColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 80,
        titleSpacing: 24,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Financeiro',
              style: GoogleFonts.outfit(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            Text(
              'Registro de entradas e dízimos',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
      body: Scrollbar(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
          child: Column(
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth > 900) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 4, child: _buildFormCard()),
                        const SizedBox(width: 24),
                        Expanded(flex: 6, child: _buildHistoryCard()),
                      ],
                    );
                  } else {
                    return Column(
                      children: [
                        _buildFormCard(),
                        const SizedBox(height: 24),
                        _buildHistoryCard(),
                      ],
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // WIDGET: CARTÃO DE FORMULÁRIO (NOVA ENTRADA)
  // ===========================================================================
  Widget _buildFormCard() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: theme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.add_card_rounded, color: theme.primaryColor, size: 24),
              ),
              const SizedBox(width: 16),
              Text(
                'Nova Entrada',
                style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // 1. Dizimista (Dropdown)
          _label('Contribuinte'),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor),
            ),
            child: Obx(() {
              return DropdownButtonHideUnderline(
                child: DropdownButton<Dizimista>(
                  isExpanded: true,
                  dropdownColor: isDark ? const Color(0xFF2C2C2C) : Colors.white,
                  hint: Text(
                    'Selecione o fiel...',
                    style: GoogleFonts.inter(color: theme.colorScheme.onSurface.withOpacity(0.4)),
                  ),
                  value: controller.dizimistaSelecionado.value,
                  icon: Icon(Icons.keyboard_arrow_down_rounded, color: theme.colorScheme.onSurface),
                  style: GoogleFonts.inter(color: theme.colorScheme.onSurface, fontSize: 14),
                  items: controller.dizimistas.map((dizimista) {
                    return DropdownMenuItem(
                      value: dizimista,
                      child: Text(
                        dizimista.nome,
                        style: GoogleFonts.inter(color: theme.colorScheme.onSurface),
                      ),
                    );
                  }).toList(),
                  onChanged: (val) => controller.dizimistaSelecionado.value = val,
                ),
              );
            }),
          ),

          const SizedBox(height: 20),

          // 2. Linha Dupla: Referência e Tipo
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _label('Referência'),
                    _buildModernDropdown(
                      value: controller.mesReferencia,
                      items: ['12/2025', '11/2025', '10/2025'],
                      onChanged: (val) => setState(() => controller.mesReferencia = val!),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _label('Tipo'),
                    _buildModernDropdown(
                      value: controller.tipo,
                      items: ['Dízimo Regular', 'Dízimo Atrasado', 'Oferta', 'Doação'],
                      onChanged: (val) => setState(() => controller.tipo = val!),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),

          // 3. Valor (Destaque)
          Text(
            'VALOR DA CONTRIBUIÇÃO',
            style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface.withOpacity(0.4),
                letterSpacing: 1
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: theme.primaryColor.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Text(
                  'R\$',
                  style: GoogleFonts.outfit(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface.withOpacity(0.5)
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _valorController,
                    keyboardType: TextInputType.number,
                    // =================================================
                    // CORREÇÃO: Usar onSurface para garantir branco no escuro
                    // =================================================
                    style: GoogleFonts.outfit(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface
                    ),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: '0,00',
                      // Hint com cor ajustada para contraste
                      hintStyle: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.2)),
                    ),
                    onChanged: (val) => controller.valor = val,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // 4. Métodos de Pagamento (Chips)
          _label('Forma de Pagamento'),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _paymentChip('PIX', Icons.qr_code_rounded),
              _paymentChip('Dinheiro', Icons.attach_money_rounded),
              _paymentChip('Cartão', Icons.credit_card_rounded),
              _paymentChip('Transferência', Icons.description_outlined),
            ],
          ),

          const SizedBox(height: 40),

          // 5. Botão Confirmar
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _submitForm,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: Text(
                'Confirmar Lançamento',
                style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // WIDGET: CARTÃO DE HISTÓRICO
  // ===========================================================================
  Widget _buildHistoryCard() {
    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          // Header do Card
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Últimos Lançamentos',
                      style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface
                      ),
                    ),
                    Text(
                      'Histórico recente de hoje',
                      style: GoogleFonts.inter(fontSize: 13, color: theme.colorScheme.onSurface.withOpacity(0.5)),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.more_horiz_rounded, color: theme.colorScheme.onSurface),
                  tooltip: 'Ver todos',
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Lista
          Obx(() {
            if (controller.isLoading) return const Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator());

            final lista = controller.getUltimosLancamentos();
            if (lista.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(40),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.receipt_long_rounded, size: 48, color: theme.dividerColor),
                      const SizedBox(height: 16),
                      Text('Sem registros hoje', style: GoogleFonts.inter(color: theme.colorScheme.onSurface.withOpacity(0.5))),
                    ],
                  ),
                ),
              );
            }

            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: lista.length,
              separatorBuilder: (_, __) => const Divider(height: 1, indent: 24, endIndent: 24),
              itemBuilder: (context, index) {
                final item = lista[index];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: _getMetodoColor(item.metodo).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                        _getMetodoIcon(item.metodo),
                        color: _getMetodoColor(item.metodo),
                        size: 20
                    ),
                  ),
                  title: Text(
                    item.dizimistaNome,
                    style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 15, color: theme.colorScheme.onSurface),
                  ),
                  subtitle: Text(
                    '${item.tipo} • Ref: ${item.mesReferencia}',
                    style: GoogleFonts.inter(fontSize: 12, color: theme.colorScheme.onSurface.withOpacity(0.6)),
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '+ ${controller.formatarMoeda(item.valor)}',
                        style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.green),
                      ),
                      Text(
                        item.metodo,
                        style: GoogleFonts.inter(fontSize: 11, color: theme.colorScheme.onSurface.withOpacity(0.4)),
                      ),
                    ],
                  ),
                );
              },
            );
          }),
        ],
      ),
    );
  }

  // ===========================================================================
  // HELPERS E COMPONENTES
  // ===========================================================================

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        text,
        style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface.withOpacity(0.7)),
      ),
    );
  }

  Widget _buildModernDropdown({required String value, required List<String> items, required Function(String?) onChanged}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          dropdownColor: isDark ? const Color(0xFF2C2C2C) : Colors.white,
          value: value,
          icon: Icon(Icons.keyboard_arrow_down_rounded, size: 20, color: theme.colorScheme.onSurface.withOpacity(0.6)),
          items: items.map((String val) {
            return DropdownMenuItem(
                value: val,
                child: Text(
                    val,
                    style: GoogleFonts.inter(fontSize: 14, color: theme.colorScheme.onSurface)
                )
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _paymentChip(String label, IconData icon) {
    final isSelected = controller.metodo == label;
    // Cor do texto quando NÃO selecionado ajustada para dark mode
    final unselectedColor = theme.colorScheme.onSurface.withOpacity(0.7);

    return InkWell(
      onTap: () => setState(() => controller.metodo = label),
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? theme.primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? theme.primaryColor : borderColor,
            width: isSelected ? 0 : 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: isSelected ? Colors.white : unselectedColor),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? Colors.white : unselectedColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submitForm() {
    if (controller.dizimistaSelecionado.value != null && _valorController.text.isNotEmpty) {
      final novaContribuicao = Contribuicao(
        id: controller.contribuicoes.length + 1,
        dizimistaId: controller.dizimistaSelecionado.value!.id,
        dizimistaNome: controller.dizimistaSelecionado.value!.nome,
        mesReferencia: controller.mesReferencia,
        tipo: controller.tipo,
        valor: double.tryParse(_valorController.text.replaceAll(',', '.')) ?? 0.0,
        metodo: controller.metodo,
        dataRegistro: DateTime.now(),
      );

      controller.addContribuicao(novaContribuicao);
      _valorController.clear();
      controller.dizimistaSelecionado.value = null;

      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lançamento registrado!', style: GoogleFonts.inter()),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          )
      );
    } else {
      Get.snackbar(
        'Atenção',
        'Preencha o contribuinte e o valor.',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(24),
        colorText: theme.colorScheme.onSurface,
      );
    }
  }

  IconData _getMetodoIcon(String metodo) {
    if (metodo.contains('PIX')) return Icons.qr_code;
    if (metodo.contains('Dinheiro')) return Icons.attach_money;
    if (metodo.contains('Cartão')) return Icons.credit_card;
    return Icons.receipt;
  }

  Color _getMetodoColor(String metodo) {
    if (metodo.contains('PIX')) return Colors.teal;
    if (metodo.contains('Dinheiro')) return Colors.green;
    if (metodo.contains('Cartão')) return Colors.purple;
    return Colors.blue;
  }
}
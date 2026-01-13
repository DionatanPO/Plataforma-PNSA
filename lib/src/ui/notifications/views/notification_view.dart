import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../controllers/notification_controller.dart';
import '../../contribuicoes/models/contribuicao_model.dart';
import '../../contribuicoes/controllers/contribuicao_controller.dart';
import '../../core/widgets/modern_header.dart';

class NotificationView extends GetView<NotificationController> {
  const NotificationView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final backgroundColor =
        isDark ? const Color(0xFF0D0D0D) : const Color(0xFFF8F9FA);
    final surfaceColor = isDark ? const Color(0xFF1A1A1A) : Colors.white;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: CustomScrollView(
        slivers: [
          const ModernHeader(
            title: 'Notificações',
            subtitle: 'Dízimos a receber e próximos do vencimento',
            icon: Icons.notifications_active_rounded,
          ),
          SliverPadding(
            padding: const EdgeInsets.all(24),
            sliver: Obx(() {
              if (controller.notifications.isEmpty) {
                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.notifications_none_rounded,
                          size: 64,
                          color: theme.colorScheme.onSurface.withOpacity(0.1),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Nenhuma notificação pendente',
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface.withOpacity(0.4),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final item = controller.notifications[index];
                    return _NotificationCard(
                      contribuicao: item,
                      theme: theme,
                      surfaceColor: surfaceColor,
                    );
                  },
                  childCount: controller.notifications.length,
                ),
              );
            }),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final Contribuicao contribuicao;
  final ThemeData theme;
  final Color surfaceColor;

  const _NotificationCard({
    Key? key,
    required this.contribuicao,
    required this.theme,
    required this.surfaceColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final pDate = DateTime(
      contribuicao.dataPagamento.year,
      contribuicao.dataPagamento.month,
      contribuicao.dataPagamento.day,
    );
    final diff = pDate.difference(today).inDays;

    final bool isOverdue = diff < 0;
    final bool isToday = diff == 0;

    Color statusColor = Colors.blue;
    String statusText = 'Vence em $diff dias';
    IconData statusIcon = Icons.timer_outlined;

    if (isOverdue) {
      statusColor = Colors.red;
      statusText = 'Atrasado há ${diff.abs()} dias';
      statusIcon = Icons.warning_amber_rounded;
    } else if (isToday) {
      statusColor = Colors.red;
      statusText = 'Vence hoje';
      statusIcon = Icons.notification_important_rounded;
    } else if (diff == 1) {
      statusColor = Colors.orange;
      statusText = 'Vence amanhã';
      statusIcon = Icons.timer_outlined;
    }

    final currency = NumberFormat.simpleCurrency(locale: 'pt_BR');

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: statusColor.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: Get.find<NotificationController>().canInteract
              ? () => _showPaymentDialog(context)
              : null,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: _PulseWidget(
                    isActive: diff < 0,
                    child: Icon(statusIcon, color: statusColor, size: 24),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        contribuicao.dizimistaNome,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        contribuicao.mesesCompetencia.join(", "),
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              statusText,
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: statusColor,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Vencimento: ${DateFormat('dd/MM/yyyy').format(contribuicao.dataPagamento)}',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color:
                                  theme.colorScheme.onSurface.withOpacity(0.4),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '•',
                            style: TextStyle(
                                color: theme.colorScheme.onSurface
                                    .withOpacity(0.2)),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            contribuicao.metodo,
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.primary.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      currency.format(contribuicao.valor),
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showPaymentDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.check_circle_outline_rounded,
                color: theme.colorScheme.primary),
            const SizedBox(width: 12),
            Text('Confirmar Recebimento',
                style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Deseja marcar esta contribuição de dízimo como PAGA?',
              style: GoogleFonts.inter(color: theme.colorScheme.onSurface),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: theme.colorScheme.primary.withOpacity(0.1)),
              ),
              child: Column(
                children: [
                  _infoRow('Dizimista:', contribuicao.dizimistaNome),
                  const SizedBox(height: 4),
                  _infoRow(
                      'Valor:',
                      NumberFormat.simpleCurrency(locale: 'pt_BR')
                          .format(contribuicao.valor)),
                  const SizedBox(height: 4),
                  _infoRow('Ref:', contribuicao.mesesCompetencia.join(", ")),
                ],
              ),
            ),
          ],
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton.icon(
                onPressed: () => _confirmDeletion(context),
                icon: const Icon(Icons.delete_outline_rounded,
                    color: Colors.red, size: 20),
                label: Text('Apagar',
                    style: GoogleFonts.inter(
                        color: Colors.red, fontWeight: FontWeight.w500)),
              ),
              Row(
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: Text('Cancelar',
                        style: GoogleFonts.inter(
                            color:
                                theme.colorScheme.onSurface.withOpacity(0.5))),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () async {
                      Get.back();
                      final cController = Get.find<ContribuicaoController>();
                      await cController.toggleStatus(contribuicao);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text('Confirmar Pago',
                        style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _confirmDeletion(BuildContext context) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Apagar Lançamento?',
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        content: Text(
          'Esta ação não pode ser desfeita. Deseja realmente excluir este lançamento de dízimo?',
          style: GoogleFonts.inter(),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancelar', style: GoogleFonts.inter()),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back(); // Fecha o diálogo de confirmação de exclusão
              Get.back(); // Fecha o diálogo principal de recebimento
              final cController = Get.find<ContribuicaoController>();
              await cController.deleteContribuicao(contribuicao.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: Text('Confirmar Exclusão',
                style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: GoogleFonts.inter(
                fontSize: 12,
                color: theme.colorScheme.onSurface.withOpacity(0.6))),
        Text(value,
            style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface)),
      ],
    );
  }
}

class _PulseWidget extends StatefulWidget {
  final Widget child;
  final bool isActive;

  const _PulseWidget({Key? key, required this.child, this.isActive = false})
      : super(key: key);

  @override
  State<_PulseWidget> createState() => _PulseWidgetState();
}

class _PulseWidgetState extends State<_PulseWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration:
          const Duration(milliseconds: 600), // Mais rápido para ser notado
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.25).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.4).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    if (widget.isActive) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(_PulseWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!widget.isActive && _controller.isAnimating) {
      _controller.stop();
      _controller.reset();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isActive) return widget.child;

    return ScaleTransition(
      scale: _scaleAnimation,
      child: FadeTransition(
        opacity: _opacityAnimation,
        child: widget.child,
      ),
    );
  }
}

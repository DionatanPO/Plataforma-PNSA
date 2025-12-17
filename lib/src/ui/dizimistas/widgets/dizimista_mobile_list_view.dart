import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/dizimista_model.dart';
import 'dizimista_avatar.dart';
import 'status_badge.dart';

class DizimistaMobileListView extends StatelessWidget {
  final List<Dizimista> lista;
  final ThemeData theme;
  final Color surfaceColor;
  final Function(Dizimista) onEditPressed;
  final Function(Dizimista) onViewHistoryPressed;

  const DizimistaMobileListView({
    Key? key,
    required this.lista,
    required this.theme,
    required this.surfaceColor,
    required this.onEditPressed,
    required this.onViewHistoryPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: lista.length,
      itemBuilder: (context, index) {
        final d = lista[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
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
          ),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DizimistaAvatar(nome: d.nome, theme: theme, size: 48),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                d.nome,
                                style: GoogleFonts.outfit(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            StatusBadge(status: d.status, compact: true),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // NOVA LINHA: Nº Registro e CPF
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: theme.dividerColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'Nº Reg: ${d.numeroRegistro}',
                                style: GoogleFonts.inter(
                                  fontSize:
                                      12, // Leve aumento para legibilidade
                                  fontWeight: FontWeight.w600, // Destaque sutil
                                  color: theme.colorScheme.onSurface
                                      .withOpacity(0.9),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // CPF
                            Expanded(
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.badge_outlined,
                                    size: 14,
                                    color: theme.colorScheme.onSurface
                                        .withOpacity(0.5),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    d.cpf.isNotEmpty
                                        ? d.cpf
                                        : 'CPF não informado',
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color: theme.colorScheme.onSurface
                                          .withOpacity(0.7),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow
                                        .ellipsis, // Previne quebra de linha visualmente feia
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // TELEFONE
                        Row(
                          children: [
                            Icon(
                              Icons
                                  .phone_rounded, // Ícone arredondado mais moderno
                              size: 14,
                              color: theme.colorScheme.onSurface.withOpacity(
                                0.5,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              d.telefone,
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: theme.colorScheme.onSurface.withOpacity(
                                  0.8,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 12),
              // Botões de Ação Mobile (Largura total)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => onEditPressed(d),
                      icon: const Icon(Icons.edit, size: 16),
                      label: const Text('Editar'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: theme.colorScheme.onSurface,
                        side: BorderSide(color: theme.dividerColor),
                      ),
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
}

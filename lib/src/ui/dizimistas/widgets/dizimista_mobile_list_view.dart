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
      padding: const EdgeInsets.all(16),
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
              BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
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
                                style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16),
                                maxLines: 1, overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            StatusBadge(status: d.status, compact: true),
                          ],
                        ),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: theme.dividerColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'Nº Reg: ${d.numeroRegistro}',
                                style: GoogleFonts.inter(fontSize: 11, color: theme.colorScheme.onSurface.withOpacity(0.8)),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'ID: ${d.id.toString().padLeft(4, '0')}',
                              style: GoogleFonts.inter(fontSize: 11, color: theme.colorScheme.onSurface.withOpacity(0.4)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.phone, size: 14, color: theme.colorScheme.onSurface.withOpacity(0.5)),
                            const SizedBox(width: 6),
                            Text(d.telefone, style: GoogleFonts.inter(fontSize: 13, color: theme.colorScheme.onSurface.withOpacity(0.7))),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.location_on_outlined, size: 14, color: theme.colorScheme.onSurface.withOpacity(0.5)),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                d.endereco,
                                style: GoogleFonts.inter(fontSize: 13, color: theme.colorScheme.onSurface.withOpacity(0.7)),
                                maxLines: 1, overflow: TextOverflow.ellipsis,
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
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => onViewHistoryPressed(d),
                      icon: const Icon(Icons.history, size: 16),
                      label: const Text('Histórico'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: theme.colorScheme.onSurface,
                        side: BorderSide(color: theme.dividerColor),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }
}
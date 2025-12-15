import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/dizimista_model.dart';
import 'dizimista_avatar.dart';
import 'status_badge.dart';
import 'table_header_cell.dart';
import 'action_button.dart';

class DizimistaDesktopTableView extends StatelessWidget {
  final List<Dizimista> lista;
  final ThemeData theme;
  final Color surfaceColor;
  final Function(Dizimista) onEditPressed;

  const DizimistaDesktopTableView({
    Key? key,
    required this.lista,
    required this.theme,
    required this.surfaceColor,
    required this.onEditPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
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
          // Cabeçalho da tabela
          Container(
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                TableHeaderCell(text: 'Nº REGISTRO', flex: 1, theme: theme),
                TableHeaderCell(text: 'FIÉL', flex: 3, theme: theme),
                TableHeaderCell(text: 'CONTATO', flex: 2, theme: theme),
                TableHeaderCell(text: 'LOCALIZAÇÃO', flex: 2, theme: theme),
                TableHeaderCell(text: 'STATUS', flex: 1, theme: theme),
                TableHeaderCell(text: 'CADASTRO', flex: 1, theme: theme),
                TableHeaderCell(text: '', flex: 1, theme: theme), // Ações
              ],
            ),
          ),
          const Divider(height: 1),
          // Linhas
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: lista.length,
            separatorBuilder: (_, __) => const Divider(height: 1, indent: 24, endIndent: 24),
            itemBuilder: (context, index) {
              final d = lista[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: Row(
                  children: [
                    // Coluna 1: Número de Registro
                    Expanded(
                      flex: 1,
                      child: Text(
                        d.numeroRegistro,
                        style: GoogleFonts.inter(fontSize: 13, color: theme.colorScheme.onSurface),
                      ),
                    ),
                    // Coluna 2: Avatar + Nome + Info
                    Expanded(
                      flex: 3,
                      child: Row(
                        children: [
                          DizimistaAvatar(nome: d.nome, theme: theme),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  d.nome,
                                  style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 15),
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    Icon(Icons.phone_outlined, size: 12, color: theme.colorScheme.onSurface.withOpacity(0.5)),
                                    const SizedBox(width: 4),
                                    Text(
                                      d.telefone,
                                      style: GoogleFonts.inter(fontSize: 12, color: theme.colorScheme.onSurface.withOpacity(0.6)),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Coluna 3: Contato
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(d.telefone, style: GoogleFonts.inter(fontSize: 13)),
                          Text(d.email ?? '', style: GoogleFonts.inter(fontSize: 11, color: theme.colorScheme.onSurface.withOpacity(0.5))),
                        ],
                      ),
                    ),
                    // Coluna 4: Endereço
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${d.rua ?? ''}${d.numero != null && d.numero!.isNotEmpty ? ", ${d.numero}" : ""}', style: GoogleFonts.inter(fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                          Text('${d.cidade} - ${d.estado}', style: GoogleFonts.inter(fontSize: 11, color: theme.colorScheme.onSurface.withOpacity(0.5))),
                        ],
                      ),
                    ),
                    // Coluna 5: Status
                    Expanded(flex: 1, child: Align(alignment: Alignment.centerLeft, child: StatusBadge(status: d.status))),
                    // Coluna 6: Data
                    Expanded(
                      flex: 1,
                      child: Text(
                        '${d.dataRegistro.day}/${d.dataRegistro.month}/${d.dataRegistro.year}',
                        style: GoogleFonts.inter(fontSize: 13, color: theme.colorScheme.onSurface.withOpacity(0.6)),
                      ),
                    ),
                    // Coluna 7: Ações
                    Expanded(
                      flex: 1,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ActionButton(
                            icon: Icons.edit_outlined,
                            color: Colors.blue,
                            onTap: () => onEditPressed(d),
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
}
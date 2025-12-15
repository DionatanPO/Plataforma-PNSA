import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/dizimista_model.dart';
import 'dizimista_avatar.dart';
import 'status_badge.dart';

class DizimistaInfoCard extends StatelessWidget {
  final Dizimista dizimista;
  final ThemeData theme;
  final Color surfaceColor;

  const DizimistaInfoCard({
    Key? key,
    required this.dizimista,
    required this.theme,
    required this.surfaceColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              DizimistaAvatar(nome: dizimista.nome, theme: theme),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dizimista.nome,
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: theme.dividerColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Nº Reg: ${dizimista.numeroRegistro}',
                            style: GoogleFonts.inter(fontSize: 11, color: theme.colorScheme.onSurface.withOpacity(0.8)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              StatusBadge(status: dizimista.status, compact: true),
            ],
          ),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.person, dizimista.cpf, 'CPF'),
          if (dizimista.telefone.isNotEmpty)
            _buildInfoRow(Icons.phone, dizimista.telefone, 'Telefone'),
          if (dizimista.email != null && dizimista.email!.isNotEmpty)
            _buildInfoRow(Icons.email, dizimista.email!, 'E-mail'),
          if (dizimista.endereco.isNotEmpty)
            _buildInfoRow(Icons.location_on, dizimista.endereco, 'Endereço'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String value, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 14, color: theme.colorScheme.onSurface.withOpacity(0.6)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  final bool compact;

  const StatusBadge({Key? key, required this.status, this.compact = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status.toLowerCase()) {
      case 'ativo':
        color = const Color(0xFF22C55E); // Green 500
        break;
      case 'afastado':
        color = const Color(0xFFF59E0B); // Amber 500
        break;
      case 'inativo':
        color = const Color(0xFF6B7280); // Gray 500
        break;
      default:
        color = const Color(0xFF64748B); // Slate 500
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: compact ? 8 : 12, vertical: compact ? 4 : 6),
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
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
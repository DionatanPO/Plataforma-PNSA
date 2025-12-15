import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  final bool compact;

  const StatusBadge({Key? key, required this.status, this.compact = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color color = status == 'Ativo'
        ? Colors.green
        : (status == 'Inativo' ? Colors.grey : Colors.blue);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: compact ? 8 : 12, vertical: compact ? 4 : 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Text(
        status.toUpperCase(),
        style: GoogleFonts.inter(color: color, fontSize: compact ? 10 : 11, fontWeight: FontWeight.bold),
      ),
    );
  }
}
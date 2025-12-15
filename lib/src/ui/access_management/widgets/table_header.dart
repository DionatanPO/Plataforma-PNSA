import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TableHeader extends StatelessWidget {
  final String text;
  final int flex;
  final bool alignRight;

  const TableHeader({
    Key? key,
    required this.text,
    required this.flex,
    this.alignRight = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
}
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TableHeaderCell extends StatelessWidget {
  final String text;
  final int flex;
  final ThemeData theme;
  final bool alignRight;

  const TableHeaderCell({
    Key? key,
    required this.text,
    required this.flex,
    required this.theme,
    this.alignRight = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        child: Text(
          text,
          textAlign: alignRight ? TextAlign.right : TextAlign.left,
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.onSurface.withOpacity(0.4),
            letterSpacing: 1.0,
          ),
        ),
      ),
    );
  }
}
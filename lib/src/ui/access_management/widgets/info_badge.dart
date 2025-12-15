import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class InfoBadge extends StatelessWidget {
  final IconData icon;
  final String text;
  final ThemeData? theme;

  const InfoBadge(this.icon, this.text, {Key? key, this.theme}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final finalTheme = theme ?? Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: finalTheme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: finalTheme.colorScheme.onSurface.withOpacity(0.6)),
          const SizedBox(width: 6),
          Text(text, style: GoogleFonts.inter(fontSize: 11, color: finalTheme.colorScheme.onSurface.withOpacity(0.8))),
        ],
      ),
    );
  }
}
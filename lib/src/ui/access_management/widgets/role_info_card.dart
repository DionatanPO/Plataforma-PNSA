
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RoleInfoCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final ThemeData? theme;

  const RoleInfoCard({
    Key? key,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    this.theme,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final finalTheme = theme ?? Theme.of(context);
    final isDark = finalTheme.brightness == Brightness.dark;
    final surfaceColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final borderColor = finalTheme.dividerColor.withOpacity(0.1);

    return Container(
      constraints: const BoxConstraints(minHeight: 140),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: finalTheme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: GoogleFonts.inter(
              fontSize: 13,
              height: 1.5,
              color: finalTheme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }
}
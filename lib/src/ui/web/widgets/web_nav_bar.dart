import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:plataforma_pnsa/src/routes/app_routes.dart';
import 'package:plataforma_pnsa/src/ui/core/theme/app_theme.dart';
import 'package:plataforma_pnsa/src/core/constants/app_constants.dart';

class WebNavBar extends StatelessWidget implements PreferredSizeWidget {
  final String activeRoute;

  const WebNavBar({super.key, required this.activeRoute});

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = AppTheme.primaryColor;
    final Color accentColor = AppTheme.accentColor;
    final isMobile = MediaQuery.of(context).size.width < 900;

    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Row(
                    children: [
                      Image.asset('assets/images/logo.jpg', height: 50),
                      const SizedBox(width: 12),
                      Flexible(
                        child: Text(
                          AppConstants.parishName,
                          overflow: TextOverflow.ellipsis,
                          softWrap: false,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                            fontFamily: 'Serif',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (isMobile)
                  IconButton(
                    icon: Icon(Icons.menu, color: primaryColor),
                    onPressed: () => Scaffold.of(context).openEndDrawer(),
                  )
                else
                  Row(
                    children: [
                      DesktopMenuLink(
                        text: "Início",
                        primaryColor: primaryColor,
                        isActive: activeRoute == AppRoutes.web_home,
                        onTap: () => Get.offAllNamed(AppRoutes.web_home),
                      ),
                      DesktopMenuLink(
                        text: "A Paróquia",
                        primaryColor: primaryColor,
                        isActive: activeRoute == AppRoutes.PARISH,
                        onTap: () => Get.toNamed(AppRoutes.PARISH),
                      ),
                      DesktopMenuLink(
                          text: "Horários", primaryColor: primaryColor),
                      DesktopMenuLink(
                          text: "Eventos",
                          primaryColor: primaryColor,
                          isActive: activeRoute == AppRoutes.EVENTS,
                          onTap: () => Get.toNamed(AppRoutes.EVENTS)),
                      DesktopMenuLink(
                          text: "Dízimo",
                          primaryColor: primaryColor,
                          isActive: activeRoute == AppRoutes.TITHE,
                          onTap: () => Get.toNamed(AppRoutes.TITHE)),
                      DesktopMenuLink(
                          text: "Galeria", primaryColor: primaryColor),
                      DesktopMenuLink(
                        text: "Contato",
                        primaryColor: primaryColor,
                        isActive: activeRoute == AppRoutes.CONTACT,
                        onTap: () => Get.toNamed(AppRoutes.CONTACT),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () => Get.toNamed(AppRoutes.login),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accentColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 18),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                          elevation: 0,
                        ),
                        child: const Text("Login"),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(80);
}

class DesktopMenuLink extends StatefulWidget {
  final String text;
  final bool isActive;
  final Color primaryColor;
  final VoidCallback? onTap;

  const DesktopMenuLink({
    super.key,
    required this.text,
    this.isActive = false,
    required this.primaryColor,
    this.onTap,
  });

  @override
  State<DesktopMenuLink> createState() => _DesktopMenuLinkState();
}

class _DesktopMenuLinkState extends State<DesktopMenuLink> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Text(
            widget.text,
            style: TextStyle(
              fontSize: 14,
              fontWeight: widget.isActive ? FontWeight.bold : FontWeight.w500,
              color: _isHovering || widget.isActive
                  ? widget.primaryColor
                  : Colors.grey[700],
            ),
          ),
        ),
      ),
    );
  }
}

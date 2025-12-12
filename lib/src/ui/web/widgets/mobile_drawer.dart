import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:plataforma_pnsa/src/routes/app_routes.dart';
import 'package:plataforma_pnsa/src/ui/core/theme/app_theme.dart';

class WebMobileDrawer extends StatelessWidget {
  const WebMobileDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = AppTheme.primaryColor;

    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: primaryColor),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/images/logo.jpg', height: 60),
                  const SizedBox(height: 12),
                  const Text(
                    "Paróquia Nossa Senhora Auxiliadora",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          _mobileListTile("Início", Icons.home, onTap: () {
            Navigator.pop(context);
            Get.offAllNamed(AppRoutes.web_home);
          }),
          _mobileListTile("A Paróquia", Icons.church, onTap: () {
            Navigator.pop(context);
            Get.toNamed(AppRoutes.PARISH);
          }),
          _mobileListTile("Horários", Icons.schedule),
          _mobileListTile("Eventos", Icons.event, onTap: () {
            Navigator.pop(context);
            Get.toNamed(AppRoutes.EVENTS);
          }),
          _mobileListTile("Dízimo", Icons.attach_money, onTap: () {
            Navigator.pop(context);
            Get.toNamed(AppRoutes.TITHE);
          }),
          _mobileListTile("Galeria", Icons.photo_library),
          _mobileListTile("Contato", Icons.contact_phone, onTap: () {
            Navigator.pop(context);
            Get.toNamed(AppRoutes.CONTACT);
          }),
          const Divider(),
          _mobileListTile("Login", Icons.login, onTap: () {
            Navigator.pop(context);
            Get.toNamed(AppRoutes.login);
          }),
        ],
      ),
    );
  }

  ListTile _mobileListTile(String title, IconData icon, {VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey[600]),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
      onTap: onTap ?? () {},
    );
  }
}

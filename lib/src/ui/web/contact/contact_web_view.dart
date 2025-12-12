import 'package:flutter/material.dart';
import 'package:plataforma_pnsa/src/routes/app_routes.dart';
import 'package:plataforma_pnsa/src/ui/core/theme/app_theme.dart';
import 'package:plataforma_pnsa/src/ui/web/widgets/mobile_drawer.dart';
import 'package:plataforma_pnsa/src/ui/web/widgets/web_nav_bar.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactWebView extends StatelessWidget {
  const ContactWebView({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bool isMobile = size.width < 900;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: const WebNavBar(activeRoute: AppRoutes.CONTACT),
      endDrawer: isMobile ? const WebMobileDrawer() : null,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeroHeader(context),
            // O conteúdo principal sobe sobre o header (efeito overlap)
            Transform.translate(
              offset: const Offset(0, -50),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _buildMainContent(context, isMobile),
              ),
            ),
            _buildFooter(isMobile),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Header Inspirador
  // ---------------------------------------------------------------------------
  Widget _buildHeroHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 60, bottom: 120, left: 24, right: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryColor,
            AppTheme.primaryColor.withOpacity(0.85),
          ],
        ),
      ),
      child: Column(
        children: [
          const Text(
            "Fale Conosco",
            style: TextStyle(
              fontSize: 42,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "Precisa de informações ou atendimento pastoral?\nEstamos a um clique de distância.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              color: Colors.white.withOpacity(0.9),
              fontWeight: FontWeight.w300,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Card Principal (Split View)
  // ---------------------------------------------------------------------------
  Widget _buildMainContent(BuildContext context, bool isMobile) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1000),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 30,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: isMobile
              ? Column(
            children: [
              _buildWhatsAppSection(isMobile: true),
              const Divider(height: 1),
              _buildLocationSection(isMobile: true),
            ],
          )
              : IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: 5,
                  child: _buildWhatsAppSection(isMobile: false),
                ),
                Container(width: 1, color: Colors.grey[200]),
                Expanded(
                  flex: 4,
                  child: _buildLocationSection(isMobile: false),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Seção 1: Foco Total no WhatsApp
  // ---------------------------------------------------------------------------
  Widget _buildWhatsAppSection({required bool isMobile}) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment:
        isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFDCF8C6).withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.chat_bubble,
                size: 40, color: Color(0xFF25D366)),
          ),
          const SizedBox(height: 24),
          Text(
            "Atendimento Online",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "A maneira mais rápida de falar com nossa secretaria. Tire dúvidas sobre horários, sacramentos e agendamentos agora mesmo.",
            textAlign: isMobile ? TextAlign.center : TextAlign.start,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              height: 1.5,
            ),
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: isMobile ? double.infinity : 300,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: () async {
                final Uri whatsappUri = Uri.parse(
                    "https://wa.me/556436743149?text=Olá, gostaria de falar com a secretaria.");
                if (!await launchUrl(whatsappUri)) {
                  // Handle error
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF25D366),
                foregroundColor: Colors.white,
                elevation: 4,
                shadowColor: const Color(0xFF25D366).withOpacity(0.4),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              icon: const Icon(Icons.send_rounded),
              label: const Text(
                "INICIAR CONVERSA",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment:
            isMobile ? MainAxisAlignment.center : MainAxisAlignment.start,
            children: [
              Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                      color: Colors.green, shape: BoxShape.circle)),
              const SizedBox(width: 8),
              Text(
                "Secretaria Online Agora",
                style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 13,
                    fontWeight: FontWeight.w500),
              ),
            ],
          )
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Seção 2: Informações de Localização
  // ---------------------------------------------------------------------------
  Widget _buildLocationSection({required bool isMobile}) {
    return Container(
      color: const Color(0xFFFAFAFA),
      padding: const EdgeInsets.all(40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Outras Formas de Contato",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 32),
          _buildInfoRow(
            Icons.location_on_outlined,
            "Visite-nos",
            "Av. Pará, 491 - Centro\nIporá - GO, 76200-000",
          ),
          const SizedBox(height: 24),
          _buildInfoRow(
            Icons.access_time,
            "Horário de Funcionamento",
            "Segunda a Sexta: 08h às 18h\nSábado: 08h às 12h",
          ),
          const SizedBox(height: 24),
          _buildInfoRow(
            Icons.phone_outlined,
            "Telefone Fixo",
            "(64) 3674-3149",
          ),
          const SizedBox(height: 24),
          _buildInfoRow(
            Icons.email_outlined,
            "E-mail",
            "contato@paroquia.com.br",
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String title, String content) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppTheme.primaryColor, size: 22),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                content,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey[600],
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // FOOTER (Dark Theme)
  // ---------------------------------------------------------------------------
  Widget _buildFooter(bool isMobile) {
    return Container(
      color: const Color(0xFF1F2937), // Dark grey
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
      margin: const EdgeInsets.only(top: 80),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              Flex(
                direction: isMobile ? Axis.vertical : Axis.horizontal,
                crossAxisAlignment: isMobile
                    ? CrossAxisAlignment.center
                    : CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Coluna 1: Marca e Social
                  SizedBox(
                    width: isMobile ? null : 350,
                    child: Column(
                      crossAxisAlignment: isMobile
                          ? CrossAxisAlignment.center
                          : CrossAxisAlignment.start,
                      children: [
                        const Text("Paróquia N. Sra. Auxiliadora",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        Text(
                          "Av. Pará, 491 - Centro\nIporá - GO, 76200-000",
                          textAlign:
                          isMobile ? TextAlign.center : TextAlign.start,
                          style:
                          TextStyle(color: Colors.grey[400], height: 1.5),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: isMobile
                              ? MainAxisAlignment.center
                              : MainAxisAlignment.start,
                          children: const [
                            _SocialIcon(Icons.facebook),
                            SizedBox(width: 12),
                            _SocialIcon(Icons.camera_alt), // Instagram
                            SizedBox(width: 12),
                            _SocialIcon(Icons.play_circle_fill), // Youtube
                          ],
                        )
                      ],
                    ),
                  ),
                  if (isMobile) const SizedBox(height: 40),

                  // Coluna 2: Navegação
                  _FooterLinksColumn(
                      isMobile: isMobile,
                      title: "Navegação",
                      links: ["Início", "A Paróquia", "Eventos", "Dízimo"]),
                  if (isMobile) const SizedBox(height: 30),

                  // Coluna 3: Links Rápidos
                  _FooterLinksColumn(
                      isMobile: isMobile,
                      title: "Serviços",
                      links: [
                        "Secretaria",
                        "Intenções de Missa",
                        "Batismo",
                        "Catequese"
                      ]),
                ],
              ),
              const SizedBox(height: 60),
              Divider(color: Colors.grey[800]),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("© 2025 PNSA. Todos os direitos reservados.",
                      style: TextStyle(color: Colors.grey[500], fontSize: 13)),
                  if (!isMobile)
                    Text("Feito com Flutter",
                        style:
                        TextStyle(color: Colors.grey[600], fontSize: 13)),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Widgets Auxiliares do Footer
// ---------------------------------------------------------------------------

class _FooterLinksColumn extends StatelessWidget {
  final String title;
  final List<String> links;
  final bool isMobile;

  const _FooterLinksColumn(
      {required this.title, required this.links, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
      isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16)),
        const SizedBox(height: 20),
        ...links.map((link) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: () {},
            child: Text(link,
                style: TextStyle(color: Colors.grey[400], fontSize: 14)),
          ),
        ))
      ],
    );
  }
}

class _SocialIcon extends StatelessWidget {
  final IconData icon;
  const _SocialIcon(this.icon);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[800],
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: Colors.white, size: 20),
    );
  }
}
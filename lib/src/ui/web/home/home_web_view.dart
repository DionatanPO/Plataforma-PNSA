import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:plataforma_pnsa/src/routes/app_routes.dart';
import 'package:plataforma_pnsa/src/ui/core/theme/app_theme.dart';
import 'package:plataforma_pnsa/src/ui/web/widgets/mobile_drawer.dart';
import 'package:plataforma_pnsa/src/ui/web/widgets/web_nav_bar.dart';

class HomeWebView extends StatefulWidget {
  const HomeWebView({super.key});

  @override
  State<HomeWebView> createState() => _HomeWebViewState();
}

class _HomeWebViewState extends State<HomeWebView> {
  final ScrollController _scrollController = ScrollController();

  // Cores refinadas para o layout
  final Color primaryColor = AppTheme.primaryColor;
  final Color accentColor = AppTheme.accentColor;
  final Color bgColor = const Color(0xFFF3F4F6); // Cinza "Cool Gray"
  final Color darkFooterColor = const Color(0xFF1F2937); // Cinza Escuro Premium

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 900;

    return Scaffold(
      backgroundColor: bgColor,
      // AppBar transparente sobre o conteúdo ou sólida dependendo do scroll (opcional, mantive padrão aqui)
      appBar: WebNavBar(activeRoute: AppRoutes.web_home),
      endDrawer: isMobile ? const WebMobileDrawer() : null,
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: [
            _buildHeroBanner(width, isMobile),

            // Conteúdo Central
            Transform.translate(
              offset: const Offset(0, -60), // Efeito de sobreposição visual
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // CARDS DE SERVIÇO (Flutuando sobre o banner)
                        _buildQuickCards(context),

                        const SizedBox(height: 80),

                        // SEÇÃO DE NOTÍCIAS
                        _buildSectionHeader("Acontece na Paróquia"),
                        const SizedBox(height: 32),
                        _buildNewsSection(isMobile),

                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            _buildFooter(isMobile),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // HERO BANNER (Imersivo)
  // ---------------------------------------------------------------------------
  Widget _buildHeroBanner(double width, bool isMobile) {
    return Container(
      height: isMobile ? 500 : 600,
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.grey,
        image: DecorationImage(
          image: AssetImage("assets/images/paroquia_banner.jpg"),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          // Gradiente Escuro (Overlay) para contraste
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.2),
                  Colors.black.withOpacity(0.8),
                ],
              ),
            ),
          ),

          // Conteúdo do Banner
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: accentColor.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Text(
                        "SEJAM BEM-VINDOS",
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1.5),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      "Fé, Esperança\ne Comunidade",
                      textAlign: isMobile ? TextAlign.center : TextAlign.start,
                      style: TextStyle(
                        fontSize: isMobile ? 42 : 64,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        height: 1.1,
                        letterSpacing: -1,
                        shadows: [
                          Shadow(offset: const Offset(0, 4), blurRadius: 20, color: Colors.black.withOpacity(0.5)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Paróquia Nossa Senhora Auxiliadora - Iporá/GO",
                      textAlign: isMobile ? TextAlign.center : TextAlign.start,
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white.withOpacity(0.9),
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    const SizedBox(height: 40),
                    Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      alignment: isMobile ? WrapAlignment.center : WrapAlignment.start,
                      children: [
                        _HeroButton(
                            text: "Assistir Ao Vivo",
                            icon: Icons.play_arrow_rounded,
                            isPrimary: true,
                            color: primaryColor
                        ),
                        _HeroButton(
                            text: "Horários de Missa",
                            icon: Icons.calendar_today_outlined,
                            isPrimary: false,
                            color: Colors.white
                        ),
                      ],
                    ),
                    // Espaço extra para compensar o translate dos cards
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Container(width: 4, height: 32, color: accentColor),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Cards de Serviços (Estilo Moderno)
  // ---------------------------------------------------------------------------
  Widget _buildQuickCards(BuildContext context) {
    final services = [
      {'icon': Icons.access_time_filled, 'title': 'Horários', 'desc': 'Missas e confissões'},
      {'icon': Icons.volunteer_activism, 'title': 'Dízimo', 'desc': 'Contribuição online'},
      {'icon': Icons.event_note, 'title': 'Agenda', 'desc': 'Calendário paroquial'},
      {'icon': Icons.perm_phone_msg, 'title': 'Contato', 'desc': 'Fale com a secretaria'},
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        double cardWidth = constraints.maxWidth < 600
            ? constraints.maxWidth
            : (constraints.maxWidth - 60) / 4;

        if (constraints.maxWidth > 600 && constraints.maxWidth < 1100) {
          cardWidth = (constraints.maxWidth - 20) / 2;
        }

        return Wrap(
          spacing: 20,
          runSpacing: 20,
          children: services.map((service) {
            return SizedBox(
              width: cardWidth,
              child: _ModernServiceCard(
                icon: service['icon'] as IconData,
                title: service['title'] as String,
                description: service['desc'] as String,
                primaryColor: primaryColor,
              ),
            );
          }).toList(),
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Notícias (Layout Revista)
  // ---------------------------------------------------------------------------
  Widget _buildNewsSection(bool isMobile) {
    return IntrinsicHeight(
      child: Flex(
        direction: isMobile ? Axis.vertical : Axis.horizontal,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Destaque Principal
          Expanded(
            flex: isMobile ? 0 : 3,
            child: _buildFeaturedNewsCard(),
          ),

          if (!isMobile) const SizedBox(width: 30),
          if (isMobile) const SizedBox(height: 30),

          // Lista Lateral
          Expanded(
            flex: isMobile ? 0 : 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSideNewsItem("12 DEZ", "Inscrições abertas para a Catequese 2025"),
                const Divider(height: 30),
                _buildSideNewsItem("10 DEZ", "Bazar beneficente neste final de semana no salão"),
                const Divider(height: 30),
                _buildSideNewsItem("08 DEZ", "Novo horário de atendimento da secretaria paroquial"),
                const SizedBox(height: 20),
                OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: primaryColor),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  ),
                  child: Text("VER TODAS AS NOTÍCIAS", style: TextStyle(color: primaryColor)),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedNewsCard() {
    return Container(
      height: 400,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 15, offset: const Offset(0, 5))],
        image: const DecorationImage(
          image: AssetImage("assets/images/paroquia.png"), // Certifique-se que existe
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black.withOpacity(0.9)],
                stops: const [0.5, 1.0],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: accentColor, borderRadius: BorderRadius.circular(4)),
                  child: const Text("DESTAQUE", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 12),
                const Text(
                  "Festa em Louvor a Nossa Senhora Auxiliadora",
                  style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold, height: 1.2),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Confira a programação completa e participe conosco deste momento de fé.",
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSideNewsItem(String date, String title) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Text(date.split(' ')[0], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            Text(date.split(' ')[1], style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            title,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.grey[800]),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // FOOTER DARK (Profissional)
  // ---------------------------------------------------------------------------
  Widget _buildFooter(bool isMobile) {
    return Container(
      color: darkFooterColor,
      padding: const EdgeInsets.only(top: 80, bottom: 40, left: 24, right: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              Flex(
                direction: isMobile ? Axis.vertical : Axis.horizontal,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Brand
                  SizedBox(
                    width: isMobile ? double.infinity : 350,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Paróquia N. Sra. Auxiliadora", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        Text(
                          "Av. Pará, 491 - Centro, Iporá-GO\nCEP: 76200-000",
                          style: TextStyle(color: Colors.grey[400], height: 1.5),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            _SocialIcon(Icons.facebook),
                            const SizedBox(width: 12),
                            _SocialIcon(Icons.camera_alt), // Instagram
                            const SizedBox(width: 12),
                            _SocialIcon(Icons.play_circle_fill), // Youtube
                          ],
                        )
                      ],
                    ),
                  ),
                  if (isMobile) const SizedBox(height: 40),

                  // Links
                  _FooterLinksColumn(title: "Navegação", links: ["Início", "A Paróquia", "Horários", "Pastorais"]),
                  if (isMobile) const SizedBox(height: 30),
                  _FooterLinksColumn(title: "Serviços", links: ["Secretaria", "Dízimo", "Intenções", "Batismo"]),
                  if (isMobile) const SizedBox(height: 30),
                  _FooterLinksColumn(title: "Contato", links: ["(64) 3674-3149", "auxiliadora@email.com", "Fale Conosco"]),
                ],
              ),
              const SizedBox(height: 60),
              Divider(color: Colors.grey[800]),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("© 2025 PNSA. Todos os direitos reservados.", style: TextStyle(color: Colors.grey[500], fontSize: 13)),
                  if (!isMobile)
                    Text("Desenvolvido com Flutter", style: TextStyle(color: Colors.grey[600], fontSize: 13)),
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
// WIDGETS AUXILIARES
// ---------------------------------------------------------------------------

class _HeroButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final bool isPrimary;
  final Color color;

  const _HeroButton({required this.text, required this.icon, required this.isPrimary, required this.color});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () {},
      icon: Icon(icon, color: isPrimary ? Colors.white : color),
      label: Text(text),
      style: ElevatedButton.styleFrom(
        backgroundColor: isPrimary ? color : Colors.transparent,
        foregroundColor: isPrimary ? Colors.white : color,
        elevation: isPrimary ? 4 : 0,
        side: isPrimary ? null : BorderSide(color: color, width: 2),
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 22),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _ModernServiceCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color primaryColor;

  const _ModernServiceCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.primaryColor,
  });

  @override
  State<_ModernServiceCard> createState() => _ModernServiceCardState();
}

class _ModernServiceCardState extends State<_ModernServiceCard> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 220,
        transform: Matrix4.translationValues(0, _isHovering ? -8 : 0, 0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(_isHovering ? 0.1 : 0.04),
              blurRadius: _isHovering ? 25 : 10,
              offset: Offset(0, _isHovering ? 15 : 4),
            )
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                widget.icon,
                size: 40,
                color: _isHovering ? widget.primaryColor : Colors.grey[700],
              ),
              const SizedBox(height: 20),
              Text(
                widget.title,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                widget.description,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[500], fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FooterLinksColumn extends StatelessWidget {
  final String title;
  final List<String> links;

  const _FooterLinksColumn({required this.title, required this.links});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 20),
        ...links.map((link) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: (){},
            child: Text(link, style: TextStyle(color: Colors.grey[400], fontSize: 14)),
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
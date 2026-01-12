import 'package:flutter/material.dart';
import 'package:plataforma_pnsa/src/routes/app_routes.dart';
import 'package:plataforma_pnsa/src/ui/core/theme/app_theme.dart';
import 'package:plataforma_pnsa/src/ui/web/widgets/mobile_drawer.dart';
import 'package:plataforma_pnsa/src/ui/web/widgets/web_nav_bar.dart';
import 'package:plataforma_pnsa/src/core/constants/app_constants.dart';

class ParishView extends StatelessWidget {
  const ParishView({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 900;

    // Cores auxiliares
    final Color bgColor = const Color(0xFFF3F4F6);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: const WebNavBar(activeRoute: AppRoutes.PARISH),
      endDrawer: isMobile ? const WebMobileDrawer() : null,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeroHeader(context),

            // Conteúdo com Overlap (Sobreposição)
            Transform.translate(
              offset: const Offset(0, -60),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    _buildHighlightsGrid(context, isMobile),
                    const SizedBox(height: 60),
                    _buildBodyContent(context, isMobile),
                  ],
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
  // HEADER
  // ---------------------------------------------------------------------------
  Widget _buildHeroHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 400,
      decoration: BoxDecoration(
        color: AppTheme.primaryColor,
        image: DecorationImage(
          image: const AssetImage("assets/images/paroquia.png"), // Fundo sutil
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
              AppTheme.primaryColor.withOpacity(0.9), BlendMode.multiply),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white30),
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Text(
              "DESDE 1951",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  letterSpacing: 2,
                  fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            "Nossa História e Missão",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: 600,
            child: Text(
              "Conheça a trajetória da ${AppConstants.parishName}, um farol de fé em Iporá.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                color: Colors.white.withOpacity(0.8),
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 40), // Espaço extra para o overlap
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // DESTAQUES (Cards Superiores)
  // ---------------------------------------------------------------------------
  Widget _buildHighlightsGrid(BuildContext context, bool isMobile) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1000),
        child: Wrap(
          spacing: 24,
          runSpacing: 24,
          alignment: WrapAlignment.center,
          children: [
            _HighlightCard(
              icon: Icons.calendar_month,
              title: "Fundação",
              subtitle: "15 de Março de 1951",
              width: isMobile ? double.infinity : 300,
            ),
            _HighlightCard(
              icon: Icons.shield_moon,
              title: "Ordem Religiosa",
              subtitle: "Passionistas",
              width: isMobile ? double.infinity : 300,
            ),
            _HighlightCard(
              icon: Icons.location_city,
              title: "Localização",
              subtitle: "Centro de Iporá - GO",
              width: isMobile ? double.infinity : 300,
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // CONTEÚDO PRINCIPAL (Timeline + Liderança)
  // ---------------------------------------------------------------------------
  Widget _buildBodyContent(BuildContext context, bool isMobile) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 900),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Seção História (Timeline)
            _buildSectionTitle("Nossa Caminhada"),
            const SizedBox(height: 32),
            _buildTimelineItem(
              year: "1951",
              title: "O Início da Jornada",
              content:
                  "Fundada em 15 de março, a ${AppConstants.parishName} nasce como a Igreja Matriz de Iporá, tornando-se o coração pulsante da fé católica na região.",
              isLast: false,
            ),
            _buildTimelineItem(
              year: "Missão",
              title: "Espiritualidade Passionista",
              content:
                  "Entregue aos cuidados da Província Exaltação da Santa Cruz, seguimos os passos de São Paulo da Cruz, vivendo a memória da Paixão de Cristo como remédio para os males do mundo.",
              isLast: false,
            ),
            _buildTimelineItem(
              year: "2024",
              title: "Homenagem à Padroeira",
              content:
                  "Em maio, inauguramos o monumento em homenagem à Nossa Senhora Auxiliadora próximo ao Campo do Juventude, eternizando a devoção da cidade.",
              isLast: true,
            ),

            const SizedBox(height: 80),

            // Seção Liderança (Cards)
            _buildSectionTitle("Nossos Pastores"),
            const SizedBox(height: 8),
            Text(
              "Conheça os sacerdotes que guiam nossa comunidade atualmente.",
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
            const SizedBox(height: 40),

            Center(
              child: Wrap(
                spacing: 30,
                runSpacing: 30,
                alignment: WrapAlignment.center,
                children: [
                  _PriestCard(
                    name: "Pe. Tarcílio José",
                    title: "Pároco",
                    imageAsset: "assets/images/padre1.jpg", // Placeholder
                  ),
                  _PriestCard(
                    name: "Pe. Leonardo Luiz",
                    title: "Vigário Paroquial",
                    imageAsset: "assets/images/padre2.jpg",
                  ),
                  _PriestCard(
                    name: "Pe. Rodrigo Alves",
                    title: "Vigário Paroquial",
                    imageAsset: "assets/images/padre3.jpg",
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 8),
          height: 5,
          width: 80,
          decoration: BoxDecoration(
            color: AppTheme.accentColor,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // FOOTER (Dark Theme Profissional)
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
                        const Text(AppConstants.parishName,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        Text(
                          "${AppConstants.parishAddress}\n76200-000",
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
                  Text(
                      "${AppConstants.copyright}. Todos os direitos reservados.",
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

  // ---------------------------------------------------------------------------
  // TIMELINE WIDGET
  // ---------------------------------------------------------------------------
  Widget _buildTimelineItem({
    required String year,
    required String title,
    required String content,
    required bool isLast,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Coluna da Esquerda (Ano + Linha)
          Column(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  year,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: Colors.grey[300],
                    margin: const EdgeInsets.symmetric(vertical: 4),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 24),

          // Coluna da Direita (Conteúdo)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 40.0),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      content,
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.6,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// WIDGETS AUXILIARES
// ---------------------------------------------------------------------------

class _HighlightCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final double width;

  const _HighlightCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, size: 40, color: AppTheme.accentColor),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey[400],
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }
}

class _PriestCard extends StatelessWidget {
  final String name;
  final String title;
  final String imageAsset;

  const _PriestCard({
    required this.name,
    required this.title,
    required this.imageAsset,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
            child: Icon(Icons.person, size: 50, color: AppTheme.primaryColor),
            // Em produção, use: backgroundImage: AssetImage(imageAsset),
          ),
          const SizedBox(height: 20),
          Text(
            name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.accentColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

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

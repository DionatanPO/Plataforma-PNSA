import 'package:flutter/material.dart';
import 'package:plataforma_pnsa/src/routes/app_routes.dart';
import 'package:plataforma_pnsa/src/ui/core/theme/app_theme.dart';
import 'package:plataforma_pnsa/src/ui/web/widgets/mobile_drawer.dart';
import 'package:plataforma_pnsa/src/ui/web/widgets/web_nav_bar.dart';
import 'package:plataforma_pnsa/src/core/constants/app_constants.dart';

class EventsView extends StatefulWidget {
  const EventsView({super.key});

  @override
  State<EventsView> createState() => _EventsViewState();
}

class _EventsViewState extends State<EventsView> {
  // Dados simulados com estrutura para o Date Badge
  final List<Map<String, String>> events = [
    {
      'title': 'Festa da Padroeira N. Sra. Auxiliadora',
      'day': '24',
      'month': 'MAI',
      'category': 'Solenidade',
      'description':
          'Celebração maior com missas, procissão luminosa e quermesse.',
      'image': 'assets/images/paroquia.png',
    },
    {
      'title': 'Corpus Christi',
      'day': '19',
      'month': 'JUN',
      'category': 'Liturgia',
      'description':
          'Confecção dos tapetes e procissão do Santíssimo Sacramento.',
      'image': 'assets/images/logo.jpg',
    },
    {
      'title': 'EJC - Encontro de Jovens',
      'day': '15',
      'month': 'AGO',
      'category': 'Retiro',
      'description':
          'Fim de semana de reflexão e encontro com Deus para a juventude.',
      'image': 'assets/images/paroquia.png',
    },
    {
      'title': 'Bênção dos Animais',
      'day': '04',
      'month': 'OUT',
      'category': 'Comunidade',
      'description': 'Celebração especial em honra a São Francisco de Assis.',
      'image': 'assets/images/logo.jpg',
    },
    {
      'title': 'Missa de Natal',
      'day': '25',
      'month': 'DEZ',
      'category': 'Solenidade',
      'description': 'Celebração do nascimento de Cristo com coral ao vivo.',
      'image': 'assets/images/paroquia.png',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bool isMobile = size.width < 900;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: const WebNavBar(activeRoute: AppRoutes.EVENTS),
      endDrawer: isMobile ? const WebMobileDrawer() : null,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeroHeader(context, isMobile),

            // Conteúdo principal sobrepondo levemente o header
            Transform.translate(
              offset: const Offset(0, -50),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    _buildCategoryFilters(isMobile),
                    const SizedBox(height: 40),
                    _buildEventsGrid(context, size.width),
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
  // Hero Header Imersivo
  // ---------------------------------------------------------------------------
  Widget _buildHeroHeader(BuildContext context, bool isMobile) {
    return Container(
      width: double.infinity,
      height: 400,
      decoration: BoxDecoration(
        color: AppTheme.primaryColor,
        image: DecorationImage(
          image: const AssetImage("assets/images/paroquia_banner.jpg"),
          fit: BoxFit.cover,
          colorFilter:
              ColorFilter.mode(Colors.black.withOpacity(0.6), BlendMode.darken),
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Calendário Pastoral",
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: -1,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.white30),
              ),
              child: const Text(
                "Acompanhe e participe da vida da nossa comunidade",
                style: TextStyle(fontSize: 16, color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 40), // Espaço extra para o overlap
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Filtros de Categoria (Visual)
  // ---------------------------------------------------------------------------
  Widget _buildCategoryFilters(bool isMobile) {
    if (isMobile) return const SizedBox.shrink();

    final categories = [
      "Todos",
      "Solenidades",
      "Retiros",
      "Festas",
      "Formação"
    ];

    return Center(
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(50),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, 10),
            )
          ],
        ),
        child: Wrap(
          spacing: 8,
          children: categories.map((cat) {
            final isSelected = cat == "Todos";
            return InkWell(
              onTap: () {},
              borderRadius: BorderRadius.circular(30),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color:
                      isSelected ? AppTheme.primaryColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  cat,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey[600],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Grid de Eventos
  // ---------------------------------------------------------------------------
  Widget _buildEventsGrid(BuildContext context, double width) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: LayoutBuilder(
          builder: (context, constraints) {
            int crossAxisCount = 3;
            if (constraints.maxWidth < 650)
              crossAxisCount = 1;
            else if (constraints.maxWidth < 1100) crossAxisCount = 2;

            double cardWidth =
                (constraints.maxWidth - ((crossAxisCount - 1) * 30)) /
                    crossAxisCount;

            return Wrap(
              spacing: 30,
              runSpacing: 40,
              children: events.map((event) {
                return SizedBox(
                  width: cardWidth,
                  child: _ModernEventCard(
                    title: event['title']!,
                    day: event['day']!,
                    month: event['month']!,
                    category: event['category']!,
                    description: event['description']!,
                    imageUrl: event['image']!,
                  ),
                );
              }).toList(),
            );
          },
        ),
      ),
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
}

// ---------------------------------------------------------------------------
// Card de Evento Moderno
// ---------------------------------------------------------------------------
class _ModernEventCard extends StatefulWidget {
  final String title;
  final String day;
  final String month;
  final String category;
  final String description;
  final String imageUrl;

  const _ModernEventCard({
    required this.title,
    required this.day,
    required this.month,
    required this.category,
    required this.description,
    required this.imageUrl,
  });

  @override
  State<_ModernEventCard> createState() => _ModernEventCardState();
}

class _ModernEventCardState extends State<_ModernEventCard> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.translationValues(0, _isHovering ? -8 : 0, 0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(_isHovering ? 0.15 : 0.05),
              blurRadius: _isHovering ? 25 : 15,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagem + Badge de Data
            Stack(
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(16)),
                  child: Image.asset(
                    widget.imageUrl,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 16,
                  left: 16,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 8),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          widget.day,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                            height: 1,
                          ),
                        ),
                        Text(
                          widget.month,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 16,
                  right: 16,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      widget.category.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Conteúdo
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 18, // Fonte Web
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.description,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Botão "Ler Mais" com animação de cor
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
                    decoration: BoxDecoration(
                        border: Border(
                            bottom: BorderSide(
                                color: _isHovering
                                    ? AppTheme.primaryColor
                                    : Colors.transparent,
                                width: 2))),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "SAIBA MAIS",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: _isHovering
                                ? AppTheme.primaryColor
                                : Colors.grey[500],
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.arrow_forward,
                          size: 16,
                          color: _isHovering
                              ? AppTheme.primaryColor
                              : Colors.grey[500],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
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

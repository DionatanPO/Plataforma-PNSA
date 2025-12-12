import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:plataforma_pnsa/src/routes/app_routes.dart';
import 'package:plataforma_pnsa/src/ui/core/theme/app_theme.dart';
import 'package:plataforma_pnsa/src/ui/web/widgets/mobile_drawer.dart';
import 'package:plataforma_pnsa/src/ui/web/widgets/web_nav_bar.dart';

class TitheView extends StatelessWidget {
  const TitheView({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bool isMobile = size.width < 900;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: const WebNavBar(activeRoute: AppRoutes.TITHE),
      endDrawer: isMobile ? const WebMobileDrawer() : null,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeroHeader(context),

            // Conteúdo Principal com Overlap
            Transform.translate(
              offset: const Offset(0, -60),
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
  // Hero Header
  // ---------------------------------------------------------------------------
  Widget _buildHeroHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 400,
      decoration: BoxDecoration(
        color: AppTheme.primaryColor,
        image: DecorationImage(
          image: const AssetImage("assets/images/paroquia_banner.jpg"), // Banner genérico
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.7),
              BlendMode.darken
          ),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white30),
            ),
            child: const Icon(Icons.volunteer_activism, size: 40, color: Colors.white),
          ),
          const SizedBox(height: 24),
          const Text(
            "Dízimo e Ofertas",
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "Gratidão que transforma e evangeliza.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              color: Colors.white.withOpacity(0.9),
              fontWeight: FontWeight.w300,
            ),
          ),
          const SizedBox(height: 40), // Espaço extra para o overlap
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Conteúdo Principal (Split View)
  // ---------------------------------------------------------------------------
  Widget _buildMainContent(BuildContext context, bool isMobile) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1100),
        child: Flex(
          direction: isMobile ? Axis.vertical : Axis.horizontal,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Lado Esquerdo: Explicação Espiritual
            Expanded(
              flex: isMobile ? 0 : 5,
              child: _buildSpiritualSection(),
            ),

            if (!isMobile) const SizedBox(width: 40),
            if (isMobile) const SizedBox(height: 40),

            // Lado Direito: Ações (Pix e Banco)
            Expanded(
              flex: isMobile ? 0 : 4,
              child: Column(
                children: [
                  _buildPixCard(context),
                  const SizedBox(height: 24),
                  _buildBankDetailsCard(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Seção Espiritual (Esquerda)
  // ---------------------------------------------------------------------------
  Widget _buildSpiritualSection() {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Por que ser dizimista?",
            style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800]
            ),
          ),
          const SizedBox(height: 24),
          Text(
            "O dízimo é uma experiência de fé, amor e gratidão. É através da sua contribuição fiel que nossa paróquia mantém as portas abertas, realiza obras sociais, sustenta o clero e promove a evangelização.",
            style: TextStyle(fontSize: 16, color: Colors.grey[600], height: 1.6),
          ),
          const SizedBox(height: 32),

          // Citação Estilizada
          Container(
            padding: const EdgeInsets.only(left: 20),
            decoration: BoxDecoration(
              border: Border(left: BorderSide(color: AppTheme.accentColor, width: 4)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '"Cada um contribua segundo propôs no seu coração; não com tristeza, ou por necessidade; porque Deus ama ao que dá com alegria."',
                  style: TextStyle(
                    fontSize: 18,
                    fontStyle: FontStyle.italic,
                    color: Colors.grey[800],
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "— 2 Coríntios 9:7",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Text(
            "Sua oferta sustenta:",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[800]),
          ),
          const SizedBox(height: 16),
          _buildCheckItem("Manutenção do Templo e Capelas"),
          _buildCheckItem("Formação de Catequistas e Lideranças"),
          _buildCheckItem("Ações Sociais aos mais necessitados"),
          _buildCheckItem("Liturgia e Evangelização"),
        ],
      ),
    );
  }

  Widget _buildCheckItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: AppTheme.accentColor, size: 20),
          const SizedBox(width: 12),
          Text(text, style: TextStyle(color: Colors.grey[700], fontSize: 15)),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Card PIX (Destaque)
  // ---------------------------------------------------------------------------
  Widget _buildPixCard(BuildContext context) {
    const pixKey = "auxiliadoraipora@gmail.com";

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: const Color(0xFF1E3A8A), // Azul Escuro (Premium)
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E3A8A).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.pix, color: Colors.white, size: 28), // Ícone do Flutter tem Pix? Se não, use qr_code
              const SizedBox(width: 8),
              const Text(
                "PIX Rápido",
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            // QR Code Placeholder
            child: Image.asset(
              'assets/images/qrcode.png',
              width: 180,
              height: 180,
              // Fallback se não tiver imagem ainda
              errorBuilder: (context, error, stackTrace) => Container(
                width: 180, height: 180,
                alignment: Alignment.center,
                child: Icon(Icons.qr_code_2, size: 100, color: Colors.grey[800]),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            "Chave E-mail",
            style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14),
          ),
          const SizedBox(height: 4),
          SelectableText(
            pixKey,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: () {
                Clipboard.setData(const ClipboardData(text: pixKey));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text("Chave PIX copiada!"),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                );
              },
              icon: const Icon(Icons.copy, size: 20),
              label: const Text("COPIAR CHAVE"),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Card Transferência Bancária
  // ---------------------------------------------------------------------------
  Widget _buildBankDetailsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.account_balance, color: AppTheme.primaryColor),
              const SizedBox(width: 12),
              Text(
                "Transferência Bancária",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[800]),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildBankInfoRow("Banco", "Banco do Brasil (001)"),
          const Divider(height: 24),
          _buildBankInfoRow("Agência", "1234-5"),
          const Divider(height: 24),
          _buildBankInfoRow("Conta Corrente", "12345-6"),
          const Divider(height: 24),
          _buildBankInfoRow("CNPJ", "00.000.000/0001-00"),
          const Divider(height: 24),
          _buildBankInfoRow("Favorecido", "Mitra Diocesana (Paróquia NSA)"),
        ],
      ),
    );
  }

  Widget _buildBankInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
        Text(value, style: TextStyle(color: Colors.grey[900], fontWeight: FontWeight.w600, fontSize: 14)),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Footer (Consistente)
  // ---------------------------------------------------------------------------
  Widget _buildFooter(bool isMobile) {
    return Container(
      color: const Color(0xFF1F2937),
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
      margin: const EdgeInsets.only(top: 80),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              Text(
                "© 2025 Paróquia Nossa Senhora Auxiliadora",
                style: TextStyle(color: Colors.grey[400]),
              ),
              const SizedBox(height: 8),
              Text(
                "Deus abençoe sua generosidade.",
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
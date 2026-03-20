import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:fala_torcedor/core/colors.dart';
import 'package:fala_torcedor/main.dart';
import 'package:fala_torcedor/services/api_service.dart';
import 'package:fala_torcedor/views/equipes/equipes_list_view.dart';
import 'package:fala_torcedor/views/jogos/jogos_list_view.dart';
import 'package:fala_torcedor/views/planos/planos_list_view.dart';
import 'package:fala_torcedor/views/torcedores/torcedores_list_view.dart';
import 'package:fala_torcedor/views/campeonatos/campeonatos_list_view.dart';
import 'package:fala_torcedor/views/relatorios/relatorios_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  Map<String, int> _contadores = {};

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
    _carregarContadores();
  }

  Future<void> _carregarContadores() async {
    try {
      final uri = Uri.parse('${ApiService.baseUrl}/contadores');
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (mounted) {
          setState(() {
            _contadores = {
              'equipes': int.tryParse('${data['equipes']}') ?? 0,
              'torcedores': int.tryParse('${data['torcedores']}') ?? 0,
              'jogos': int.tryParse('${data['jogos']}') ?? 0,
              'planos': int.tryParse('${data['planos']}') ?? 0,
              'campeonatos': int.tryParse('${data['campeonatos']}') ?? 0,
            };
          });
        }
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  String _saudacao() {
    final hora = DateTime.now().hour;
    if (hora < 12) return 'Bom dia';
    if (hora < 18) return 'Boa tarde';
    return 'Boa noite';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _buildDrawer(context),
      body: Builder(
        builder: (ctx) => SafeArea(
          child: FadeTransition(
            opacity: _fadeAnim,
            child: SlideTransition(
              position: _slideAnim,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    _buildHeader(ctx),
                    const SizedBox(height: 24),
                    _buildStatsStrip(context),
                    const SizedBox(height: 28),
                    _buildSectionLabel(context, 'MÓDULOS'),
                    const SizedBox(height: 14),
                    _buildGrid(context),
                    const SizedBox(height: 12),
                    _buildFeaturedCards(context),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ======================== HEADER ========================

  Widget _buildHeader(BuildContext ctx) {
    return Row(
      children: [
        IconButton(
          onPressed: () => Scaffold.of(ctx).openDrawer(),
          icon: const Icon(Icons.menu_rounded),
          style: IconButton.styleFrom(
            backgroundColor: Theme.of(ctx).colorScheme.outlineVariant,
            foregroundColor: Theme.of(ctx).colorScheme.onSurface,
            padding: const EdgeInsets.all(12),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${_saudacao()}!',
                style: TextStyle(
                  fontSize: 13,
                  color: Theme.of(ctx).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                'Fala, Torcedor!',
                style: GoogleFonts.inter(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Theme.of(ctx).colorScheme.onSurface,
                  letterSpacing: -0.8,
                  height: 1.15,
                ),
              ),
            ],
          ),
        ),
        ListenableBuilder(
          listenable: themeProvider,
          builder: (_, _) => IconButton(
            onPressed: () => themeProvider.toggle(),
            icon: Icon(
              themeProvider.isDark
                  ? Icons.light_mode_rounded
                  : Icons.dark_mode_rounded,
            ),
            style: IconButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.outlineVariant,
              foregroundColor: Theme.of(ctx).colorScheme.onSurface,
              padding: const EdgeInsets.all(12),
            ),
          ),
        ),
      ],
    );
  }

  // ======================== STATS STRIP ========================

  Widget _buildStatsStrip(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildStatItem(
            context,
            '${_contadores['equipes'] ?? 0}',
            'Equipes',
            Icons.shield_rounded,
            AppColors.primary,
          ),
          _buildStatDivider(context),
          _buildStatItem(
            context,
            '${_contadores['torcedores'] ?? 0}',
            'Torcedores',
            Icons.people_rounded,
            AppColors.secondary,
          ),
          _buildStatDivider(context),
          _buildStatItem(
            context,
            '${_contadores['jogos'] ?? 0}',
            'Jogos',
            Icons.sports_score_rounded,
            AppColors.jogos,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String valor,
    String label,
    IconData icon,
    Color cor,
  ) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: cor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: cor, size: 18),
          ),
          const SizedBox(height: 6),
          Text(
            valor,
            style: GoogleFonts.inter(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Theme.of(context).colorScheme.onSurface,
              letterSpacing: -0.5,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatDivider(BuildContext context) {
    return Container(
      height: 44,
      width: 1,
      color: Theme.of(context).colorScheme.outlineVariant,
    );
  }

  // ======================== SECTION LABEL ========================

  Widget _buildSectionLabel(BuildContext context, String label) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }

  // ======================== 2-COLUMN GRID ========================

  Widget _buildGrid(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _CompactCard(
                icon: Icons.shield_rounded,
                title: 'Equipes',
                contador: _contadores['equipes'],
                gradient: [AppColors.primary, AppColors.primaryLight],
                onTap: () => _navegarPara(context, const EquipesListView()),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _CompactCard(
                icon: Icons.people_rounded,
                title: 'Torcedores',
                contador: _contadores['torcedores'],
                gradient: [AppColors.secondary, AppColors.secondaryLight],
                onTap: () => _navegarPara(context, const TorcedoresListView()),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _CompactCard(
                icon: Icons.card_membership_rounded,
                title: 'Planos',
                contador: _contadores['planos'],
                gradient: [AppColors.accent, AppColors.accentLight],
                onTap: () => _navegarPara(context, const PlanosListView()),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _CompactCard(
                icon: Icons.sports_score_rounded,
                title: 'Jogos',
                contador: _contadores['jogos'],
                gradient: [AppColors.jogos, AppColors.jogosLight],
                onTap: () => _navegarPara(context, const JogosListView()),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ======================== FEATURED FULL-WIDTH CARDS ========================

  Widget _buildFeaturedCards(BuildContext context) {
    return Column(
      children: [
        _MenuCard(
          icon: Icons.emoji_events_rounded,
          title: 'Campeonatos',
          subtitle: 'Criar e gerenciar campeonatos',
          contador: _contadores['campeonatos'],
          gradient: [AppColors.campeonatos, AppColors.campeonatosLight],
          onTap: () => _navegarPara(context, const CampeonatosListView()),
        ),
        const SizedBox(height: 12),
        _MenuCard(
          icon: Icons.bar_chart_rounded,
          title: 'Relatórios',
          subtitle: 'Estatísticas e gráficos interativos',
          gradient: [AppColors.relatorios, AppColors.relatoriosLight],
          featured: true,
          onTap: () => _navegarPara(context, const RelatoriosView()),
        ),
      ],
    );
  }

  // ======================== NAVIGATION ========================

  void _navegarPara(BuildContext context, Widget pagina) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => pagina));
    _carregarContadores();
  }

  // ======================== DRAWER ========================

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.secondary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.sports_soccer_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Fala, Torcedor!',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
          _buildDrawerItem(
            icon: Icons.shield_rounded,
            label: 'Equipes',
            onTap: () {
              Navigator.pop(context);
              _navegarPara(context, const EquipesListView());
            },
          ),
          _buildDrawerItem(
            icon: Icons.people_rounded,
            label: 'Torcedores',
            onTap: () {
              Navigator.pop(context);
              _navegarPara(context, const TorcedoresListView());
            },
          ),
          _buildDrawerItem(
            icon: Icons.sports_score_rounded,
            label: 'Jogos',
            onTap: () {
              Navigator.pop(context);
              _navegarPara(context, const JogosListView());
            },
          ),
          _buildDrawerItem(
            icon: Icons.card_membership_rounded,
            label: 'Planos',
            onTap: () {
              Navigator.pop(context);
              _navegarPara(context, const PlanosListView());
            },
          ),
          _buildDrawerItem(
            icon: Icons.emoji_events_rounded,
            label: 'Campeonatos',
            onTap: () {
              Navigator.pop(context);
              _navegarPara(context, const CampeonatosListView());
            },
          ),
          _buildDrawerItem(
            icon: Icons.bar_chart_rounded,
            label: 'Relatórios',
            onTap: () {
              Navigator.pop(context);
              _navegarPara(context, const RelatoriosView());
            },
          ),
          const Divider(),
          ListenableBuilder(
            listenable: themeProvider,
            builder: (context, _) => SwitchListTile(
              secondary: Icon(
                themeProvider.isDark
                    ? Icons.dark_mode_rounded
                    : Icons.light_mode_rounded,
                color: AppColors.primary,
              ),
              title: Text(
                'Modo escuro',
                style: GoogleFonts.inter(fontWeight: FontWeight.w600),
              ),
              value: themeProvider.isDark,
              onChanged: (_) => themeProvider.toggle(),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20),
            ),
          ),
          _buildDrawerItem(
            icon: Icons.info_outline_rounded,
            label: 'Sobre',
            onTap: () {
              Navigator.pop(context);
              _mostrarSobre(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(
        label,
        style: GoogleFonts.inter(
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
    );
  }

  void _mostrarSobre(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.sports_soccer_rounded,
                color: AppColors.primary,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            const Text('Sobre'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Fala, Torcedor!',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Aplicação para gerenciamento de equipes esportivas, planos de sócio-torcedor, torcedores, jogos, campeonatos e relatórios estatísticos.',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 14,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Processo Seletivo G4 Flex',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Desenvolvido com Flutter + Node.js + PostgreSQL',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 13,
              ),
            ),
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }
}

// ======================== COMPACT CARD (2-column grid) ========================

class _CompactCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final int? contador;
  final List<Color> gradient;
  final VoidCallback onTap;

  const _CompactCard({
    required this.icon,
    required this.title,
    this.contador,
    required this.gradient,
    required this.onTap,
  });

  @override
  State<_CompactCard> createState() => _CompactCardState();
}

class _CompactCardState extends State<_CompactCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          height: 120,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: cs.outlineVariant),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: widget.gradient,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(widget.icon, color: Colors.white, size: 20),
                  ),
                  const Spacer(),
                  if (widget.contador != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: widget.gradient[0].withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${widget.contador}',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: widget.gradient[0],
                        ),
                      ),
                    ),
                ],
              ),
              const Spacer(),
              Text(
                widget.title,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: cs.onSurface,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Text(
                    'Ver todos',
                    style: TextStyle(
                      fontSize: 11,
                      color: widget.gradient[0],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 2),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 11,
                    color: widget.gradient[0],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ======================== MENU CARD (full-width) ========================

class _MenuCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final int? contador;
  final List<Color> gradient;
  final VoidCallback onTap;
  final bool featured;

  const _MenuCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.contador,
    required this.gradient,
    required this.onTap,
    this.featured = false,
  });

  @override
  State<_MenuCard> createState() => _MenuCardState();
}

class _MenuCardState extends State<_MenuCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: widget.featured
              ? BoxDecoration(
                  gradient: LinearGradient(
                    colors: widget.gradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: widget.gradient[0].withValues(alpha: 0.35),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                )
              : BoxDecoration(
                  color: cs.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: cs.outlineVariant),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: widget.featured
                      ? Colors.white.withValues(alpha: 0.2)
                      : null,
                  gradient: widget.featured
                      ? null
                      : LinearGradient(
                          colors: widget.gradient,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(widget.icon, color: Colors.white, size: 26),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: widget.featured ? Colors.white : cs.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: widget.featured
                            ? Colors.white.withValues(alpha: 0.8)
                            : cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (widget.contador != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: widget.featured
                        ? Colors.white.withValues(alpha: 0.2)
                        : null,
                    gradient: widget.featured
                        ? null
                        : LinearGradient(
                            colors: widget.gradient,
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${widget.contador}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: widget.featured
                      ? Colors.white.withValues(alpha: 0.2)
                      : cs.outlineVariant,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.arrow_forward_rounded,
                  size: 18,
                  color: widget.featured ? Colors.white : cs.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

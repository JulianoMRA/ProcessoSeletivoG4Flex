import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fala_torcedor/core/colors.dart';
import 'package:fala_torcedor/main.dart';
import 'package:fala_torcedor/services/api_service.dart';
import 'package:fala_torcedor/views/equipes/equipes_list_view.dart';
import 'package:fala_torcedor/views/jogos/jogos_list_view.dart';
import 'package:fala_torcedor/views/planos/planos_list_view.dart';
import 'package:fala_torcedor/views/torcedores/torcedores_list_view.dart';
import 'package:fala_torcedor/views/campeonatos/campeonatos_list_view.dart';

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
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 40),
                    _buildHeader(ctx),
                    const Spacer(),
                    _buildMenuCards(context),
                    const Spacer(flex: 2),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

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
                const Text(
                  'Fala, Torcedor!',
                  style: TextStyle(
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
              title: const Text(
                'Modo escuro',
                style: TextStyle(fontWeight: FontWeight.w600),
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
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
    );
  }

  void _navegarPara(BuildContext context, Widget pagina) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => pagina));
    _carregarContadores();
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
            const Text('Sobre', style: TextStyle(fontWeight: FontWeight.w700)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Fala, Torcedor!',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Aplicação CRUD para gerenciamento de equipes esportivas, planos de sócio-torcedor, torcedores e jogos.',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 14,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Processo Seletivo G4 Flex',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
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

  Widget _buildHeader(BuildContext ctx) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
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
            const Spacer(),
          ],
        ),
        const SizedBox(height: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${_saudacao()}!',
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(ctx).colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Fala, Torcedor!',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: Theme.of(ctx).colorScheme.onSurface,
                letterSpacing: -1,
                height: 1.1,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Gerencie equipes, planos, torcedores, jogos e campeonatos',
          style: TextStyle(
            fontSize: 16,
            color: Theme.of(ctx).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuCards(BuildContext context) {
    return Column(
      children: [
        _MenuCard(
          icon: Icons.shield_rounded,
          title: 'Equipes',
          subtitle: 'Cadastrar e gerenciar equipes',
          contador: _contadores['equipes'],
          gradient: [AppColors.primary, AppColors.primaryLight],
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const EquipesListView()),
            );
            _carregarContadores();
          },
        ),
        const SizedBox(height: 16),
        _MenuCard(
          icon: Icons.people_rounded,
          title: 'Torcedores',
          subtitle: 'Cadastrar e gerenciar torcedores',
          contador: _contadores['torcedores'],
          gradient: [AppColors.secondary, AppColors.secondaryLight],
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TorcedoresListView()),
            );
            _carregarContadores();
          },
        ),
        const SizedBox(height: 16),
        _MenuCard(
          icon: Icons.card_membership_rounded,
          title: 'Planos',
          subtitle: 'Gerenciar planos de sócio',
          contador: _contadores['planos'],
          gradient: [AppColors.accent, AppColors.accentLight],
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PlanosListView()),
            );
            _carregarContadores();
          },
        ),
        const SizedBox(height: 16),
        _MenuCard(
          icon: Icons.sports_score_rounded,
          title: 'Jogos',
          subtitle: 'Registrar e consultar jogos',
          contador: _contadores['jogos'],
          gradient: [AppColors.jogos, AppColors.jogosLight],
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const JogosListView()),
            );
            _carregarContadores();
          },
        ),
        const SizedBox(height: 16),
        _MenuCard(
          icon: Icons.emoji_events_rounded,
          title: 'Campeonatos',
          subtitle: 'Criar e gerenciar campeonatos',
          contador: _contadores['campeonatos'],
          gradient: [AppColors.campeonatos, AppColors.campeonatosLight],
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CampeonatosListView()),
            );
            _carregarContadores();
          },
        ),
      ],
    );
  }
}

class _MenuCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final int? contador;
  final List<Color> gradient;
  final VoidCallback onTap;

  const _MenuCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.contador,
    required this.gradient,
    required this.onTap,
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
          decoration: BoxDecoration(
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
                  gradient: LinearGradient(
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
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: cs.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: cs.onSurfaceVariant,
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
                    gradient: LinearGradient(
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
                  color: cs.outlineVariant,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.arrow_forward_rounded,
                  size: 18,
                  color: cs.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

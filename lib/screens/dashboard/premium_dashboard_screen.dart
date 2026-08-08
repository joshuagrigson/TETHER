import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/tether_theme.dart';
import '../../models/person.dart';
import '../../providers/relationship_provider.dart';
import '../../services/relationship_attention_service.dart';
import '../relationship/add_relationship_screen.dart';
import '../relationship/relationship_detail_screen.dart';

class PremiumDashboardScreen extends StatefulWidget {
  const PremiumDashboardScreen({super.key});

  @override
  State<PremiumDashboardScreen> createState() => _PremiumDashboardScreenState();
}

class _PremiumDashboardScreenState extends State<PremiumDashboardScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ambient;
  int _tab = 0;

  @override
  void initState() {
    super.initState();
    _ambient = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
  }

  @override
  void dispose() {
    _ambient.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RelationshipProvider>();
    final people = provider.people;

    return Scaffold(
      backgroundColor: TetherColors.obsidian,
      body: Stack(
        children: [
          Positioned.fill(child: _AmbientBackground(animation: _ambient)),
          SafeArea(
            child: IndexedStack(
              index: _tab,
              children: [
                _DashboardBody(people: people, loading: provider.isLoading),
                _PeopleBody(people: people),
                const _ReminderBody(),
                const _ProfileBody(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _BottomNav(
        selected: _tab,
        onSelected: (value) => setState(() => _tab = value),
        onAdd: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const AddRelationshipScreen()),
        ),
      ),
    );
  }
}

class _AmbientBackground extends StatelessWidget {
  const _AmbientBackground({required this.animation});
  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) => CustomPaint(
        painter: _AmbientPainter(animation.value),
      ),
    );
  }
}

class _AmbientPainter extends CustomPainter {
  const _AmbientPainter(this.t);
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final p = Paint();
    final x = math.sin(t * math.pi * 2) * .12;
    final y = math.cos(t * math.pi * 2) * .08;
    p.shader = RadialGradient(
      center: Alignment(-.55 + x, -.9 + y),
      radius: .85,
      colors: [TetherColors.violet.withValues(alpha: .12), Colors.transparent],
    ).createShader(rect);
    canvas.drawRect(rect, p);
    p.shader = RadialGradient(
      center: Alignment(.85 - x, -.25),
      radius: .7,
      colors: [TetherColors.neon.withValues(alpha: .07), Colors.transparent],
    ).createShader(rect);
    canvas.drawRect(rect, p);
  }

  @override
  bool shouldRepaint(covariant _AmbientPainter oldDelegate) => oldDelegate.t != t;
}

class _DashboardBody extends StatelessWidget {
  const _DashboardBody({required this.people, required this.loading});
  final List<Person> people;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    if (loading) return const Center(child: CircularProgressIndicator());
    final attention = const RelationshipAttentionService().prioritize(people, limit: 3);
    final average = people.isEmpty
        ? 0
        : (people.fold<int>(0, (sum, p) => sum + p.bondXp) / people.length / 10)
            .round()
            .clamp(0, 100);
    final strong = people.where((p) => p.state == BondState.strong || p.state == BondState.thriving).length;
    final needs = people.where((p) => p.state == BondState.needsAttention).length;

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
          sliver: SliverToBoxAdapter(child: _TopBar(peopleCount: people.length)),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 18),
          sliver: SliverToBoxAdapter(
            child: _HealthHero(health: average, strong: strong, needs: needs, total: people.length),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
          sliver: SliverToBoxAdapter(child: _SectionTitle(title: 'PEOPLE TO REACH TODAY', action: 'VIEW ALL')),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverToBoxAdapter(
            child: Column(
              children: attention.isEmpty
                  ? [const _EmptyPriority()]
                  : attention.map((person) => Padding(
                        padding: const EdgeInsets.only(bottom: 9),
                        child: _PriorityCard(person: person),
                      )).toList(),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 15, 20, 10),
          sliver: SliverToBoxAdapter(child: _SectionTitle(title: 'RECENT INTERACTIONS', action: 'VIEW ALL')),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverList.builder(
            itemCount: math.min(people.length, 4),
            itemBuilder: (context, index) => Padding(
              padding: const EdgeInsets.only(bottom: 9),
              child: _RecentCard(person: people[index]),
            ),
          ),
        ),
        const SliverPadding(padding: EdgeInsets.only(bottom: 24)),
      ],
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.peopleCount});
  final int peopleCount;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: TetherColors.violet.withValues(alpha: .8)),
              boxShadow: [BoxShadow(color: TetherColors.violet.withValues(alpha: .2), blurRadius: 18)],
            ),
            child: const Icon(Icons.all_inclusive_rounded, color: TetherColors.violet, size: 23),
          ),
          const SizedBox(width: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('TETHER', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: 3)),
              Text('STRONGER BONDS. BETTER YOU.', style: TextStyle(fontSize: 7, color: TetherColors.neon, letterSpacing: 1.3, fontWeight: FontWeight.w800)),
            ],
          ),
          const Spacer(),
          _IconButton(icon: Icons.search_rounded),
          const SizedBox(width: 8),
          _IconButton(icon: Icons.notifications_none_rounded),
        ],
      );
}

class _IconButton extends StatelessWidget {
  const _IconButton({required this.icon});
  final IconData icon;
  @override
  Widget build(BuildContext context) => Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(color: TetherColors.surface.withValues(alpha: .8), borderRadius: BorderRadius.circular(14), border: Border.all(color: TetherColors.line)),
        child: Icon(icon, size: 19, color: TetherColors.text),
      );
}

class _HealthHero extends StatelessWidget {
  const _HealthHero({required this.health, required this.strong, required this.needs, required this.total});
  final int health;
  final int strong;
  final int needs;
  final int total;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: TetherColors.line),
          gradient: LinearGradient(colors: [TetherColors.surfaceRaised.withValues(alpha: .94), TetherColors.surface.withValues(alpha: .82)]),
        ),
        child: Row(
          children: [
            _HealthRing(value: health),
            const SizedBox(width: 17),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('YOUR RELATIONSHIPS AT A GLANCE', style: TextStyle(fontSize: 8, color: TetherColors.muted, letterSpacing: 1.4, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 7),
                  Text(health >= 80 ? 'Your circle is strong.' : 'A few bonds need attention.', style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 12),
                  Row(children: [
                    _Metric(value: '$strong', label: 'STRONG'),
                    const SizedBox(width: 18),
                    _Metric(value: '$needs', label: 'ATTENTION'),
                    const SizedBox(width: 18),
                    _Metric(value: '$total', label: 'PEOPLE'),
                  ]),
                ],
              ),
            ),
          ],
        ),
      );
}

class _HealthRing extends StatelessWidget {
  const _HealthRing({required this.value});
  final int value;
  @override
  Widget build(BuildContext context) => SizedBox(
        width: 102,
        height: 102,
        child: Stack(alignment: Alignment.center, children: [
          SizedBox(
            width: 96,
            height: 96,
            child: CircularProgressIndicator(value: value / 100, strokeWidth: 6, backgroundColor: TetherColors.line, valueColor: const AlwaysStoppedAnimation(TetherColors.neon)),
          ),
          Column(mainAxisSize: MainAxisSize.min, children: [
            Text('$value', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
            const Text('OVERALL HEALTH', style: TextStyle(fontSize: 6, color: TetherColors.muted, letterSpacing: .9)),
          ]),
        ]),
      );
}

class _Metric extends StatelessWidget {
  const _Metric({required this.value, required this.label});
  final String value;
  final String label;
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900)),
        Text(label, style: const TextStyle(fontSize: 6.5, color: TetherColors.muted, letterSpacing: 1, fontWeight: FontWeight.w800)),
      ]);
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.action});
  final String title;
  final String action;
  @override
  Widget build(BuildContext context) => Row(children: [
        Expanded(child: Text(title, style: const TextStyle(fontSize: 9, letterSpacing: 1.7, fontWeight: FontWeight.w900))),
        Text(action, style: const TextStyle(fontSize: 8, color: TetherColors.violet, letterSpacing: .8, fontWeight: FontWeight.w800)),
      ]);
}

class _PriorityCard extends StatelessWidget {
  const _PriorityCard({required this.person});
  final Person person;
  @override
  Widget build(BuildContext context) {
    final urgent = person.state == BondState.needsAttention;
    return _TapCard(
      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => RelationshipDetailScreen(personId: person.id))),
      child: Row(children: [
        _Avatar(person: person, accent: urgent ? TetherColors.danger : TetherColors.neon),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [Expanded(child: Text(person.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13))), _PriorityPill(urgent: urgent)]),
          const SizedBox(height: 4),
          Text(person.tags.isEmpty ? 'Important person' : person.tags.first, style: const TextStyle(color: TetherColors.muted, fontSize: 10)),
          const SizedBox(height: 3),
          Text(urgent ? 'Bond needs attention' : 'Keep the connection alive', style: TextStyle(color: urgent ? TetherColors.danger : TetherColors.muted, fontSize: 9)),
        ])),
        const Icon(Icons.chevron_right_rounded, color: TetherColors.muted),
      ]),
    );
  }
}

class _PriorityPill extends StatelessWidget {
  const _PriorityPill({required this.urgent});
  final bool urgent;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(color: (urgent ? TetherColors.danger : TetherColors.violet).withValues(alpha: .1), borderRadius: BorderRadius.circular(20), border: Border.all(color: (urgent ? TetherColors.danger : TetherColors.violet).withValues(alpha: .35))),
        child: Text(urgent ? 'HIGH PRIORITY' : 'TODAY', style: TextStyle(fontSize: 6.5, color: urgent ? TetherColors.danger : TetherColors.violet, fontWeight: FontWeight.w900, letterSpacing: .7)),
      );
}

class _RecentCard extends StatelessWidget {
  const _RecentCard({required this.person});
  final Person person;
  @override
  Widget build(BuildContext context) => _TapCard(
        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => RelationshipDetailScreen(personId: person.id))),
        child: Row(children: [
          _Avatar(person: person, accent: TetherColors.violet),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(person.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
            const SizedBox(height: 3),
            Text('${person.recentInteractions} recent interactions · Bond XP ${person.bondXp}', style: const TextStyle(color: TetherColors.muted, fontSize: 9)),
          ])),
          Text('+${person.recentInteractions * 3} XP', style: const TextStyle(color: TetherColors.neon, fontSize: 9, fontWeight: FontWeight.w800)),
        ]),
      );
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.person, required this.accent});
  final Person person;
  final Color accent;
  @override
  Widget build(BuildContext context) => Container(
        width: 42,
        height: 42,
        alignment: Alignment.center,
        decoration: BoxDecoration(shape: BoxShape.circle, gradient: LinearGradient(colors: [accent.withValues(alpha: .9), TetherColors.violet.withValues(alpha: .75)]), border: Border.all(color: accent, width: 1.5), boxShadow: [BoxShadow(color: accent.withValues(alpha: .15), blurRadius: 12)]),
        child: Text(person.initials, style: const TextStyle(fontWeight: FontWeight.w900)),
      );
}

class _TapCard extends StatelessWidget {
  const _TapCard({required this.child, required this.onTap});
  final Widget child;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Material(
        color: TetherColors.surface.withValues(alpha: .86),
        borderRadius: BorderRadius.circular(18),
        child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(18), child: Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(borderRadius: BorderRadius.circular(18), border: Border.all(color: TetherColors.line.withValues(alpha: .85)))),
      );
}

class _EmptyPriority extends StatelessWidget {
  const _EmptyPriority();
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: TetherColors.surface.withValues(alpha: .7), borderRadius: BorderRadius.circular(18), border: Border.all(color: TetherColors.line)), child: const Row(children: [Icon(Icons.auto_awesome_rounded, color: TetherColors.neon), SizedBox(width: 12), Expanded(child: Text('You are caught up. TETHER will surface the next meaningful connection.', style: TextStyle(color: TetherColors.muted, fontSize: 11)))]));
}

class _PeopleBody extends StatelessWidget {
  const _PeopleBody({required this.people});
  final List<Person> people;
  @override
  Widget build(BuildContext context) => ListView(padding: const EdgeInsets.fromLTRB(20, 22, 20, 30), children: [const Text('PEOPLE', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: 2)), const SizedBox(height: 6), const Text('Everyone in your circle.', style: TextStyle(color: TetherColors.muted)), const SizedBox(height: 20), ...people.map((p) => Padding(padding: const EdgeInsets.only(bottom: 10), child: _PriorityCard(person: p))) ]);
}

class _ReminderBody extends StatelessWidget {
  const _ReminderBody();
  @override
  Widget build(BuildContext context) => const Center(child: Padding(padding: EdgeInsets.all(30), child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.notifications_active_outlined, color: TetherColors.violet, size: 42), SizedBox(height: 14), Text('SMART REMINDERS', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: 1.4)), SizedBox(height: 7), Text('TETHER will turn relationship cadence and context into timely reminders.', textAlign: TextAlign.center, style: TextStyle(color: TetherColors.muted))])));
}

class _ProfileBody extends StatelessWidget {
  const _ProfileBody();
  @override
  Widget build(BuildContext context) => const Center(child: Padding(padding: EdgeInsets.all(30), child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.person_outline_rounded, color: TetherColors.neon, size: 42), SizedBox(height: 14), Text('YOUR TETHER PROFILE', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: 1.4)), SizedBox(height: 7), Text('Profile preferences and intelligence controls will live here.', textAlign: TextAlign.center, style: TextStyle(color: TetherColors.muted))])));
}

class _BottomNav extends StatelessWidget {
  const _BottomNav({required this.selected, required this.onSelected, required this.onAdd});
  final int selected;
  final ValueChanged<int> onSelected;
  final VoidCallback onAdd;
  @override
  Widget build(BuildContext context) => BottomAppBar(
        color: TetherColors.obsidian.withValues(alpha: .97),
        elevation: 0,
        height: 76,
        child: Row(children: [
          _NavItem(icon: Icons.grid_view_rounded, label: 'Dashboard', selected: selected == 0, onTap: () => onSelected(0)),
          _NavItem(icon: Icons.people_outline_rounded, label: 'People', selected: selected == 1, onTap: () => onSelected(1)),
          Expanded(child: Center(child: GestureDetector(onTap: onAdd, child: Container(width: 56, height: 56, decoration: BoxDecoration(shape: BoxShape.circle, gradient: const LinearGradient(colors: [TetherColors.violet, TetherColors.neon]), boxShadow: [BoxShadow(color: TetherColors.violet.withValues(alpha: .28), blurRadius: 20)]), child: const Icon(Icons.add_rounded, color: TetherColors.obsidian, size: 30))))),
          _NavItem(icon: Icons.notifications_none_rounded, label: 'Reminders', selected: selected == 2, onTap: () => onSelected(2)),
          _NavItem(icon: Icons.person_outline_rounded, label: 'Profile', selected: selected == 3, onTap: () => onSelected(3)),
        ]),
      );
}

class _NavItem extends StatelessWidget {
  const _NavItem({required this.icon, required this.label, required this.selected, required this.onTap});
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Expanded(child: InkWell(onTap: onTap, child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, size: 20, color: selected ? TetherColors.violet : TetherColors.muted), const SizedBox(height: 4), Text(label, style: TextStyle(fontSize: 7, color: selected ? TetherColors.violet : TetherColors.muted, fontWeight: selected ? FontWeight.w800 : FontWeight.w500))])));
}

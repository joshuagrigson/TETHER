import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/tether_theme.dart';
import '../../models/person.dart';
import '../../providers/relationship_provider.dart';
import '../../services/relationship_attention_service.dart';
import '../relationship/add_relationship_screen.dart';
import '../relationship/relationship_detail_screen.dart';

class NorthStarDashboardScreen extends StatefulWidget {
  const NorthStarDashboardScreen({super.key});

  @override
  State<NorthStarDashboardScreen> createState() => _NorthStarDashboardScreenState();
}

class _NorthStarDashboardScreenState extends State<NorthStarDashboardScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;
  int _tab = 0;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(vsync: this, duration: const Duration(seconds: 5))..repeat();
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  void _openAdd() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const AddRelationshipScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RelationshipProvider>();
    return Scaffold(
      backgroundColor: TetherColors.obsidian,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Positioned.fill(child: _NeonBackdrop(animation: _pulse)),
            IndexedStack(
              index: _tab,
              children: [
                _HomeView(people: provider.people, loading: provider.isLoading, animation: _pulse),
                _PeopleView(people: provider.people),
                const _PlaceholderView(title: 'REMINDERS', icon: Icons.notifications_none_rounded),
                const _PlaceholderView(title: 'PROFILE', icon: Icons.person_outline_rounded),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: _NorthStarNav(
        selected: _tab,
        onSelected: (index) => setState(() => _tab = index),
        onAdd: _openAdd,
      ),
    );
  }
}

class _NeonBackdrop extends StatelessWidget {
  const _NeonBackdrop({required this.animation});
  final Animation<double> animation;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: animation,
        builder: (_, __) => CustomPaint(painter: _BackdropPainter(animation.value)),
      );
}

class _BackdropPainter extends CustomPainter {
  const _BackdropPainter(this.t);
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final paint = Paint();
    final drift = math.sin(t * math.pi * 2) * .04;
    paint.shader = RadialGradient(
      center: Alignment(-.65 + drift, -.9),
      radius: .95,
      colors: [
        TetherColors.violet.withValues(alpha: .18),
        TetherColors.violet.withValues(alpha: .03),
        Colors.transparent,
      ],
    ).createShader(rect);
    canvas.drawRect(rect, paint);
    paint.shader = RadialGradient(
      center: Alignment(.8 - drift, .15),
      radius: .75,
      colors: [TetherColors.neon.withValues(alpha: .055), Colors.transparent],
    ).createShader(rect);
    canvas.drawRect(rect, paint);
  }

  @override
  bool shouldRepaint(covariant _BackdropPainter oldDelegate) => oldDelegate.t != t;
}

class _HomeView extends StatelessWidget {
  const _HomeView({required this.people, required this.loading, required this.animation});
  final List<Person> people;
  final bool loading;
  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    if (loading) return const Center(child: CircularProgressIndicator());

    final intelligence = const RelationshipAttentionService().prioritizeWithIntelligence(people, limit: 3);
    final health = _overallHealth(people);
    final strong = people.where((p) => p.state == BondState.strong || p.state == BondState.thriving).length;
    final attention = people.where((p) => p.state == BondState.needsAttention).length;

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 0),
          sliver: SliverToBoxAdapter(child: _Header()),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
          sliver: SliverToBoxAdapter(
            child: _HealthHero(health: health, strong: strong, attention: attention, people: people.length, animation: animation),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          sliver: SliverToBoxAdapter(
            child: _SectionHeader(title: 'PEOPLE TO REACH TODAY', action: 'VIEW ALL'),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 4),
          sliver: SliverToBoxAdapter(
            child: intelligence.isEmpty
                ? const _EmptyState()
                : Column(
                    children: intelligence.map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _IntelligenceCard(item: item),
                    )).toList(),
                  ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 8),
          sliver: SliverToBoxAdapter(child: _SectionHeader(title: 'RECENT ACTIVITY', action: 'VIEW ALL')),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          sliver: SliverList.builder(
            itemCount: math.min(4, people.length),
            itemBuilder: (_, index) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _ActivityCard(person: people[index]),
            ),
          ),
        ),
        const SliverPadding(padding: EdgeInsets.only(bottom: 30)),
      ],
    );
  }

  int _overallHealth(List<Person> people) {
    if (people.isEmpty) return 0;
    final total = people.fold<int>(0, (sum, person) {
      final stateScore = switch (person.state) {
        BondState.thriving => 95,
        BondState.strong => 82,
        BondState.steady => 65,
        BondState.needsAttention => 38,
      };
      return sum + stateScore;
    });
    return (total / people.length).round();
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: TetherColors.violet, width: 1.2),
              boxShadow: [BoxShadow(color: TetherColors.violet.withValues(alpha: .3), blurRadius: 18)],
              gradient: LinearGradient(
                colors: [TetherColors.violet.withValues(alpha: .22), Colors.transparent],
              ),
            ),
            child: const Icon(Icons.all_inclusive_rounded, color: TetherColors.violet, size: 21),
          ),
          const SizedBox(width: 11),
          const Text(
            'T E T H E R',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: 2.7),
          ),
          const Spacer(),
          _CircleIcon(icon: Icons.notifications_none_rounded),
        ],
      );
}

class _CircleIcon extends StatelessWidget {
  const _CircleIcon({required this.icon});
  final IconData icon;

  @override
  Widget build(BuildContext context) => Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: TetherColors.surface.withValues(alpha: .72),
          border: Border.all(color: TetherColors.line),
        ),
        child: Icon(icon, color: TetherColors.text, size: 19),
      );
}

class _HealthHero extends StatelessWidget {
  const _HealthHero({required this.health, required this.strong, required this.attention, required this.people, required this.animation});
  final int health;
  final int strong;
  final int attention;
  final int people;
  final Animation<double> animation;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: TetherColors.violet.withValues(alpha: .22)),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF11101B).withValues(alpha: .97),
              TetherColors.surface.withValues(alpha: .92),
            ],
          ),
          boxShadow: [BoxShadow(color: TetherColors.violet.withValues(alpha: .08), blurRadius: 28)],
        ),
        child: Column(
          children: [
            const Align(
              alignment: Alignment.center,
              child: Text('OVERALL HEALTH', style: TextStyle(fontSize: 8, letterSpacing: 2, color: TetherColors.muted, fontWeight: FontWeight.w800)),
            ),
            const SizedBox(height: 10),
            _OrbitalHealth(value: health, animation: animation),
            const SizedBox(height: 14),
            Row(
              children: [
                _StatTile(value: '$strong', label: 'STRONG', accent: TetherColors.neon),
                const SizedBox(width: 8),
                _StatTile(value: '$attention', label: 'ATTENTION', accent: TetherColors.violet),
                const SizedBox(width: 8),
                _StatTile(value: '$people', label: 'PEOPLE', accent: TetherColors.text),
              ],
            ),
          ],
        ),
      );
}

class _OrbitalHealth extends StatelessWidget {
  const _OrbitalHealth({required this.value, required this.animation});
  final int value;
  final Animation<double> animation;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: 182,
        height: 182,
        child: AnimatedBuilder(
          animation: animation,
          builder: (_, __) => CustomPaint(
            painter: _OrbitalPainter(value: value, phase: animation.value),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('$value', style: const TextStyle(fontSize: 46, fontWeight: FontWeight.w300, letterSpacing: -2)),
                  Text(_healthLabel(value), style: const TextStyle(color: TetherColors.neon, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.1)),
                ],
              ),
            ),
          ),
        ),
      );

  String _healthLabel(int value) => value >= 80 ? 'STRONG' : value >= 60 ? 'STEADY' : 'ATTENTION';
}

class _OrbitalPainter extends CustomPainter {
  const _OrbitalPainter({required this.value, required this.phase});
  final int value;
  final double phase;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width * .38;
    final progress = (value.clamp(0, 100)) / 100;
    final glow = Paint()..style = PaintingStyle.stroke..strokeWidth = 13..color = TetherColors.violet.withValues(alpha: .08);
    canvas.drawCircle(center, radius, glow);

    final base = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.2
      ..strokeCap = StrokeCap.round
      ..color = TetherColors.line;
    canvas.drawCircle(center, radius, base);

    final arc = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        colors: const [TetherColors.violet, TetherColors.neon, TetherColors.violet],
        stops: const [0, .55, 1],
        transform: GradientRotation(phase * math.pi * 2),
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), -math.pi / 2, math.pi * 2 * progress, false, arc);

    final orbit = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = TetherColors.violet.withValues(alpha: .2);
    canvas.drawCircle(center, radius + 13, orbit);
    canvas.drawCircle(center, radius + 20, orbit..color = TetherColors.neon.withValues(alpha: .07));
  }

  @override
  bool shouldRepaint(covariant _OrbitalPainter oldDelegate) => oldDelegate.value != value || oldDelegate.phase != phase;
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.value, required this.label, required this.accent});
  final String value;
  final String label;
  final Color accent;

  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 11),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: .2),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: TetherColors.line.withValues(alpha: .7)),
          ),
          child: Column(
            children: [
              Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: accent)),
              const SizedBox(height: 3),
              Text(label, style: const TextStyle(fontSize: 6.5, letterSpacing: 1.1, color: TetherColors.muted, fontWeight: FontWeight.w800)),
            ],
          ),
        ),
      );
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.action});
  final String title;
  final String action;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Expanded(child: Text(title, style: const TextStyle(fontSize: 9, letterSpacing: 1.7, fontWeight: FontWeight.w900))),
          Text(action, style: const TextStyle(fontSize: 8, letterSpacing: .8, color: TetherColors.violet, fontWeight: FontWeight.w800)),
        ],
      );
}

class _IntelligenceCard extends StatelessWidget {
  const _IntelligenceCard({required this.item});
  final RelationshipPriority item;

  @override
  Widget build(BuildContext context) {
    final person = item.person;
    final urgent = item.score >= 100 || person.state == BondState.needsAttention;
    final accent = urgent ? TetherColors.danger : TetherColors.violet;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => RelationshipDetailScreen(personId: person.id))),
        borderRadius: BorderRadius.circular(21),
        child: Container(
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(21),
            color: TetherColors.surface.withValues(alpha: .88),
            border: Border.all(color: accent.withValues(alpha: .18)),
            boxShadow: [BoxShadow(color: accent.withValues(alpha: .04), blurRadius: 18)],
          ),
          child: Row(
            children: [
              _Avatar(person: person, accent: accent),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(child: Text(person.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800))),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: accent.withValues(alpha: .09),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: accent.withValues(alpha: .28)),
                          ),
                          child: Text(item.headline, style: TextStyle(fontSize: 6, color: accent, letterSpacing: .65, fontWeight: FontWeight.w900)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(person.tags.isEmpty ? _relationshipLabel(person) : person.tags.first, style: const TextStyle(color: TetherColors.muted, fontSize: 9)),
                    const SizedBox(height: 3),
                    Text(item.detail, style: TextStyle(color: accent, fontSize: 9, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 2),
                    Text(item.action, style: const TextStyle(color: TetherColors.muted, fontSize: 8)),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right_rounded, color: TetherColors.muted, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  String _relationshipLabel(Person person) => switch (person.cadence) {
        Cadence.daily => 'Daily connection',
        Cadence.weekly => 'Close connection',
        Cadence.occasional => 'Meaningful connection',
      };
}

class _ActivityCard extends StatelessWidget {
  const _ActivityCard({required this.person});
  final Person person;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
        decoration: BoxDecoration(
          color: TetherColors.surface.withValues(alpha: .72),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: TetherColors.line.withValues(alpha: .7)),
        ),
        child: Row(
          children: [
            _Avatar(person: person, accent: TetherColors.violet),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(person.name, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 3),
                  Text('${person.recentInteractions} recent interactions', style: const TextStyle(fontSize: 8.5, color: TetherColors.muted)),
                ],
              ),
            ),
            Text('+${person.recentInteractions * 3} XP', style: const TextStyle(color: TetherColors.neon, fontSize: 8.5, fontWeight: FontWeight.w800)),
          ],
        ),
      );
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.person, required this.accent});
  final Person person;
  final Color accent;

  @override
  Widget build(BuildContext context) => Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: [accent.withValues(alpha: .7), TetherColors.midnight]),
          border: Border.all(color: accent.withValues(alpha: .9), width: 1.4),
          boxShadow: [BoxShadow(color: accent.withValues(alpha: .18), blurRadius: 13)],
        ),
        alignment: Alignment.center,
        child: Text(person.initials, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12)),
      );
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: TetherColors.surface.withValues(alpha: .72),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: TetherColors.line),
        ),
        child: const Row(
          children: [
            Icon(Icons.auto_awesome_rounded, color: TetherColors.neon),
            SizedBox(width: 12),
            Expanded(child: Text('You are caught up. TETHER will surface the next meaningful connection.', style: TextStyle(color: TetherColors.muted, fontSize: 10))),
          ],
        ),
      );
}

class _PeopleView extends StatefulWidget {
  const _PeopleView({required this.people});
  final List<Person> people;
  @override
  State<_PeopleView> createState() => _PeopleViewState();
}

class _PeopleViewState extends State<_PeopleView> {
  final _search = TextEditingController();
  String _filter = 'ALL';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<Person> get _people {
    final query = _search.text.trim().toLowerCase();
    return widget.people.where((person) {
      final matchesQuery = query.isEmpty || person.name.toLowerCase().contains(query) || person.tags.any((tag) => tag.toLowerCase().contains(query));
      final matchesFilter = switch (_filter) {
        'ATTENTION' => person.state == BondState.needsAttention,
        'THRIVING' => person.state == BondState.thriving,
        'RECENT' => person.lastInteractionAt != null,
        _ => true,
      };
      return matchesQuery && matchesFilter;
    }).toList();
  }

  @override
  Widget build(BuildContext context) => CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverPadding(padding: const EdgeInsets.fromLTRB(18, 16, 18, 12), sliver: SliverToBoxAdapter(child: _PeopleHeader(total: widget.people.length))),
          SliverPadding(padding: const EdgeInsets.symmetric(horizontal: 18), sliver: SliverToBoxAdapter(child: TextField(
            controller: _search,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Search people or tags...',
              prefixIcon: const Icon(Icons.search_rounded, size: 18),
              filled: true,
              fillColor: TetherColors.surface.withValues(alpha: .9),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: TetherColors.line)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: TetherColors.line)),
            ),
          ))),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 10),
            sliver: SliverToBoxAdapter(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(children: ['ALL', 'ATTENTION', 'THRIVING', 'RECENT'].map((filter) {
                  final active = _filter == filter;
                  return Padding(
                    padding: const EdgeInsets.only(right: 7),
                    child: GestureDetector(
                      onTap: () => setState(() => _filter = filter),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
                        decoration: BoxDecoration(
                          color: active ? TetherColors.violet.withValues(alpha: .15) : TetherColors.surface.withValues(alpha: .7),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: active ? TetherColors.violet.withValues(alpha: .55) : TetherColors.line),
                        ),
                        child: Text(filter, style: TextStyle(fontSize: 7, fontWeight: FontWeight.w900, color: active ? TetherColors.violet : TetherColors.muted, letterSpacing: .7)),
                      ),
                    ),
                  );
                }).toList()),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(18, 2, 18, 8),
            sliver: SliverToBoxAdapter(child: Text('YOUR CIRCLE  ·  ${_people.length}', style: const TextStyle(fontSize: 8, letterSpacing: 1.5, color: TetherColors.muted, fontWeight: FontWeight.w800))),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            sliver: SliverList.builder(
              itemCount: _people.length,
              itemBuilder: (_, index) => Padding(padding: const EdgeInsets.only(bottom: 9), child: _PersonCard(person: _people[index])),
            ),
          ),
          const SliverPadding(padding: EdgeInsets.only(bottom: 30)),
        ],
      );
}

class _PeopleHeader extends StatelessWidget {
  const _PeopleHeader({required this.total});
  final int total;
  @override
  Widget build(BuildContext context) => Row(
        children: [
          const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('PEOPLE', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: 1.8)), SizedBox(height: 4), Text('Your circle, intentionally connected.', style: TextStyle(color: TetherColors.muted, fontSize: 10))])),
          Text('$total', style: const TextStyle(fontSize: 28, color: TetherColors.violet, fontWeight: FontWeight.w300)),
        ],
      );
}

class _PersonCard extends StatelessWidget {
  const _PersonCard({required this.person});
  final Person person;
  @override
  Widget build(BuildContext context) {
    final color = person.state == BondState.needsAttention ? TetherColors.danger : TetherColors.neon;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => RelationshipDetailScreen(personId: person.id))),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: TetherColors.surface.withValues(alpha: .82), borderRadius: BorderRadius.circular(20), border: Border.all(color: TetherColors.line)),
          child: Row(children: [
            _Avatar(person: person, accent: color),
            const SizedBox(width: 11),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(person.name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
              const SizedBox(height: 3),
              Text(person.tags.isEmpty ? 'Relationship' : person.tags.first, style: const TextStyle(fontSize: 9, color: TetherColors.muted)),
              const SizedBox(height: 3),
              Text('${person.recentInteractions} interactions  ·  ${person.bondXp} XP', style: const TextStyle(fontSize: 8, color: TetherColors.muted)),
            ])),
            _HealthBadge(person: person, color: color),
          ]),
        ),
      ),
    );
  }
}

class _HealthBadge extends StatelessWidget {
  const _HealthBadge({required this.person, required this.color});
  final Person person;
  final Color color;
  @override
  Widget build(BuildContext context) {
    final value = switch (person.state) { BondState.thriving => 92, BondState.strong => 82, BondState.steady => 65, BondState.needsAttention => 38 };
    return SizedBox(width: 50, height: 50, child: Stack(alignment: Alignment.center, children: [
      CircularProgressIndicator(value: value / 100, strokeWidth: 3, backgroundColor: TetherColors.line, valueColor: AlwaysStoppedAnimation(color)),
      Text('$value', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900)),
    ]));
  }
}

class _PlaceholderView extends StatelessWidget {
  const _PlaceholderView({required this.title, required this.icon});
  final String title;
  final IconData icon;
  @override
  Widget build(BuildContext context) => Center(child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(icon, color: TetherColors.violet, size: 42), const SizedBox(height: 12), Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 2)), const SizedBox(height: 5), const Text('This module is coming next.', style: TextStyle(color: TetherColors.muted, fontSize: 10))]));
}

class _NorthStarNav extends StatelessWidget {
  const _NorthStarNav({required this.selected, required this.onSelected, required this.onAdd});
  final int selected;
  final ValueChanged<int> onSelected;
  final VoidCallback onAdd;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 14),
        decoration: BoxDecoration(
          color: const Color(0xFF080A10).withValues(alpha: .97),
          border: Border(top: BorderSide(color: TetherColors.line.withValues(alpha: .65))),
        ),
        child: Row(children: [
          _NavItem(icon: Icons.grid_view_rounded, label: 'Dashboard', active: selected == 0, onTap: () => onSelected(0)),
          _NavItem(icon: Icons.people_outline_rounded, label: 'People', active: selected == 1, onTap: () => onSelected(1)),
          Expanded(child: Center(child: GestureDetector(onTap: onAdd, child: Container(width: 52, height: 52, decoration: BoxDecoration(shape: BoxShape.circle, gradient: const LinearGradient(colors: [TetherColors.violet, Color(0xFF5B2BFF)]), boxShadow: [BoxShadow(color: TetherColors.violet.withValues(alpha: .45), blurRadius: 22)]), child: const Icon(Icons.add_rounded, size: 28))))),
          _NavItem(icon: Icons.notifications_none_rounded, label: 'Reminders', active: selected == 2, onTap: () => onSelected(2)),
          _NavItem(icon: Icons.person_outline_rounded, label: 'Profile', active: selected == 3, onTap: () => onSelected(3)),
        ]),
      );
}

class _NavItem extends StatelessWidget {
  const _NavItem({required this.icon, required this.label, required this.active, required this.onTap});
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Expanded(child: GestureDetector(onTap: onTap, behavior: HitTestBehavior.opaque, child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 19, color: active ? TetherColors.violet : TetherColors.muted), const SizedBox(height: 4), Text(label, style: TextStyle(fontSize: 7, color: active ? TetherColors.violet : TetherColors.muted, fontWeight: active ? FontWeight.w800 : FontWeight.w500))])));
}

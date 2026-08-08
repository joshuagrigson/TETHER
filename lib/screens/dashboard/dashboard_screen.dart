import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/tether_theme.dart';
import '../../models/person.dart';
import '../../providers/relationship_provider.dart';
import '../../services/relationship_attention_service.dart';
import '../relationship/add_relationship_screen.dart';
import '../relationship/relationship_detail_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  final _searchController = TextEditingController();
  late final AnimationController _pulseController;
  BondState? _filter;
  bool _searching = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  List<Person> _filtered(List<Person> people) {
    final query = _searchController.text.trim().toLowerCase();
    return people.where((person) {
      final matchesQuery = query.isEmpty ||
          person.name.toLowerCase().contains(query) ||
          person.tags.any((tag) => tag.toLowerCase().contains(query));
      final matchesFilter = _filter == null || person.state == _filter;
      return matchesQuery && matchesFilter;
    }).toList();
  }

  void _toggleSearch() {
    setState(() {
      _searching = !_searching;
      if (!_searching) _searchController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RelationshipProvider>();
    final people = _filtered(provider.people);

    return Scaffold(
      backgroundColor: TetherColors.obsidian,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _AddBondButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const AddRelationshipScreen()),
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(child: _AmbientField(animation: _pulseController)),
          SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
                  sliver: SliverToBoxAdapter(
                    child: _Header(
                      searching: _searching,
                      controller: _searchController,
                      onSearch: _toggleSearch,
                      onQueryChanged: () => setState(() {}),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverToBoxAdapter(
                    child: _HealthHero(people: provider.people),
                  ),
                ),
                if (!provider.isLoading && provider.people.isNotEmpty)
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                    sliver: SliverToBoxAdapter(
                      child: _AttentionQueue(people: provider.people),
                    ),
                  ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 22, 20, 10),
                  sliver: SliverToBoxAdapter(
                    child: _FilterBar(
                      selected: _filter,
                      onChanged: (value) => setState(() => _filter = value),
                    ),
                  ),
                ),
                if (provider.isLoading)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (people.isEmpty)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: _EmptyState(),
                  )
                else
                  SliverList.builder(
                    itemCount: people.length,
                    itemBuilder: (context, index) => Padding(
                      padding: const EdgeInsets.fromLTRB(20, 6, 20, 6),
                      child: _RelationshipCard(person: people[index]),
                    ),
                  ),
                const SliverPadding(padding: EdgeInsets.only(bottom: 115)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AmbientField extends StatelessWidget {
  const _AmbientField({required this.animation});
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
  const _AmbientPainter(this.progress);
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final drift = math.sin(progress * math.pi) * 20;

    paint.shader = RadialGradient(
      center: Alignment(-0.7 + progress * 0.08, -0.9),
      radius: 0.8,
      colors: [
        TetherColors.neon.withValues(alpha: 0.075),
        Colors.transparent,
      ],
    ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, paint);

    paint.shader = RadialGradient(
      center: Alignment(0.9, -0.25 + progress * 0.08),
      radius: 0.65,
      colors: [
        TetherColors.violet.withValues(alpha: 0.055),
        Colors.transparent,
      ],
    ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, paint);

    paint
      ..shader = null
      ..color = TetherColors.line.withValues(alpha: 0.11)
      ..strokeWidth = 1;
    for (double y = 120 + drift; y < size.height; y += 96) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _AmbientPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class _Header extends StatelessWidget {
  const _Header({
    required this.searching,
    required this.controller,
    required this.onSearch,
    required this.onQueryChanged,
  });

  final bool searching;
  final TextEditingController controller;
  final VoidCallback onSearch;
  final VoidCallback onQueryChanged;

  @override
  Widget build(BuildContext context) {
    if (searching) {
      return Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              autofocus: true,
              onChanged: (_) => onQueryChanged(),
              decoration: const InputDecoration(
                hintText: 'Search people or tags',
                prefixIcon: Icon(Icons.search_rounded),
                isDense: true,
              ),
            ),
          ),
          IconButton(
            onPressed: onSearch,
            icon: const Icon(Icons.close_rounded),
          ),
        ],
      );
    }

    return Row(
      children: [
        const _TetherMark(),
        const Spacer(),
        _HeaderIcon(icon: Icons.search_rounded, onTap: onSearch),
        const SizedBox(width: 8),
        const _HeaderIcon(icon: Icons.notifications_none_rounded),
        const SizedBox(width: 8),
        Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: TetherColors.line),
            color: TetherColors.surface.withValues(alpha: 0.8),
          ),
          child: const Text(
            'J',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
        ),
      ],
    );
  }
}

class _TetherMark extends StatelessWidget {
  const _TetherMark();

  @override
  Widget build(BuildContext context) => const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'TETHER',
            style: TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.w900,
              letterSpacing: 3.8,
            ),
          ),
          SizedBox(height: 2),
          Text(
            'RELATIONSHIP INTELLIGENCE',
            style: TextStyle(
              fontSize: 7,
              color: TetherColors.muted,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.8,
            ),
          ),
        ],
      );
}

class _HeaderIcon extends StatelessWidget {
  const _HeaderIcon({required this.icon, this.onTap});
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Material(
        color: TetherColors.surface.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: SizedBox(
            width: 40,
            height: 40,
            child: Icon(icon, size: 19, color: TetherColors.text),
          ),
        ),
      );
}

class _HealthHero extends StatelessWidget {
  const _HealthHero({required this.people});
  final List<Person> people;

  @override
  Widget build(BuildContext context) {
    final health = people.isEmpty
        ? 0
        : (people.fold<int>(0, (sum, p) => sum + p.bondXp) /
                (people.length * 10))
            .round()
            .clamp(0, 100);
    final needsAttention =
        people.where((p) => p.state == BondState.needsAttention).length;
    final thriving =
        people.where((p) => p.state == BondState.thriving).length;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: TetherColors.line),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [TetherColors.surfaceRaised, TetherColors.surface],
        ),
        boxShadow: [
          BoxShadow(
            color: TetherColors.neon.withValues(alpha: 0.035),
            blurRadius: 30,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        children: [
          _HealthOrb(value: health),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'CIRCLE STATUS',
                  style: TextStyle(
                    color: TetherColors.neon,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.9,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  needsAttention == 0
                      ? 'Your circle is healthy.'
                      : '$needsAttention bond${needsAttention == 1 ? '' : 's'} need attention.',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    height: 1.08,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  '${people.length} connected · $thriving thriving',
                  style: const TextStyle(
                    color: TetherColors.muted,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 13),
                Row(
                  children: [
                    _MicroStat(value: '$health%', label: 'HEALTH'),
                    const SizedBox(width: 18),
                    _MicroStat(value: '$thriving', label: 'THRIVING'),
                    const SizedBox(width: 18),
                    _MicroStat(
                      value:
                          '+${people.fold<int>(0, (sum, p) => sum + p.recentInteractions * 3)}',
                      label: 'XP / WEEK',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HealthOrb extends StatelessWidget {
  const _HealthOrb({required this.value});
  final int value;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: 92,
        height: 92,
        child: Stack(
          alignment: Alignment.center,
          children: [
            CircularProgressIndicator(
              value: value / 100,
              strokeWidth: 5,
              backgroundColor: TetherColors.line,
              valueColor: const AlwaysStoppedAnimation(TetherColors.neon),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$value',
                  style: const TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const Text(
                  'BOND',
                  style: TextStyle(
                    color: TetherColors.muted,
                    fontSize: 7,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
}

class _MicroStat extends StatelessWidget {
  const _MicroStat({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              color: TetherColors.muted,
              fontSize: 7,
              letterSpacing: 1,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      );
}

class _AttentionQueue extends StatelessWidget {
  const _AttentionQueue({required this.people});
  final List<Person> people;
  static const _service = RelationshipAttentionService();

  @override
  Widget build(BuildContext context) {
    final priorities = _service.prioritize(people, limit: 3);
    if (priorities.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'PEOPLE TO REACH TODAY',
                style: TextStyle(
                  fontSize: 10,
                  letterSpacing: 1.7,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            Text(
              '${priorities.length} PRIORITIES',
              style: const TextStyle(
                fontSize: 8,
                color: TetherColors.muted,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ...priorities.map(
          (person) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _AttentionCard(
              person: person,
              reason: _service.reason(person),
            ),
          ),
        ),
      ],
    );
  }
}

class _AttentionCard extends StatelessWidget {
  const _AttentionCard({required this.person, required this.reason});
  final Person person;
  final String reason;

  @override
  Widget build(BuildContext context) {
    final urgent = person.state == BondState.needsAttention ||
        reason.contains('overdue') ||
        reason == 'Due today';
    final accent = urgent ? TetherColors.danger : TetherColors.neon;

    return Container(
      decoration: BoxDecoration(
        color: TetherColors.surface.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: TetherColors.line),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => RelationshipDetailScreen(personId: person.id),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: accent.withValues(alpha: 0.22)),
                ),
                child: Text(
                  person.initials,
                  style: TextStyle(
                    color: accent,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      person.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      reason,
                      style: TextStyle(
                        color: accent,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 12,
                color: accent.withValues(alpha: 0.65),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterBar extends StatelessWidget {
  const _FilterBar({required this.selected, required this.onChanged});
  final BondState? selected;
  final ValueChanged<BondState?> onChanged;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: [
            _FilterChip(
              label: 'ALL',
              selected: selected == null,
              onTap: () => onChanged(null),
            ),
            _FilterChip(
              label: 'THRIVING',
              selected: selected == BondState.thriving,
              onTap: () => onChanged(BondState.thriving),
            ),
            _FilterChip(
              label: 'STRONG',
              selected: selected == BondState.strong,
              onTap: () => onChanged(BondState.strong),
            ),
            _FilterChip(
              label: 'STEADY',
              selected: selected == BondState.steady,
              onTap: () => onChanged(BondState.steady),
            ),
            _FilterChip(
              label: 'ATTENTION',
              selected: selected == BondState.needsAttention,
              onTap: () => onChanged(BondState.needsAttention),
            ),
          ],
        ),
      );
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(right: 7),
        child: ChoiceChip(
          label: Text(
            label,
            style: const TextStyle(
              fontSize: 9,
              letterSpacing: 1,
              fontWeight: FontWeight.w800,
            ),
          ),
          selected: selected,
          onSelected: (_) => onTap(),
          side: BorderSide(
            color: selected ? TetherColors.neon : TetherColors.line,
          ),
          backgroundColor: TetherColors.surface.withValues(alpha: 0.75),
          selectedColor: TetherColors.neon.withValues(alpha: 0.13),
          labelStyle: TextStyle(
            color: selected ? TetherColors.neon : TetherColors.muted,
          ),
          showCheckmark: false,
        ),
      );
}

class _RelationshipCard extends StatelessWidget {
  const _RelationshipCard({required this.person});
  final Person person;

  @override
  Widget build(BuildContext context) {
    final color = switch (person.state) {
      BondState.thriving => TetherColors.neon,
      BondState.strong => TetherColors.violet,
      BondState.steady => TetherColors.muted,
      BondState.needsAttention => TetherColors.danger,
    };

    return Container(
      decoration: BoxDecoration(
        color: TetherColors.surface.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: TetherColors.line),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => RelationshipDetailScreen(personId: person.id),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      person.initials,
                      style: TextStyle(
                        color: color,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: TetherColors.surface,
                        width: 2,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      person.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Text(
                          '${person.bondXp} XP',
                          style: TextStyle(
                            color: color,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const Text(
                          '  ·  ',
                          style: TextStyle(color: TetherColors.line),
                        ),
                        Text(
                          '${person.recentInteractions} interactions',
                          style: const TextStyle(
                            color: TetherColors.muted,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: color),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddBondButton extends StatelessWidget {
  const _AddBondButton({required this.onPressed});
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: TetherColors.neon.withValues(alpha: 0.18),
              blurRadius: 22,
              spreadRadius: 1,
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: onPressed,
          backgroundColor: TetherColors.neon,
          foregroundColor: TetherColors.obsidian,
          elevation: 0,
          icon: const Icon(Icons.add_rounded, size: 20),
          label: const Text(
            'ADD BOND',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
            ),
          ),
        ),
      );
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.radar_rounded,
                size: 46,
                color: TetherColors.muted.withValues(alpha: 0.7),
              ),
              const SizedBox(height: 16),
              const Text(
                'NO MATCHES',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 7),
              const Text(
                'Nothing in your circle matches the current search or filter.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: TetherColors.muted,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      );
}

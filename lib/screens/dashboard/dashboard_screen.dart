import 'package:flutter/material.dart';
import '../../core/theme/tether_theme.dart';
import '../../models/person.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  static const people = <Person>[
    Person(id: '1', name: 'Alex', initials: 'AX', bondXp: 920, recentInteractions: 7, cadence: Cadence.daily, state: BondState.thriving),
    Person(id: '2', name: 'Jordan', initials: 'JD', bondXp: 640, recentInteractions: 4, cadence: Cadence.weekly, state: BondState.strong),
    Person(id: '3', name: 'Morgan', initials: 'MG', bondXp: 310, recentInteractions: 2, cadence: Cadence.weekly, state: BondState.steady),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              sliver: SliverToBoxAdapter(child: _Header()),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverToBoxAdapter(child: _HealthHero()),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
              sliver: SliverToBoxAdapter(
                child: Text('YOUR BONDS', style: Theme.of(context).textTheme.labelMedium?.copyWith(letterSpacing: 2, color: TetherColors.muted)),
              ),
            ),
            SliverList.builder(
              itemCount: people.length,
              itemBuilder: (context, index) => Padding(
                padding: const EdgeInsets.fromLTRB(20, 7, 20, 7),
                child: _RelationshipCard(person: people[index]),
              ),
            ),
            const SliverPadding(padding: EdgeInsets.only(bottom: 28)),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Row(
    children: [
      const Expanded(child: Text('TETHER', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, letterSpacing: 3))),
      Container(width: 42, height: 42, decoration: BoxDecoration(color: TetherColors.surfaceRaised, borderRadius: BorderRadius.circular(14)), child: const Icon(Icons.notifications_none_rounded)),
    ],
  );
}

class _HealthHero extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(22),
    decoration: BoxDecoration(
      gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [TetherColors.surfaceRaised, TetherColors.surface]),
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: TetherColors.line),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('GOOD EVENING', style: Theme.of(context).textTheme.labelMedium?.copyWith(color: TetherColors.neon, letterSpacing: 2)),
      const SizedBox(height: 10),
      const Text('Your circle is healthy.', style: TextStyle(fontSize: 27, fontWeight: FontWeight.w700)),
      const SizedBox(height: 6),
      Text('3 relationships are trending positively.', style: TextStyle(color: TetherColors.muted)),
      const SizedBox(height: 20),
      Row(children: const [
        _Metric(value: '82%', label: 'HEALTH'),
        SizedBox(width: 28),
        _Metric(value: '+126', label: 'XP THIS WEEK'),
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
    Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
    const SizedBox(height: 3),
    Text(label, style: const TextStyle(fontSize: 10, color: TetherColors.muted, letterSpacing: 1.3)),
  ]);
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
    return Card(child: Padding(padding: const EdgeInsets.all(16), child: Row(children: [
      CircleAvatar(radius: 25, backgroundColor: color.withValues(alpha: .14), child: Text(person.initials, style: TextStyle(color: color, fontWeight: FontWeight.w800))),
      const SizedBox(width: 14),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(person.name, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
        const SizedBox(height: 5),
        Text('${person.bondXp} XP  •  ${person.recentInteractions} recent interactions', style: const TextStyle(color: TetherColors.muted, fontSize: 12)),
      ])),
      Icon(Icons.chevron_right_rounded, color: color),
    ])));
  }
}

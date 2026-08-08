import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/tether_theme.dart';
import '../../models/person.dart';
import '../../providers/relationship_provider.dart';
import '../relationship/add_relationship_screen.dart';
import '../relationship/relationship_detail_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final people = context.watch<RelationshipProvider>().people;
    return Scaffold(
      body: SafeArea(child: CustomScrollView(slivers: [
        SliverPadding(padding: const EdgeInsets.fromLTRB(20, 20, 20, 12), sliver: SliverToBoxAdapter(child: _Header())),
        SliverPadding(padding: const EdgeInsets.symmetric(horizontal: 20), sliver: SliverToBoxAdapter(child: _HealthHero(people: people))),
        SliverPadding(padding: const EdgeInsets.fromLTRB(20, 24, 20, 8), sliver: SliverToBoxAdapter(child: Row(children: [const Expanded(child: Text('YOUR BONDS', style: TextStyle(letterSpacing: 2, color: TetherColors.muted, fontSize: 11))), TextButton.icon(onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AddRelationshipScreen())), icon: const Icon(Icons.add_rounded, size: 17), label: const Text('ADD'))]))),
        if (people.isEmpty) const SliverFillRemaining(hasScrollBody: false, child: Center(child: Text('Your circle is empty. Add your first relationship.'))),
        SliverList.builder(itemCount: people.length, itemBuilder: (context, index) => Padding(padding: const EdgeInsets.fromLTRB(20, 7, 20, 7), child: _RelationshipCard(person: people[index]))),
        const SliverPadding(padding: EdgeInsets.only(bottom: 28)),
      ])),
      floatingActionButton: FloatingActionButton(onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AddRelationshipScreen())), child: const Icon(Icons.person_add_alt_1_rounded)),
    );
  }
}

class _Header extends StatelessWidget { @override Widget build(BuildContext context) => Row(children: [const Expanded(child: Text('TETHER', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, letterSpacing: 3))), Container(width: 42, height: 42, decoration: BoxDecoration(color: TetherColors.surfaceRaised, borderRadius: BorderRadius.circular(14)), child: const Icon(Icons.notifications_none_rounded))]); }

class _HealthHero extends StatelessWidget {
  const _HealthHero({required this.people}); final List<Person> people;
  @override Widget build(BuildContext context) { final average = people.isEmpty ? 0 : (people.fold<int>(0, (sum, p) => sum + p.bondXp) / (people.length * 10)).round().clamp(0, 100); return Container(padding: const EdgeInsets.all(22), decoration: BoxDecoration(gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [TetherColors.surfaceRaised, TetherColors.surface]), borderRadius: BorderRadius.circular(24), border: Border.all(color: TetherColors.line)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('GOOD EVENING', style: Theme.of(context).textTheme.labelMedium?.copyWith(color: TetherColors.neon, letterSpacing: 2)), const SizedBox(height: 10), const Text('Your circle is healthy.', style: TextStyle(fontSize: 27, fontWeight: FontWeight.w700)), const SizedBox(height: 6), Text('${people.length} relationships are in your circle.', style: const TextStyle(color: TetherColors.muted)), const SizedBox(height: 20), Row(children: [_Metric(value: '$average%', label: 'HEALTH'), const SizedBox(width: 28), _Metric(value: '+${people.fold<int>(0, (sum, p) => sum + p.recentInteractions * 3)}', label: 'XP THIS WEEK')]) ])); }
}

class _Metric extends StatelessWidget { const _Metric({required this.value, required this.label}); final String value, label; @override Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)), const SizedBox(height: 3), Text(label, style: const TextStyle(fontSize: 10, color: TetherColors.muted, letterSpacing: 1.3))]); }

class _RelationshipCard extends StatelessWidget { const _RelationshipCard({required this.person}); final Person person; @override Widget build(BuildContext context) { final color = switch (person.state) { BondState.thriving => TetherColors.neon, BondState.strong => TetherColors.violet, BondState.steady => TetherColors.muted, BondState.needsAttention => TetherColors.danger }; return Card(child: InkWell(borderRadius: BorderRadius.circular(20), onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => RelationshipDetailScreen(personId: person.id))), child: Padding(padding: const EdgeInsets.all(16), child: Row(children: [CircleAvatar(radius: 25, backgroundColor: color.withValues(alpha: .14), child: Text(person.initials, style: TextStyle(color: color, fontWeight: FontWeight.w800))), const SizedBox(width: 14), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(person.name, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)), const SizedBox(height: 5), Text('${person.bondXp} XP  •  ${person.recentInteractions} recent interactions', style: const TextStyle(color: TetherColors.muted, fontSize: 12))])), Icon(Icons.chevron_right_rounded, color: color)])))); } }

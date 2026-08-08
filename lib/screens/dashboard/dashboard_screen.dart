import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/tether_theme.dart';
import '../../models/person.dart';
import '../../providers/relationship_provider.dart';
import '../relationship/add_relationship_screen.dart';
import '../relationship/relationship_detail_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _searchController = TextEditingController();
  BondState? _filter;
  bool _searching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Person> _filtered(List<Person> people) {
    final query = _searchController.text.trim().toLowerCase();
    return people.where((person) {
      final matchesQuery = query.isEmpty || person.name.toLowerCase().contains(query) || person.tags.any((tag) => tag.toLowerCase().contains(query));
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AddRelationshipScreen())),
        icon: const Icon(Icons.add_rounded),
        label: const Text('ADD BOND'),
      ),
      body: SafeArea(
        child: CustomScrollView(slivers: [
          SliverPadding(padding: const EdgeInsets.fromLTRB(20, 20, 20, 12), sliver: SliverToBoxAdapter(child: _Header(searching: _searching, controller: _searchController, onSearch: _toggleSearch, onQueryChanged: () => setState(() {})))),
          SliverPadding(padding: const EdgeInsets.symmetric(horizontal: 20), sliver: SliverToBoxAdapter(child: _HealthHero(people: provider.people))),
          SliverPadding(padding: const EdgeInsets.fromLTRB(20, 24, 20, 10), sliver: SliverToBoxAdapter(child: _FilterBar(selected: _filter, onChanged: (value) => setState(() => _filter = value)))),
          if (provider.isLoading)
            const SliverFillRemaining(hasScrollBody: false, child: Center(child: CircularProgressIndicator()))
          else if (people.isEmpty)
            const SliverFillRemaining(hasScrollBody: false, child: _EmptyState())
          else
            SliverList.builder(itemCount: people.length, itemBuilder: (context, index) => Padding(padding: const EdgeInsets.fromLTRB(20, 7, 20, 7), child: _RelationshipCard(person: people[index]))),
          const SliverPadding(padding: EdgeInsets.only(bottom: 110)),
        ]),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.searching, required this.controller, required this.onSearch, required this.onQueryChanged});
  final bool searching;
  final TextEditingController controller;
  final VoidCallback onSearch;
  final VoidCallback onQueryChanged;

  @override
  Widget build(BuildContext context) {
    if (searching) {
      return Row(children: [
        Expanded(child: TextField(controller: controller, autofocus: true, onChanged: (_) => onQueryChanged(), decoration: const InputDecoration(hintText: 'Search people or tags', prefixIcon: Icon(Icons.search_rounded), isDense: true))),
        IconButton(onPressed: onSearch, icon: const Icon(Icons.close_rounded)),
      ]);
    }
    return Row(children: [
      const Expanded(child: Text('TETHER', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, letterSpacing: 3))),
      IconButton(onPressed: onSearch, icon: const Icon(Icons.search_rounded)),
      Container(width: 42, height: 42, decoration: BoxDecoration(color: TetherColors.surfaceRaised, borderRadius: BorderRadius.circular(14)), child: const Icon(Icons.notifications_none_rounded)),
    ]);
  }
}

class _HealthHero extends StatelessWidget {
  const _HealthHero({required this.people});
  final List<Person> people;

  @override
  Widget build(BuildContext context) {
    final average = people.isEmpty ? 0 : (people.fold<int>(0, (sum, p) => sum + p.bondXp) / (people.length * 10)).round().clamp(0, 100);
    final needsAttention = people.where((p) => p.state == BondState.needsAttention).length;
    final thriving = people.where((p) => p.state == BondState.thriving).length;
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [TetherColors.surfaceRaised, TetherColors.surface]), borderRadius: BorderRadius.circular(24), border: Border.all(color: TetherColors.line)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('GOOD EVENING', style: Theme.of(context).textTheme.labelMedium?.copyWith(color: TetherColors.neon, letterSpacing: 2)),
        const SizedBox(height: 10),
        const Text('Your circle is healthy.', style: TextStyle(fontSize: 27, fontWeight: FontWeight.w700)),
        const SizedBox(height: 6),
        Text('${people.length} relationships connected${needsAttention == 0 ? '.' : ' · $needsAttention need attention.'}', style: const TextStyle(color: TetherColors.muted)),
        const SizedBox(height: 20),
        Row(children: [_Metric(value: '$average%', label: 'HEALTH'), const SizedBox(width: 28), _Metric(value: '$thriving', label: 'THRIVING'), const SizedBox(width: 28), _Metric(value: '+${people.fold<int>(0, (sum, p) => sum + p.recentInteractions * 3)}', label: 'XP THIS WEEK')]),
      ]),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.value, required this.label});
  final String value;
  final String label;
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(value, style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w800)), const SizedBox(height: 3), Text(label, style: const TextStyle(fontSize: 9, color: TetherColors.muted, letterSpacing: 1.1))]);
}

class _FilterBar extends StatelessWidget {
  const _FilterBar({required this.selected, required this.onChanged});
  final BondState? selected;
  final ValueChanged<BondState?> onChanged;
  @override
  Widget build(BuildContext context) => SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: [
    _FilterChip(label: 'ALL', selected: selected == null, onTap: () => onChanged(null)),
    _FilterChip(label: 'THRIVING', selected: selected == BondState.thriving, onTap: () => onChanged(BondState.thriving)),
    _FilterChip(label: 'STRONG', selected: selected == BondState.strong, onTap: () => onChanged(BondState.strong)),
    _FilterChip(label: 'STEADY', selected: selected == BondState.steady, onTap: () => onChanged(BondState.steady)),
    _FilterChip(label: 'ATTENTION', selected: selected == BondState.needsAttention, onTap: () => onChanged(BondState.needsAttention)),
  ]));
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.only(right: 8), child: ChoiceChip(label: Text(label, style: const TextStyle(fontSize: 10, letterSpacing: 1, fontWeight: FontWeight.w700)), selected: selected, onSelected: (_) => onTap()));
}

class _RelationshipCard extends StatelessWidget {
  const _RelationshipCard({required this.person});
  final Person person;
  @override
  Widget build(BuildContext context) {
    final color = switch (person.state) { BondState.thriving => TetherColors.neon, BondState.strong => TetherColors.violet, BondState.steady => TetherColors.muted, BondState.needsAttention => TetherColors.danger };
    return Card(child: InkWell(borderRadius: BorderRadius.circular(20), onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => RelationshipDetailScreen(personId: person.id))), child: Padding(padding: const EdgeInsets.all(16), child: Row(children: [
      CircleAvatar(radius: 25, backgroundColor: color.withValues(alpha: .14), child: Text(person.initials, style: TextStyle(color: color, fontWeight: FontWeight.w800))),
      const SizedBox(width: 14),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(person.name, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)), const SizedBox(height: 5), Text('${person.bondXp} XP  •  ${person.recentInteractions} recent interactions', style: const TextStyle(color: TetherColors.muted, fontSize: 12))])),
      Icon(Icons.chevron_right_rounded, color: color),
    ]))));
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();
  @override
  Widget build(BuildContext context) => Center(child: Padding(padding: const EdgeInsets.all(40), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
    Icon(Icons.search_off_rounded, size: 44, color: TetherColors.muted),
    const SizedBox(height: 14),
    const Text('NO MATCHES', style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 2)),
    const SizedBox(height: 6),
    const Text('Nothing in your circle matches the current search or filter.', textAlign: TextAlign.center, style: TextStyle(color: TetherColors.muted)),
  ])));
}

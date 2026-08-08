import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/tether_theme.dart';
import '../../models/interaction.dart';
import '../../models/person.dart';
import '../../providers/relationship_provider.dart';

class RelationshipDetailScreen extends StatelessWidget {
  const RelationshipDetailScreen({super.key, required this.personId});

  final String personId;

  @override
  Widget build(BuildContext context) {
    final person = context.watch<RelationshipProvider>().findById(personId);
    if (person == null) return const Scaffold(body: Center(child: Text('Relationship not found')));

    final interactions = _timeline(person);
    final health = _health(person);

    return Scaffold(
      appBar: AppBar(
        title: const Text('RELATIONSHIP', style: TextStyle(letterSpacing: 2, fontSize: 13, fontWeight: FontWeight.w700)),
        actions: [
          IconButton(tooltip: 'Log interaction', icon: const Icon(Icons.add_comment_outlined), onPressed: () => _logInteraction(context, person)),
          IconButton(tooltip: 'Edit relationship', icon: const Icon(Icons.edit_outlined), onPressed: () => _showEditSheet(context, person)),
        ],
      ),
      body: CustomScrollView(slivers: [
        SliverPadding(padding: const EdgeInsets.fromLTRB(20, 8, 20, 24), sliver: SliverToBoxAdapter(child: _ProfileHero(person: person, health: health))),
        SliverPadding(padding: const EdgeInsets.symmetric(horizontal: 20), sliver: SliverToBoxAdapter(child: _QuickStats(person: person))),
        SliverPadding(padding: const EdgeInsets.fromLTRB(20, 28, 20, 10), sliver: SliverToBoxAdapter(child: _SectionTitle(title: 'TIMELINE', action: 'ADD NOTE', onAction: () => _showNote(context, person)))),
        SliverPadding(padding: const EdgeInsets.symmetric(horizontal: 20), sliver: SliverList.builder(itemCount: interactions.length, itemBuilder: (context, index) => _TimelineItem(interaction: interactions[index]))),
        SliverPadding(padding: const EdgeInsets.fromLTRB(20, 24, 20, 10), sliver: SliverToBoxAdapter(child: _SectionTitle(title: 'MEMORIES & NOTES'))),
        SliverPadding(padding: const EdgeInsets.fromLTRB(20, 0, 20, 36), sliver: SliverToBoxAdapter(child: _NotesCard(person: person))),
      ]),
    );
  }

  static String _health(Person person) {
    if (person.bondXp >= 800 && person.recentInteractions >= 5) return 'THRIVING';
    if (person.bondXp >= 500 && person.recentInteractions >= 3) return 'STRONG';
    if (person.recentInteractions > 0) return 'STEADY';
    return 'NEEDS ATTENTION';
  }

  static List<Interaction> _timeline(Person person) => [
    Interaction(id: 'i1', personId: person.id, type: InteractionType.conversation, title: 'Meaningful conversation', description: 'A recent interaction strengthened the bond.', occurredAt: DateTime.now().subtract(const Duration(hours: 5))),
    Interaction(id: 'i2', personId: person.id, type: InteractionType.memory, title: 'Memory captured', description: '${person.memoryCount} memories are connected to this relationship.', occurredAt: DateTime.now().subtract(const Duration(days: 2))),
    Interaction(id: 'i3', personId: person.id, type: InteractionType.note, title: 'Relationship note', description: person.notes.isEmpty ? 'No notes yet.' : person.notes.first, occurredAt: DateTime.now().subtract(const Duration(days: 6))),
  ];

  Future<void> _logInteraction(BuildContext context, Person person) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: TetherColors.surface,
      builder: (sheetContext) => SafeArea(child: Padding(padding: const EdgeInsets.fromLTRB(20, 18, 20, 24), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('LOG INTERACTION', style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 2)),
        const SizedBox(height: 6),
        const Text('TETHER will increase bond XP and recalculate relationship health.', style: TextStyle(color: TetherColors.muted)),
        const SizedBox(height: 18),
        Row(children: [
          Expanded(child: _InteractionAction(icon: Icons.chat_bubble_outline_rounded, label: 'CONVERSATION', onTap: () { context.read<RelationshipProvider>().recordInteraction(person.id, xp: 25); Navigator.pop(sheetContext); })),
          const SizedBox(width: 10),
          Expanded(child: _InteractionAction(icon: Icons.call_outlined, label: 'CALL', onTap: () { context.read<RelationshipProvider>().recordInteraction(person.id, xp: 35); Navigator.pop(sheetContext); })),
        ]),
      ])),
    );
  }

  Future<void> _showEditSheet(BuildContext context, Person person) async {
    final controller = TextEditingController(text: person.name);
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: TetherColors.surface,
      builder: (sheetContext) => Padding(padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.viewInsetsOf(sheetContext).bottom + 20), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('EDIT RELATIONSHIP', style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 2)),
        const SizedBox(height: 18),
        TextField(controller: controller, autofocus: true, decoration: const InputDecoration(labelText: 'Name', border: OutlineInputBorder())),
        const SizedBox(height: 14),
        FilledButton(onPressed: () { context.read<RelationshipProvider>().save(person.copyWith(name: controller.text.trim().isEmpty ? person.name : controller.text.trim())); Navigator.pop(sheetContext); }, child: const Text('SAVE CHANGES')),
      ])),
    );
    controller.dispose();
  }

  Future<void> _showNote(BuildContext context, Person person) async {
    final controller = TextEditingController();
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: TetherColors.surface,
      builder: (sheetContext) => Padding(padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.viewInsetsOf(sheetContext).bottom + 20), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('CAPTURE A NOTE', style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 2)),
        const SizedBox(height: 18),
        TextField(controller: controller, autofocus: true, maxLines: 4, decoration: const InputDecoration(hintText: 'What should TETHER remember?', border: OutlineInputBorder())),
        const SizedBox(height: 14),
        FilledButton(onPressed: () { final value = controller.text.trim(); if (value.isNotEmpty) context.read<RelationshipProvider>().save(person.copyWith(notes: [value, ...person.notes])); Navigator.pop(sheetContext); }, child: const Text('SAVE NOTE')),
      ])),
    );
    controller.dispose();
  }
}

class _InteractionAction extends StatelessWidget {
  const _InteractionAction({required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => OutlinedButton.icon(onPressed: onTap, icon: Icon(icon), label: Text(label, style: const TextStyle(fontSize: 10, letterSpacing: .8)), style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 15)));
}

class _ProfileHero extends StatelessWidget {
  const _ProfileHero({required this.person, required this.health});
  final Person person;
  final String health;
  @override
  Widget build(BuildContext context) {
    final color = health == 'THRIVING' ? TetherColors.neon : health == 'NEEDS ATTENTION' ? TetherColors.danger : TetherColors.violet;
    return Container(padding: const EdgeInsets.all(22), decoration: BoxDecoration(gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [TetherColors.surfaceRaised, TetherColors.surface]), borderRadius: BorderRadius.circular(26), border: Border.all(color: TetherColors.line)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [CircleAvatar(radius: 34, backgroundColor: color.withValues(alpha: .14), child: Text(person.initials, style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 18))), const SizedBox(width: 16), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(person.name, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800)), const SizedBox(height: 5), Text(health, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 2))]))]),
      const SizedBox(height: 24),
      Row(children: [Expanded(child: _Gauge(label: 'BOND XP', value: '${person.bondXp}', progress: (person.bondXp / 1000).clamp(0, 1).toDouble(), color: color)), const SizedBox(width: 18), Expanded(child: _Gauge(label: 'CADENCE', value: person.cadence.name.toUpperCase(), progress: person.recentInteractions.clamp(0, 7) / 7, color: TetherColors.violet))]),
    ]));
  }
}

class _Gauge extends StatelessWidget {
  const _Gauge({required this.label, required this.value, required this.progress, required this.color});
  final String label, value;
  final double progress;
  final Color color;
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: const TextStyle(color: TetherColors.muted, fontSize: 10, letterSpacing: 1.4)), const SizedBox(height: 6), Text(value, style: const TextStyle(fontWeight: FontWeight.w800)), const SizedBox(height: 8), ClipRRect(borderRadius: BorderRadius.circular(99), child: LinearProgressIndicator(value: progress, minHeight: 6, color: color, backgroundColor: TetherColors.line))]);
}

class _QuickStats extends StatelessWidget {
  const _QuickStats({required this.person});
  final Person person;
  @override
  Widget build(BuildContext context) => Row(children: [Expanded(child: _Stat(value: '${person.recentInteractions}', label: 'INTERACTIONS')), Expanded(child: _Stat(value: '${person.memoryCount}', label: 'MEMORIES')), Expanded(child: _Stat(value: '${person.tags.length}', label: 'TAGS'))]);
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});
  final String value, label;
  @override
  Widget build(BuildContext context) => Column(children: [Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)), const SizedBox(height: 3), Text(label, style: const TextStyle(fontSize: 9, color: TetherColors.muted, letterSpacing: 1.2))]);
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, this.action, this.onAction});
  final String title;
  final String? action;
  final VoidCallback? onAction;
  @override
  Widget build(BuildContext context) => Row(children: [Expanded(child: Text(title, style: const TextStyle(fontSize: 11, color: TetherColors.muted, letterSpacing: 2, fontWeight: FontWeight.w700))), if (action != null) TextButton(onPressed: onAction, child: Text(action!))]);
}

class _TimelineItem extends StatelessWidget {
  const _TimelineItem({required this.interaction});
  final Interaction interaction;
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.only(bottom: 14), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Container(width: 10, height: 10, margin: const EdgeInsets.only(top: 5), decoration: const BoxDecoration(color: TetherColors.neon, shape: BoxShape.circle)), const SizedBox(width: 14), Expanded(child: Card(child: Padding(padding: const EdgeInsets.all(15), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(interaction.title, style: const TextStyle(fontWeight: FontWeight.w700)), const SizedBox(height: 5), Text(interaction.description, style: const TextStyle(color: TetherColors.muted, fontSize: 12)), const SizedBox(height: 8), Text(_date(interaction.occurredAt), style: const TextStyle(color: TetherColors.muted, fontSize: 10))])))]));
}

class _NotesCard extends StatelessWidget {
  const _NotesCard({required this.person});
  final Person person;
  @override
  Widget build(BuildContext context) => Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Wrap(spacing: 7, runSpacing: 7, children: person.tags.map((tag) => Chip(label: Text(tag, style: const TextStyle(fontSize: 11)))).toList()), const SizedBox(height: 8), if (person.notes.isEmpty) const Text('No notes captured yet.', style: TextStyle(color: TetherColors.muted)) else ...person.notes.take(3).map((note) => Padding(padding: const EdgeInsets.only(top: 8), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [const Icon(Icons.notes_rounded, size: 16, color: TetherColors.muted), const SizedBox(width: 8), Expanded(child: Text(note))]))])));
}

String _date(DateTime date) => '${date.month}/${date.day} · ${date.hour == 0 ? 12 : (date.hour > 12 ? date.hour - 12 : date.hour)}:${date.minute.toString().padLeft(2, '0')} ${date.hour >= 12 ? 'PM' : 'AM'}';

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
    final provider = context.watch<RelationshipProvider>();
    final person = provider.findById(personId);

    if (person == null) {
      return const Scaffold(
        body: Center(child: Text('Relationship not found')),
      );
    }

    final interactions =
        provider.interactionsFor(person.id).reversed.toList(growable: false);
    final health = switch (person.state) {
      BondState.thriving => 'THRIVING',
      BondState.strong => 'STRONG',
      BondState.steady => 'STEADY',
      BondState.needsAttention => 'NEEDS ATTENTION',
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'RELATIONSHIP',
          style: TextStyle(
            letterSpacing: 2,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Log interaction',
            icon: const Icon(Icons.add_comment_outlined),
            onPressed: () => _logInteraction(context, person),
          ),
          IconButton(
            tooltip: 'Edit relationship',
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => _showEditSheet(context, person),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            sliver: SliverToBoxAdapter(
              child: _ProfileHero(person: person, health: health),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverToBoxAdapter(child: _QuickStats(person: person)),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 28, 20, 10),
            sliver: SliverToBoxAdapter(
              child: _SectionTitle(
                title: 'INTERACTION HISTORY',
                action: 'ADD NOTE',
                onAction: () => _showNote(context, person),
              ),
            ),
          ),
          if (interactions.isEmpty)
            const SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverToBoxAdapter(
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(18),
                    child: Text(
                      'No interactions recorded yet. Your next conversation or call will appear here.',
                      style: TextStyle(color: TetherColors.muted),
                    ),
                  ),
                ),
              ),
            ),
          if (interactions.isNotEmpty)
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList.builder(
                itemCount: interactions.length,
                itemBuilder: (context, index) =>
                    _TimelineItem(interaction: interactions[index]),
              ),
            ),
          const SliverPadding(
            padding: EdgeInsets.fromLTRB(20, 24, 20, 10),
            sliver: SliverToBoxAdapter(
              child: _SectionTitle(title: 'MEMORIES & NOTES'),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 36),
            sliver: SliverToBoxAdapter(child: _NotesCard(person: person)),
          ),
        ],
      ),
    );
  }

  Future<void> _logInteraction(BuildContext context, Person person) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: TetherColors.surface,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'LOG INTERACTION',
                  style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 2),
                ),
                const SizedBox(height: 6),
                const Text(
                  'This creates a permanent timeline event, updates the last-contact date, awards XP, and recalculates health.',
                  style: TextStyle(color: TetherColors.muted),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: _InteractionAction(
                        icon: Icons.chat_bubble_outline_rounded,
                        label: 'CONVERSATION',
                        onTap: () {
                          context.read<RelationshipProvider>().recordInteraction(
                                person.id,
                                type: InteractionType.conversation,
                                xp: 25,
                              );
                          Navigator.pop(sheetContext);
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _InteractionAction(
                        icon: Icons.call_outlined,
                        label: 'CALL',
                        onTap: () {
                          context.read<RelationshipProvider>().recordInteraction(
                                person.id,
                                type: InteractionType.call,
                                xp: 35,
                              );
                          Navigator.pop(sheetContext);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showEditSheet(BuildContext context, Person person) async {
    final controller = TextEditingController(text: person.name);

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: TetherColors.surface,
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            MediaQuery.viewInsetsOf(sheetContext).bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'EDIT RELATIONSHIP',
                style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 2),
              ),
              const SizedBox(height: 18),
              TextField(
                controller: controller,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 14),
              FilledButton(
                onPressed: () {
                  context.read<RelationshipProvider>().save(
                        person.copyWith(
                          name: controller.text.trim().isEmpty
                              ? person.name
                              : controller.text.trim(),
                        ),
                      );
                  Navigator.pop(sheetContext);
                },
                child: const Text('SAVE CHANGES'),
              ),
            ],
          ),
        );
      },
    );

    controller.dispose();
  }

  Future<void> _showNote(BuildContext context, Person person) async {
    final controller = TextEditingController();

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: TetherColors.surface,
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            MediaQuery.viewInsetsOf(sheetContext).bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'CAPTURE A NOTE',
                style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 2),
              ),
              const SizedBox(height: 18),
              TextField(
                controller: controller,
                autofocus: true,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'What should TETHER remember?',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 14),
              FilledButton(
                onPressed: () {
                  context
                      .read<RelationshipProvider>()
                      .addNote(person.id, controller.text);
                  Navigator.pop(sheetContext);
                },
                child: const Text('SAVE NOTE'),
              ),
            ],
          ),
        );
      },
    );

    controller.dispose();
  }
}

class _InteractionAction extends StatelessWidget {
  const _InteractionAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon),
      label: Text(
        label,
        style: const TextStyle(fontSize: 10, letterSpacing: .8),
      ),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 15),
      ),
    );
  }
}

class _ProfileHero extends StatelessWidget {
  const _ProfileHero({required this.person, required this.health});

  final Person person;
  final String health;

  @override
  Widget build(BuildContext context) {
    final color = health == 'THRIVING'
        ? TetherColors.neon
        : health == 'NEEDS ATTENTION'
            ? TetherColors.danger
            : TetherColors.violet;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [TetherColors.surfaceRaised, TetherColors.surface],
        ),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: TetherColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 34,
                backgroundColor: color.withValues(alpha: .14),
                child: Text(
                  person.initials,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      person.name,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      health,
                      style: TextStyle(
                        color: color,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _Gauge(
                  label: 'BOND XP',
                  value: '${person.bondXp}',
                  progress: (person.bondXp / 1000).clamp(0, 1).toDouble(),
                  color: color,
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: _Gauge(
                  label: 'CADENCE',
                  value: person.cadence.name.toUpperCase(),
                  progress:
                      (person.recentInteractions.clamp(0, 7) / 7).toDouble(),
                  color: TetherColors.violet,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Gauge extends StatelessWidget {
  const _Gauge({
    required this.label,
    required this.value,
    required this.progress,
    required this.color,
  });

  final String label;
  final String value;
  final double progress;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: TetherColors.muted,
            fontSize: 10,
            letterSpacing: 1.4,
          ),
        ),
        const SizedBox(height: 6),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(99),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 6,
            color: color,
            backgroundColor: TetherColors.line,
          ),
        ),
      ],
    );
  }
}

class _QuickStats extends StatelessWidget {
  const _QuickStats({required this.person});

  final Person person;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _Stat(
            value: '${person.recentInteractions}',
            label: 'INTERACTIONS',
          ),
        ),
        Expanded(
          child: _Stat(value: '${person.memoryCount}', label: 'MEMORIES'),
        ),
        Expanded(
          child: _Stat(value: '${person.tags.length}', label: 'TAGS'),
        ),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: const TextStyle(
            fontSize: 9,
            color: TetherColors.muted,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.title,
    this.action,
    this.onAction,
  });

  final String title;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              color: TetherColors.muted,
              letterSpacing: 2,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        if (action != null)
          TextButton(onPressed: onAction, child: Text(action!)),
      ],
    );
  }
}

class _TimelineItem extends StatelessWidget {
  const _TimelineItem({required this.interaction});

  final Interaction interaction;

  @override
  Widget build(BuildContext context) {
    final icon = interaction.type == InteractionType.call
        ? Icons.call_outlined
        : interaction.type == InteractionType.note
            ? Icons.notes_rounded
            : Icons.chat_bubble_outline_rounded;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: TetherColors.neon.withValues(alpha: .1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 16, color: TetherColors.neon),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      interaction.title,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      interaction.description,
                      style: const TextStyle(
                        color: TetherColors.muted,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _date(interaction.occurredAt),
                      style: const TextStyle(
                        color: TetherColors.muted,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NotesCard extends StatelessWidget {
  const _NotesCard({required this.person});

  final Person person;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 7,
              runSpacing: 7,
              children: person.tags
                  .map(
                    (tag) => Chip(
                      label: Text(
                        tag,
                        style: const TextStyle(fontSize: 11),
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 8),
            if (person.notes.isEmpty)
              const Text(
                'No notes captured yet.',
                style: TextStyle(color: TetherColors.muted),
              )
            else
              ...person.notes.take(3).map(
                    (note) => Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.notes_rounded,
                            size: 16,
                            color: TetherColors.muted,
                          ),
                          const SizedBox(width: 8),
                          Expanded(child: Text(note)),
                        ],
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

String _date(DateTime date) {
  final hour = date.hour == 0
      ? 12
      : date.hour > 12
          ? date.hour - 12
          : date.hour;
  final minute = date.minute.toString().padLeft(2, '0');
  final meridiem = date.hour >= 12 ? 'PM' : 'AM';
  return '${date.month}/${date.day} · $hour:$minute $meridiem';
}

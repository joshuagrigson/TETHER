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

    final interactions = provider.interactionsFor(person.id).reversed.toList();
    final accent = _healthColor(person.state);

    return Scaffold(
      backgroundColor: TetherColors.obsidian,
      appBar: AppBar(
        backgroundColor: TetherColors.obsidian,
        title: const Text(
          'BOND PROFILE',
          style: TextStyle(
            fontSize: 10,
            letterSpacing: 2.2,
            fontWeight: FontWeight.w800,
            color: TetherColors.muted,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => _editName(context, person),
            icon: const Icon(Icons.edit_outlined),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 34),
        children: [
          _HeroCard(person: person, accent: accent),
          const SizedBox(height: 12),
          _ActionRow(
            onChat: () => _record(context, person, InteractionType.conversation, 25),
            onCall: () => _record(context, person, InteractionType.call, 35),
            onPlan: () => _record(context, person, InteractionType.note, 20),
            onNote: () => _addNote(context, person),
          ),
          const SizedBox(height: 24),
          _NextAction(person: person),
          const SizedBox(height: 26),
          _Heading(title: 'BOND SIGNALS', trailing: '${person.bondXp} XP'),
          const SizedBox(height: 10),
          _SignalRow(person: person),
          const SizedBox(height: 28),
          _Heading(
            title: 'RELATIONSHIP TIMELINE',
            trailing: '${interactions.length} EVENTS',
          ),
          const SizedBox(height: 10),
          _TimelineList(interactions: interactions),
          const SizedBox(height: 18),
          _Heading(
            title: 'MEMORY BANK',
            trailing: '${person.memoryCount} MEMORIES',
          ),
          const SizedBox(height: 10),
          _MemoryBank(person: person),
        ],
      ),
    );
  }

  void _record(
    BuildContext context,
    Person person,
    InteractionType type,
    int xp,
  ) {
    context.read<RelationshipProvider>().recordInteraction(
      person.id,
      type: type,
      xp: xp,
    );

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${_interactionLabel(type)} logged · +$xp XP'),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(milliseconds: 1400),
        ),
      );
    }
  }

  Future<void> _editName(BuildContext context, Person person) async {
    final controller = TextEditingController(text: person.name);

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: TetherColors.surface,
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            22,
            20,
            MediaQuery.viewInsetsOf(sheetContext).bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'EDIT BOND',
                style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 2),
              ),
              const SizedBox(height: 18),
              TextField(
                controller: controller,
                autofocus: true,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    final name = controller.text.trim();
                    if (name.isNotEmpty) {
                      context.read<RelationshipProvider>().save(
                        person.copyWith(name: name),
                      );
                    }
                    Navigator.pop(sheetContext);
                  },
                  child: const Text('SAVE CHANGES'),
                ),
              ),
            ],
          ),
        );
      },
    );

    controller.dispose();
  }

  Future<void> _addNote(BuildContext context, Person person) async {
    final controller = TextEditingController();

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: TetherColors.surface,
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            22,
            20,
            MediaQuery.viewInsetsOf(sheetContext).bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'CAPTURE MEMORY',
                style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 2),
              ),
              const SizedBox(height: 18),
              TextField(
                controller: controller,
                autofocus: true,
                maxLines: 5,
                decoration: const InputDecoration(
                  hintText: 'What should TETHER remember?',
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    final note = controller.text.trim();
                    if (note.isNotEmpty) {
                      context.read<RelationshipProvider>().addNote(
                        person.id,
                        note,
                      );
                    }
                    Navigator.pop(sheetContext);
                  },
                  child: const Text('STORE MEMORY'),
                ),
              ),
            ],
          ),
        );
      },
    );

    controller.dispose();
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.person, required this.accent});

  final Person person;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final xpProgress = (person.bondXp / 1000).clamp(0.0, 1.0).toDouble();
    final cadenceProgress =
        (person.recentInteractions.clamp(0, 7) / 7).toDouble();

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: TetherColors.line),
        gradient: const LinearGradient(
          colors: [TetherColors.surfaceRaised, TetherColors.surface],
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _Avatar(person: person, accent: accent),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      person.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _healthLabel(person.state),
                      style: TextStyle(
                        color: accent,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
              _Score(person: person, accent: accent),
            ],
          ),
          const SizedBox(height: 26),
          _Metric(
            label: 'BOND XP',
            value: '${person.bondXp} / 1000',
            progress: xpProgress,
            accent: accent,
          ),
          const SizedBox(height: 14),
          _Metric(
            label: 'CONTACT CADENCE',
            value: '${person.recentInteractions} / 7',
            progress: cadenceProgress,
            accent: accent,
          ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.person, required this.accent});

  final Person person;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: accent.withValues(alpha: 0.1),
        border: Border.all(color: accent.withValues(alpha: 0.4), width: 2),
      ),
      child: Text(
        person.initials,
        style: TextStyle(
          color: accent,
          fontSize: 18,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _Score extends StatelessWidget {
  const _Score({required this.person, required this.accent});

  final Person person;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final score = (person.bondXp / 10).round().clamp(0, 100);
    return Container(
      width: 62,
      height: 62,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: accent.withValues(alpha: 0.5), width: 2),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$score',
            style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900),
          ),
          const Text(
            'SCORE',
            style: TextStyle(
              fontSize: 7,
              color: TetherColors.muted,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({
    required this.label,
    required this.value,
    required this.progress,
    required this.accent,
  });

  final String label;
  final String value;
  final double progress;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: TetherColors.muted,
                fontSize: 8,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
              ),
            ),
            Text(
              value,
              style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800),
            ),
          ],
        ),
        const SizedBox(height: 7),
        ClipRRect(
          borderRadius: BorderRadius.circular(99),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 5,
            backgroundColor: TetherColors.line,
            valueColor: AlwaysStoppedAnimation<Color>(accent),
          ),
        ),
      ],
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.onChat,
    required this.onCall,
    required this.onPlan,
    required this.onNote,
  });

  final VoidCallback onChat;
  final VoidCallback onCall;
  final VoidCallback onPlan;
  final VoidCallback onNote;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _Action(icon: Icons.chat_bubble_outline_rounded, label: 'CHAT', onTap: onChat)),
        const SizedBox(width: 8),
        Expanded(child: _Action(icon: Icons.call_outlined, label: 'CALL', onTap: onCall)),
        const SizedBox(width: 8),
        Expanded(child: _Action(icon: Icons.event_available_outlined, label: 'PLAN', onTap: onPlan)),
        const SizedBox(width: 8),
        Expanded(child: _Action(icon: Icons.notes_rounded, label: 'NOTE', onTap: onNote)),
      ],
    );
  }
}

class _Action extends StatelessWidget {
  const _Action({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: TetherColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 13),
          child: Column(
            children: [
              Icon(icon, size: 17),
              const SizedBox(height: 5),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 7,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NextAction extends StatelessWidget {
  const _NextAction({required this.person});

  final Person person;

  @override
  Widget build(BuildContext context) {
    final message = person.recentInteractions == 0
        ? 'Start the relationship with a meaningful touchpoint.'
        : 'Keep the bond active with a meaningful touchpoint.';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TetherColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: TetherColors.line),
      ),
      child: Row(
        children: [
          const Icon(Icons.auto_awesome_rounded, color: TetherColors.neon, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'NEXT BEST ACTION',
                  style: TextStyle(
                    fontSize: 8,
                    color: TetherColors.muted,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Heading extends StatelessWidget {
  const _Heading({required this.title, required this.trailing});

  final String title;
  final String trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
          ),
        ),
        Text(
          trailing,
          style: const TextStyle(
            fontSize: 8,
            color: TetherColors.muted,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _SignalRow extends StatelessWidget {
  const _SignalRow({required this.person});

  final Person person;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _Signal(value: '${person.recentInteractions}', label: 'TOUCHPOINTS')),
        const SizedBox(width: 8),
        Expanded(child: _Signal(value: '${person.memoryCount}', label: 'MEMORIES')),
        const SizedBox(width: 8),
        Expanded(child: _Signal(value: '${person.tags.length}', label: 'TAGS')),
      ],
    );
  }
}

class _Signal extends StatelessWidget {
  const _Signal({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: TetherColors.surface,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: TetherColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: TetherColors.muted,
              fontSize: 7,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineList extends StatelessWidget {
  const _TimelineList({required this.interactions});

  final List<Interaction> interactions;

  @override
  Widget build(BuildContext context) {
    if (interactions.isEmpty) {
      return const _EmptyTimeline();
    }

    return Column(
      children: interactions
          .map((interaction) => _TimelineEvent(interaction: interaction))
          .toList(growable: false),
    );
  }
}

class _TimelineEvent extends StatelessWidget {
  const _TimelineEvent({required this.interaction});

  final Interaction interaction;

  @override
  Widget build(BuildContext context) {
    final accent = _interactionColor(interaction.type);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: TetherColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: TetherColors.line),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(_interactionIcon(interaction.type), size: 16, color: accent),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        interaction.title,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
                      ),
                    ),
                    Text(
                      _date(interaction.occurredAt),
                      style: const TextStyle(color: TetherColors.muted, fontSize: 8),
                    ),
                  ],
                ),
                if (interaction.description.isNotEmpty) ...[
                  const SizedBox(height: 5),
                  Text(
                    interaction.description,
                    style: const TextStyle(
                      color: TetherColors.muted,
                      fontSize: 10.5,
                      height: 1.35,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MemoryBank extends StatelessWidget {
  const _MemoryBank({required this.person});

  final Person person;

  @override
  Widget build(BuildContext context) {
    final notes = person.notes.take(4).toList(growable: false);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TetherColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: TetherColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (person.tags.isNotEmpty) _TagList(tags: person.tags),
          if (person.tags.isNotEmpty && notes.isNotEmpty)
            const SizedBox(height: 12),
          if (notes.isEmpty)
            const Text(
              'No memories captured yet.',
              style: TextStyle(color: TetherColors.muted, fontSize: 11),
            )
          else
            ...notes.map((note) => _MemoryNote(note: note)),
        ],
      ),
    );
  }
}

class _TagList extends StatelessWidget {
  const _TagList({required this.tags});

  final List<String> tags;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 7,
      runSpacing: 7,
      children: tags
          .map(
            (tag) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: TetherColors.violet.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(99),
              ),
              child: Text(
                tag,
                style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700),
              ),
            ),
          )
          .toList(growable: false),
    );
  }
}

class _MemoryNote extends StatelessWidget {
  const _MemoryNote({required this.note});

  final String note;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.auto_awesome_rounded, size: 13, color: TetherColors.neon),
          const SizedBox(width: 9),
          Expanded(
            child: Text(note, style: const TextStyle(fontSize: 11, height: 1.4)),
          ),
        ],
      ),
    );
  }
}

class _EmptyTimeline extends StatelessWidget {
  const _EmptyTimeline();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: TetherColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: TetherColors.line),
      ),
      child: const Row(
        children: [
          Icon(Icons.timeline_rounded, color: TetherColors.muted),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'No interaction history yet. Your first meaningful touchpoint will establish the timeline.',
              style: TextStyle(color: TetherColors.muted, fontSize: 11, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}

String _healthLabel(BondState state) {
  switch (state) {
    case BondState.thriving:
      return 'THRIVING';
    case BondState.strong:
      return 'STRONG';
    case BondState.steady:
      return 'STEADY';
    case BondState.needsAttention:
      return 'NEEDS ATTENTION';
  }
}

Color _healthColor(BondState state) {
  switch (state) {
    case BondState.thriving:
      return TetherColors.neon;
    case BondState.strong:
      return TetherColors.violet;
    case BondState.steady:
      return TetherColors.text;
    case BondState.needsAttention:
      return TetherColors.danger;
  }
}

Color _interactionColor(InteractionType type) {
  switch (type) {
    case InteractionType.call:
      return TetherColors.violet;
    case InteractionType.note:
      return TetherColors.neon;
    case InteractionType.conversation:
      return TetherColors.text;
    case InteractionType.memory:
      return TetherColors.neon;
  }
}

IconData _interactionIcon(InteractionType type) {
  switch (type) {
    case InteractionType.conversation:
      return Icons.chat_bubble_outline_rounded;
    case InteractionType.call:
      return Icons.call_outlined;
    case InteractionType.note:
      return Icons.event_available_outlined;
    case InteractionType.memory:
      return Icons.auto_awesome_rounded;
  }
}

String _interactionLabel(InteractionType type) {
  switch (type) {
    case InteractionType.conversation:
      return 'Conversation';
    case InteractionType.call:
      return 'Call';
    case InteractionType.note:
      return 'Activity';
    case InteractionType.memory:
      return 'Memory';
  }
}

String _date(DateTime date) => '${date.month}/${date.day}';

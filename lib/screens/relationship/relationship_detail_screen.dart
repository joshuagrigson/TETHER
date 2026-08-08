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
    final health = _healthLabel(person.state);
    final accent = _healthColor(person.state);

    return Scaffold(
      backgroundColor: TetherColors.obsidian,
      appBar: AppBar(
        backgroundColor: TetherColors.obsidian,
        titleSpacing: 20,
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
          _TopIcon(
            icon: Icons.edit_outlined,
            tooltip: 'Edit relationship',
            onPressed: () => _showEditSheet(context, person),
          ),
          const SizedBox(width: 6),
          _TopIcon(
            icon: Icons.more_horiz_rounded,
            tooltip: 'More',
            onPressed: () => _showMoreSheet(context, person),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 6, 20, 16),
            sliver: SliverToBoxAdapter(
              child: _IdentityHero(
                person: person,
                health: health,
                accent: accent,
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverToBoxAdapter(
              child: _ActionDock(
                onConversation: () => _recordInteraction(
                  context,
                  person,
                  InteractionType.conversation,
                  25,
                ),
                onCall: () => _recordInteraction(
                  context,
                  person,
                  InteractionType.call,
                  35,
                ),
                onPlan: () => _recordInteraction(
                  context,
                  person,
                  InteractionType.note,
                  20,
                ),
                onNote: () => _showNote(context, person),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 26, 20, 10),
            sliver: SliverToBoxAdapter(
              child: _NextBestAction(person: person),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            sliver: SliverToBoxAdapter(
              child: _SectionHeading(
                title: 'BOND SIGNALS',
                trailing: '${person.bondXp} XP',
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverToBoxAdapter(
              child: _SignalGrid(person: person, accent: accent),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 28, 20, 8),
            sliver: SliverToBoxAdapter(
              child: _SectionHeading(
                title: 'RELATIONSHIP TIMELINE',
                trailing: '${interactions.length} EVENTS',
              ),
            ),
          ),
          if (interactions.isEmpty)
            const SliverPadding(
              padding: EdgeInsets.fromLTRB(20, 8, 20, 0),
              sliver: SliverToBoxAdapter(child: _EmptyTimeline()),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              sliver: SliverList.builder(
                itemCount: interactions.length,
                itemBuilder: (context, index) => _TimelineEvent(
                  interaction: interactions[index],
                  isLast: index == interactions.length - 1,
                ),
              ),
            ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 30, 20, 8),
            sliver: SliverToBoxAdapter(
              child: _SectionHeading(
                title: 'MEMORY BANK',
                trailing: '${person.memoryCount} MEMORIES',
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 34),
            sliver: SliverToBoxAdapter(
              child: _MemoryBank(person: person),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _recordInteraction(
    BuildContext context,
    Person person,
    InteractionType type,
    int xp,
  ) async {
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

  Future<void> _showEditSheet(BuildContext context, Person person) async {
    final controller = TextEditingController(text: person.name);
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: TetherColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          22,
          20,
          MediaQuery.viewInsetsOf(sheetContext).bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'EDIT BOND',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Keep the identity layer accurate. TETHER uses this profile as the anchor for relationship intelligence.',
              style: TextStyle(color: TetherColors.muted, height: 1.4),
            ),
            const SizedBox(height: 18),
            TextField(
              controller: controller,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Name',
                prefixIcon: Icon(Icons.person_outline_rounded),
              ),
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
      ),
    );
    controller.dispose();
  }

  Future<void> _showNote(BuildContext context, Person person) async {
    final controller = TextEditingController();
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: TetherColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          22,
          20,
          MediaQuery.viewInsetsOf(sheetContext).bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'CAPTURE MEMORY',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Save something future-you will be glad TETHER remembered.',
              style: TextStyle(color: TetherColors.muted),
            ),
            const SizedBox(height: 18),
            TextField(
              controller: controller,
              autofocus: true,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: 'What should TETHER remember?',
                alignLabelWithHint: true,
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
      ),
    );
    controller.dispose();
  }

  Future<void> _showMoreSheet(BuildContext context, Person person) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: TetherColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const _SheetHandle(),
              _SheetAction(
                icon: Icons.add_comment_outlined,
                title: 'Log interaction',
                subtitle: 'Add a conversation, call, or activity event.',
                onTap: () {
                  Navigator.pop(sheetContext);
                  _showInteractionSheet(context, person);
                },
              ),
              _SheetAction(
                icon: Icons.notes_rounded,
                title: 'Capture memory',
                subtitle: 'Store a note, detail, or important moment.',
                onTap: () {
                  Navigator.pop(sheetContext);
                  _showNote(context, person);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showInteractionSheet(
    BuildContext context,
    Person person,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: TetherColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _SheetHandle(),
              const Text(
                'LOG ACTIVITY',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 16),
              _SheetAction(
                icon: Icons.chat_bubble_outline_rounded,
                title: 'Conversation',
                subtitle: '+25 XP · refreshes contact cadence',
                onTap: () {
                  Navigator.pop(sheetContext);
                  _recordInteraction(
                    context,
                    person,
                    InteractionType.conversation,
                    25,
                  );
                },
              ),
              _SheetAction(
                icon: Icons.call_outlined,
                title: 'Call',
                subtitle: '+35 XP · strongest contact signal',
                onTap: () {
                  Navigator.pop(sheetContext);
                  _recordInteraction(
                    context,
                    person,
                    InteractionType.call,
                    35,
                  );
                },
              ),
              _SheetAction(
                icon: Icons.event_available_outlined,
                title: 'Plan activity',
                subtitle: '+20 XP · records intentional time together',
                onTap: () {
                  Navigator.pop(sheetContext);
                  _recordInteraction(
                    context,
                    person,
                    InteractionType.note,
                    20,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopIcon extends StatelessWidget {
  const _TopIcon({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => IconButton(
        tooltip: tooltip,
        onPressed: onPressed,
        icon: Icon(icon, size: 19),
        style: IconButton.styleFrom(
          backgroundColor: TetherColors.surface,
          foregroundColor: TetherColors.text,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(13),
          ),
        ),
      );
}

class _IdentityHero extends StatelessWidget {
  const _IdentityHero({
    required this.person,
    required this.health,
    required this.accent,
  });

  final Person person;
  final String health;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final xpProgress = (person.bondXp / 1000).clamp(0.0, 1.0);
    final cadenceProgress =
        (person.recentInteractions.clamp(0, 7) / 7).toDouble();

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: TetherColors.line),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [TetherColors.surfaceRaised, TetherColors.surface],
        ),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: .045),
            blurRadius: 36,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              _Avatar(initials: person.initials, accent: accent),
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
                        fontSize: 27,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color: accent,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: accent.withValues(alpha: .5),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 7),
                        Text(
                          health,
                          style: TextStyle(
                            color: accent,
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.7,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              _BondScore(
                value: (person.bondXp / 10).round().clamp(0, 100),
                accent: accent,
              ),
            ],
          ),
          const SizedBox(height: 26),
          _MetricBar(
            label: 'BOND XP',
            value: '${person.bondXp}',
            progress: xpProgress,
            accent: accent,
          ),
          const SizedBox(height: 16),
          _MetricBar(
            label: 'CONTACT CADENCE',
            value: person.cadence.name.toUpperCase(),
            progress: cadenceProgress,
            accent: TetherColors.violet,
          ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.initials, required this.accent});
  final String initials;
  final Color accent;

  @override
  Widget build(BuildContext context) => Container(
        width: 68,
        height: 68,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: accent.withValues(alpha: .09),
          border: Border.all(color: accent.withValues(alpha: .45), width: 1.4),
          boxShadow: [
            BoxShadow(color: accent.withValues(alpha: .09), blurRadius: 22),
          ],
        ),
        child: Text(
          initials,
          style: TextStyle(
            color: accent,
            fontSize: 20,
            fontWeight: FontWeight.w900,
            letterSpacing: 1,
          ),
        ),
      );
}

class _BondScore extends StatelessWidget {
  const _BondScore({required this.value, required this.accent});
  final int value;
  final Color accent;

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Text(
            '$value',
            style: TextStyle(
              color: accent,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const Text(
            'BOND',
            style: TextStyle(
              color: TetherColors.muted,
              fontSize: 7,
              letterSpacing: 1.6,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      );
}

class _MetricBar extends StatelessWidget {
  const _MetricBar({
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
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: TetherColors.muted,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  color: accent,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: .8,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 5,
              backgroundColor: TetherColors.line,
              color: accent,
            ),
          ),
        ],
      );
}

class _ActionDock extends StatelessWidget {
  const _ActionDock({
    required this.onConversation,
    required this.onCall,
    required this.onPlan,
    required this.onNote,
  });

  final VoidCallback onConversation;
  final VoidCallback onCall;
  final VoidCallback onPlan;
  final VoidCallback onNote;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Expanded(
            child: _ActionButton(
              icon: Icons.chat_bubble_outline_rounded,
              label: 'MESSAGE',
              onTap: onConversation,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _ActionButton(
              icon: Icons.call_outlined,
              label: 'CALL',
              onTap: onCall,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _ActionButton(
              icon: Icons.event_available_outlined,
              label: 'PLAN',
              onTap: onPlan,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _ActionButton(
              icon: Icons.notes_rounded,
              label: 'NOTE',
              onTap: onNote,
            ),
          ),
        ],
      );
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
        color: TetherColors.surface,
        borderRadius: BorderRadius.circular(17),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(17),
          child: Container(
            height: 70,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(17),
              border: Border.all(color: TetherColors.line),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 20, color: TetherColors.neon),
                const SizedBox(height: 6),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 7.5,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.1,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}

class _NextBestAction extends StatelessWidget {
  const _NextBestAction({required this.person});
  final Person person;

  @override
  Widget build(BuildContext context) {
    final attention = person.state == BondState.needsAttention;
    final accent = attention ? TetherColors.danger : TetherColors.neon;
    final title = attention ? 'RECONNECT SOON' : 'KEEP THE BOND MOVING';
    final body = attention
        ? 'This relationship is showing signs of drift. A real conversation is the highest-value next move.'
        : person.cadence == Cadence.daily
            ? 'A meaningful touchpoint today keeps this bond inside its intended cadence.'
            : 'Your recent activity is healthy. An intentional touchpoint will reinforce the current trajectory.';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: accent.withValues(alpha: .055),
        border: Border.all(color: accent.withValues(alpha: .28)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: .12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(Icons.auto_awesome_rounded, color: accent, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'NEXT BEST ACTION',
                  style: TextStyle(
                    color: accent,
                    fontSize: 8,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.6,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  body,
                  style: const TextStyle(
                    color: TetherColors.muted,
                    fontSize: 11,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.title, required this.trailing});
  final String title;
  final String trailing;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: TetherColors.muted,
                fontSize: 9,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.8,
              ),
            ),
          ),
          Text(
            trailing,
            style: const TextStyle(
              color: TetherColors.muted,
              fontSize: 8,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
            ),
          ),
        ],
      );
}

class _SignalGrid extends StatelessWidget {
  const _SignalGrid({required this.person, required this.accent});
  final Person person;
  final Color accent;

  @override
  Widget build(BuildContext context) => GridView.count(
        crossAxisCount: 3,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 8,
        childAspectRatio: 1.35,
        children: [
          _Signal(value: '${person.recentInteractions}', label: 'TOUCHPOINTS'),
          _Signal(value: '${person.memoryCount}', label: 'MEMORIES'),
          _Signal(value: '${person.tags.length}', label: 'TAGS'),
        ],
      );
}

class _Signal extends StatelessWidget {
  const _Signal({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) => Container(
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
                letterSpacing: .8,
              ),
            ),
          ],
        ),
      );
}

class _TimelineEvent extends StatelessWidget {
  const _TimelineEvent({required this.interaction, required this.isLast});
  final Interaction interaction;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final accent = interaction.type == InteractionType.call
        ? TetherColors.violet
        : interaction.type == InteractionType.note
            ? TetherColors.neon
            : TetherColors.text;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 34,
            child: Column(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: .1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: accent.withValues(alpha: .25)),
                  ),
                  child: Icon(_interactionIcon(interaction.type), size: 15, color: accent),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 1,
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      color: TetherColors.line,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.fromLTRB(15, 13, 15, 13),
              decoration: BoxDecoration(
                color: TetherColors.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: TetherColors.line),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          interaction.title,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      Text(
                        _date(interaction.occurredAt),
                        style: const TextStyle(
                          color: TetherColors.muted,
                          fontSize: 8,
                        ),
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
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: TetherColors.surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: TetherColors.line),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (person.tags.isNotEmpty) ...[
              Wrap(
                spacing: 7,
                runSpacing: 7,
                children: person.tags
                    .map(
                      (tag) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: TetherColors.violet.withValues(alpha: .08),
                          borderRadius: BorderRadius.circular(99),
                          border: Border.all(
                            color: TetherColors.violet.withValues(alpha: .2),
                          ),
                        ),
                        child: Text(
                          tag,
                          style: const TextStyle(
                            color: TetherColors.text,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 12),
            ],
            if (person.notes.isEmpty)
              const Text(
                'No memories captured yet.',
                style: TextStyle(color: TetherColors.muted, fontSize: 11),
              )
            else
              ...person.notes.take(4).map(
                    (note) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(top: 2),
                            child: Icon(
                              Icons.auto_awesome_rounded,
                              size: 13,
                              color: TetherColors.neon,
                            ),
                          ),
                          const SizedBox(width: 9),
                          Expanded(
                            child: Text(
                              note,
                              style: const TextStyle(
                                fontSize: 11,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          ],
        ),
      );
}

class _EmptyTimeline extends StatelessWidget {
  const _EmptyTimeline();

  @override
  Widget build(BuildContext context) => Container(
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
                style: TextStyle(
                  color: TetherColors.muted,
                  fontSize: 11,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      );
}

class _SheetHandle extends StatelessWidget {
  const _SheetHandle();

  @override
  Widget build(BuildContext context) => Center(
        child: Container(
          width: 36,
          height: 4,
          margin: const EdgeInsets.only(bottom: 18),
          decoration: BoxDecoration(
            color: TetherColors.line,
            borderRadius: BorderRadius.circular(99),
          ),
        ),
      );
}

class _SheetAction extends StatelessWidget {
  const _SheetAction({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Material(
          color: TetherColors.surfaceRaised,
          borderRadius: BorderRadius.circular(17),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(17),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: TetherColors.neon.withValues(alpha: .08),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: const Icon(
                      Icons.arrow_forward_rounded,
                      color: TetherColors.neon,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          subtitle,
                          style: const TextStyle(
                            color: TetherColors.muted,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(icon, color: TetherColors.muted, size: 18),
                ],
              ),
            ),
          ),
        ),
      );

String _healthLabel(BondState state) => switch (state) {
      BondState.thriving => 'THRIVING',
      BondState.strong => 'STRONG',
      BondState.steady => 'STEADY',
      BondState.needsAttention => 'NEEDS ATTENTION',
    };

Color _healthColor(BondState state) => switch (state) {
      BondState.thriving => TetherColors.neon,
      BondState.strong => TetherColors.violet,
      BondState.steady => TetherColors.text,
      BondState.needsAttention => TetherColors.danger,
    };

String _interactionLabel(InteractionType type) => switch (type) {
      InteractionType.conversation => 'Conversation',
      InteractionType.call => 'Call',
      InteractionType.note => 'Activity',
      InteractionType.memory => 'Memory',
    };

IconData _interactionIcon(InteractionType type) => switch (type) {
      InteractionType.conversation => Icons.chat_bubble_outline_rounded,
      InteractionType.call => Icons.call_outlined,
      InteractionType.note => Icons.event_available_outlined,
      InteractionType.memory => Icons.auto_awesome_rounded,
    };

String _date(DateTime date) {
  final now = DateTime.now();
  final difference = now.difference(date);
  if (difference.inMinutes < 1) return 'NOW';
  if (difference.inHours < 1) return '${difference.inMinutes}M';
  if (difference.inDays < 1) return '${difference.inHours}H';
  if (difference.inDays < 7) return '${difference.inDays}D';
  return '${date.month}/${date.day}';
}

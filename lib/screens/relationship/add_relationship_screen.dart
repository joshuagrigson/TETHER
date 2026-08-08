import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/tether_theme.dart';
import '../../models/person.dart';
import '../../providers/relationship_provider.dart';

class AddRelationshipScreen extends StatefulWidget {
  const AddRelationshipScreen({super.key});

  @override
  State<AddRelationshipScreen> createState() => _AddRelationshipScreenState();
}

class _AddRelationshipScreenState extends State<AddRelationshipScreen> {
  final _nameController = TextEditingController();
  Cadence _cadence = Cadence.weekly;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _save() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Give this relationship a name first.')),
      );
      return;
    }

    final parts = name.split(RegExp(r'\s+')).where((part) => part.isNotEmpty).toList();
    final initials = parts.take(2).map((part) => part[0].toUpperCase()).join();
    final id = DateTime.now().microsecondsSinceEpoch.toString();

    context.read<RelationshipProvider>().save(
      Person(
        id: id,
        name: name,
        initials: initials.isEmpty ? '?' : initials,
        bondXp: 0,
        recentInteractions: 0,
        cadence: _cadence,
        state: BondState.needsAttention,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TetherColors.obsidian,
      appBar: AppBar(
        backgroundColor: TetherColors.obsidian,
        title: const Text(
          'NEW BOND',
          style: TextStyle(
            color: TetherColors.muted,
            letterSpacing: 2.2,
            fontSize: 10,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            const _BondIntro(),
            const SizedBox(height: 18),
            _FieldCard(
              child: TextField(
                controller: _nameController,
                autofocus: true,
                textCapitalization: TextCapitalization.words,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                decoration: const InputDecoration(
                  labelText: 'PERSON',
                  hintText: 'Who matters to you?',
                  prefixIcon: Icon(Icons.person_outline_rounded),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                ),
              ),
            ),
            const SizedBox(height: 12),
            _FieldCard(
              child: DropdownButtonFormField<Cadence>(
                initialValue: _cadence,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'IDEAL CADENCE',
                  prefixIcon: Icon(Icons.schedule_rounded),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 4),
                ),
                items: Cadence.values
                    .map(
                      (value) => DropdownMenuItem(
                        value: value,
                        child: Text(value.name.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w800)),
                      ),
                    )
                    .toList(),
                onChanged: (value) => setState(() => _cadence = value ?? Cadence.weekly),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: TetherColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: TetherColors.line),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.auto_awesome_rounded, color: TetherColors.neon, size: 18),
                  SizedBox(width: 11),
                  Expanded(
                    child: Text(
                      'You can add memories, tags, important dates, and interaction history after the bond is created.',
                      style: TextStyle(color: TetherColors.muted, fontSize: 11, height: 1.45),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            SizedBox(
              height: 56,
              child: FilledButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.link_rounded),
                label: const Text(
                  'CREATE BOND',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.7),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: TetherColors.neon,
                  foregroundColor: TetherColors.obsidian,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BondIntro extends StatelessWidget {
  const _BondIntro();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: TetherColors.line),
        gradient: const LinearGradient(colors: [TetherColors.surfaceRaised, TetherColors.surface]),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'BUILD THE BOND',
            style: TextStyle(color: TetherColors.neon, fontSize: 9, letterSpacing: 2.2, fontWeight: FontWeight.w900),
          ),
          SizedBox(height: 10),
          Text(
            'Who should TETHER\nremember?',
            style: TextStyle(fontSize: 28, height: 1.05, fontWeight: FontWeight.w900, letterSpacing: -.6),
          ),
          SizedBox(height: 10),
          Text(
            'Start with the person. TETHER builds the relationship intelligence around them as you interact.',
            style: TextStyle(color: TetherColors.muted, fontSize: 12, height: 1.45),
          ),
        ],
      ),
    );
  }
}

class _FieldCard extends StatelessWidget {
  const _FieldCard({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: TetherColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: TetherColors.line),
      ),
      child: child,
    );
  }
}

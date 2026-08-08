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
    if (name.isEmpty) return;

    final initials = name
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .take(2)
        .map((part) => part[0].toUpperCase())
        .join();

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
      appBar: AppBar(
        title: const Text(
          'NEW RELATIONSHIP',
          style: TextStyle(
            letterSpacing: 2,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: TetherColors.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: TetherColors.line),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'BUILD THE BOND',
                  style: TextStyle(
                    color: TetherColors.neon,
                    fontSize: 11,
                    letterSpacing: 2,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Who should TETHER remember?',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                ),
                SizedBox(height: 8),
                Text(
                  'Start with a name. You can enrich the relationship later with notes, memories, tags, and important dates.',
                  style: TextStyle(color: TetherColors.muted, height: 1.4),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          TextField(
            controller: _nameController,
            autofocus: true,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Name',
              hintText: 'e.g. Taylor',
              prefixIcon: Icon(Icons.person_outline_rounded),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 18),
          DropdownButtonFormField<Cadence>(
            initialValue: _cadence,
            decoration: const InputDecoration(
              labelText: 'Ideal cadence',
              prefixIcon: Icon(Icons.schedule_rounded),
              border: OutlineInputBorder(),
            ),
            items: Cadence.values
                .map(
                  (value) => DropdownMenuItem(
                    value: value,
                    child: Text(value.name.toUpperCase()),
                  ),
                )
                .toList(),
            onChanged: (value) {
              setState(() => _cadence = value ?? Cadence.weekly);
            },
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _save,
            icon: const Icon(Icons.add_rounded),
            label: const Padding(
              padding: EdgeInsets.symmetric(vertical: 14),
              child: Text('CREATE RELATIONSHIP'),
            ),
          ),
        ],
      ),
    );
  }
}

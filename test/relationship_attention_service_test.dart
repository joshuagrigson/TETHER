import 'package:flutter_test/flutter_test.dart';
import 'package:tether/models/person.dart';
import 'package:tether/services/relationship_attention_service.dart';

void main() {
  const service = RelationshipAttentionService();
  final now = DateTime(2026, 8, 8, 12);

  test('prioritizes an overdue relationship above a thriving one', () {
    final overdue = Person(id: '1', name: 'Overdue', initials: 'O', bondXp: 100, recentInteractions: 1, cadence: Cadence.weekly, state: BondState.needsAttention, lastInteractionAt: DateTime(2026, 7, 20));
    final thriving = Person(id: '2', name: 'Thriving', initials: 'T', bondXp: 900, recentInteractions: 6, cadence: Cadence.weekly, state: BondState.thriving, lastInteractionAt: DateTime(2026, 8, 7));

    expect(service.prioritize([thriving, overdue], now: now).first.name, 'Overdue');
  });

  test('new relationships are surfaced immediately', () {
    const person = Person(id: '1', name: 'New', initials: 'N', bondXp: 0, recentInteractions: 0, cadence: Cadence.weekly, state: BondState.needsAttention);
    expect(service.prioritize([person], now: now).single, person);
    expect(service.reason(person, now: now), 'No interaction recorded yet');
  });

  test('reports overdue days', () {
    final person = Person(id: '1', name: 'A', initials: 'A', bondXp: 100, recentInteractions: 1, cadence: Cadence.weekly, state: BondState.steady, lastInteractionAt: DateTime(2026, 7, 25));
    expect(service.reason(person, now: now), '7 days overdue');
  });
}

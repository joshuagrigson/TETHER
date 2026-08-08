import 'package:flutter_test/flutter_test.dart';

import 'package:tether/models/person.dart';
import 'package:tether/services/relationship_attention_service.dart';

void main() {
  const service = RelationshipAttentionService();
  final now = DateTime(2026, 8, 8, 12);

  Person person({
    String id = '1',
    String name = 'Alex',
    BondState state = BondState.strong,
    Cadence cadence = Cadence.weekly,
    DateTime? lastInteractionAt,
    int memoryCount = 1,
    List<String> importantDates = const [],
  }) => Person(
        id: id,
        name: name,
        initials: 'A',
        bondXp: 500,
        recentInteractions: 2,
        cadence: cadence,
        state: state,
        memoryCount: memoryCount,
        importantDates: importantDates,
        lastInteractionAt: lastInteractionAt,
      );

  test('prioritizes people with no recorded interaction', () {
    final untouched = person(id: 'untouched', lastInteractionAt: null);
    final recent = person(
      id: 'recent',
      lastInteractionAt: now.subtract(const Duration(days: 1)),
    );

    final ranked = service.prioritize([recent, untouched], now: now);

    expect(ranked.first.id, 'untouched');
    expect(service.reason(untouched, now: now), contains('first touchpoint'));
  });

  test('identifies cadence overdue relationships', () {
    final p = person(
      lastInteractionAt: now.subtract(const Duration(days: 10)),
      cadence: Cadence.weekly,
    );

    expect(service.score(p, now: now), greaterThan(0));
    expect(service.reason(p, now: now), 'Past your weekly cadence');
    expect(service.nextBestAction(p, now: now), 'Reach out today');
  });

  test('gives declining bonds a meaningful next action', () {
    final p = person(
      state: BondState.needsAttention,
      lastInteractionAt: now.subtract(const Duration(days: 2)),
      memoryCount: 2,
    );

    expect(service.reason(p, now: now), 'Bond health is declining');
    expect(
      service.nextBestAction(p, now: now),
      'Reconnect with a meaningful conversation',
    );
  });

  test('surfaces missing context when a bond has no memories', () {
    final p = person(
      lastInteractionAt: now.subtract(const Duration(hours: 12)),
      memoryCount: 0,
    );

    expect(
      service.reason(p, now: now),
      'Capture a memory to strengthen context',
    );
    expect(
      service.nextBestAction(p, now: now),
      'Capture something worth remembering',
    );
  });
}

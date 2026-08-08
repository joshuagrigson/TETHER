import 'package:flutter_test/flutter_test.dart';
import 'package:tether/models/person.dart';
import 'package:tether/services/reminder_service.dart';

void main() {
  const service = ReminderService();

  test('daily cadence becomes due after one day', () {
    final last = DateTime(2026, 8, 1, 9);
    final person = Person(id: '1', name: 'A', initials: 'A', bondXp: 10, recentInteractions: 1, cadence: Cadence.daily, state: BondState.steady, lastInteractionAt: last);
    expect(service.isDue(person, now: DateTime(2026, 8, 2, 9)), isTrue);
    expect(service.isDue(person, now: DateTime(2026, 8, 2, 8, 59)), isFalse);
  });

  test('weekly cadence calculates the next contact date', () {
    final last = DateTime(2026, 8, 1);
    final person = Person(id: '2', name: 'B', initials: 'B', bondXp: 10, recentInteractions: 1, cadence: Cadence.weekly, state: BondState.steady, lastInteractionAt: last);
    expect(service.nextDue(person), DateTime(2026, 8, 8));
  });

  test('relationships without a recorded interaction are immediately due', () {
    const person = Person(id: '3', name: 'C', initials: 'C', bondXp: 0, recentInteractions: 0, cadence: Cadence.weekly, state: BondState.needsAttention);
    expect(service.isDue(person, now: DateTime(2026, 8, 8)), isTrue);
  });
}

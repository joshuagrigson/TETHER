import 'package:flutter_test/flutter_test.dart';
import 'package:tether/models/person.dart';
import 'package:tether/services/relationship_health_service.dart';

void main() {
  const service = RelationshipHealthService();

  test('classifies a thriving relationship', () {
    const person = Person(id: '1', name: 'A', initials: 'A', bondXp: 900, recentInteractions: 6, cadence: Cadence.daily, state: BondState.thriving);
    expect(service.classify(person), BondState.thriving);
  });

  test('classifies a strong relationship', () {
    const person = Person(id: '2', name: 'B', initials: 'B', bondXp: 600, recentInteractions: 4, cadence: Cadence.weekly, state: BondState.strong);
    expect(service.classify(person), BondState.strong);
  });

  test('classifies a relationship needing attention', () {
    const person = Person(id: '3', name: 'C', initials: 'C', bondXp: 0, recentInteractions: 0, cadence: Cadence.weekly, state: BondState.needsAttention);
    expect(service.classify(person), BondState.needsAttention);
  });
}

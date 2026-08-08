import '../models/person.dart';

class RelationshipHealthService {
  const RelationshipHealthService();

  BondState classify(Person person) {
    if (person.recentInteractions >= 5 && person.bondXp >= 800) {
      return BondState.thriving;
    }
    if (person.recentInteractions >= 3 && person.bondXp >= 500) {
      return BondState.strong;
    }
    if (person.recentInteractions >= 1) {
      return BondState.steady;
    }
    return BondState.needsAttention;
  }
}

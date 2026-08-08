enum Cadence { daily, weekly, occasional }

enum BondState { thriving, strong, steady, needsAttention }

class Person {
  const Person({
    required this.id,
    required this.name,
    required this.initials,
    required this.bondXp,
    required this.recentInteractions,
    required this.cadence,
    required this.state,
  });

  final String id;
  final String name;
  final String initials;
  final int bondXp;
  final int recentInteractions;
  final Cadence cadence;
  final BondState state;
}

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
    this.notes = const [],
    this.tags = const [],
    this.importantDates = const [],
    this.memoryCount = 0,
  });

  final String id;
  final String name;
  final String initials;
  final int bondXp;
  final int recentInteractions;
  final Cadence cadence;
  final BondState state;
  final List<String> notes;
  final List<String> tags;
  final List<String> importantDates;
  final int memoryCount;

  Person copyWith({
    String? name,
    String? initials,
    int? bondXp,
    int? recentInteractions,
    Cadence? cadence,
    BondState? state,
    List<String>? notes,
    List<String>? tags,
    List<String>? importantDates,
    int? memoryCount,
  }) => Person(
    id: id,
    name: name ?? this.name,
    initials: initials ?? this.initials,
    bondXp: bondXp ?? this.bondXp,
    recentInteractions: recentInteractions ?? this.recentInteractions,
    cadence: cadence ?? this.cadence,
    state: state ?? this.state,
    notes: notes ?? this.notes,
    tags: tags ?? this.tags,
    importantDates: importantDates ?? this.importantDates,
    memoryCount: memoryCount ?? this.memoryCount,
  );
}

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
    this.lastInteractionAt,
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
  final DateTime? lastInteractionAt;

  Person copyWith({String? name, String? initials, int? bondXp, int? recentInteractions, Cadence? cadence, BondState? state, List<String>? notes, List<String>? tags, List<String>? importantDates, int? memoryCount, DateTime? lastInteractionAt}) => Person(
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
    lastInteractionAt: lastInteractionAt ?? this.lastInteractionAt,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'initials': initials,
    'bondXp': bondXp,
    'recentInteractions': recentInteractions,
    'cadence': cadence.name,
    'state': state.name,
    'notes': notes,
    'tags': tags,
    'importantDates': importantDates,
    'memoryCount': memoryCount,
    'lastInteractionAt': lastInteractionAt?.toIso8601String(),
  };

  factory Person.fromJson(Map<String, dynamic> json) => Person(
    id: json['id'] as String,
    name: json['name'] as String,
    initials: json['initials'] as String,
    bondXp: (json['bondXp'] as num).toInt(),
    recentInteractions: (json['recentInteractions'] as num).toInt(),
    cadence: Cadence.values.byName(json['cadence'] as String),
    state: BondState.values.byName(json['state'] as String),
    notes: List<String>.from(json['notes'] as List<dynamic>? ?? const []),
    tags: List<String>.from(json['tags'] as List<dynamic>? ?? const []),
    importantDates: List<String>.from(json['importantDates'] as List<dynamic>? ?? const []),
    memoryCount: (json['memoryCount'] as num?)?.toInt() ?? 0,
    lastInteractionAt: json['lastInteractionAt'] == null ? null : DateTime.tryParse(json['lastInteractionAt'] as String),
  );
}

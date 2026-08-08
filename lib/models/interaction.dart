enum InteractionType { conversation, call, note, memory }

class Interaction {
  const Interaction({
    required this.id,
    required this.personId,
    required this.type,
    required this.title,
    required this.description,
    required this.occurredAt,
  });

  final String id;
  final String personId;
  final InteractionType type;
  final String title;
  final String description;
  final DateTime occurredAt;

  Map<String, dynamic> toJson() => {
    'id': id,
    'personId': personId,
    'type': type.name,
    'title': title,
    'description': description,
    'occurredAt': occurredAt.toIso8601String(),
  };

  factory Interaction.fromJson(Map<String, dynamic> json) => Interaction(
    id: json['id'] as String,
    personId: json['personId'] as String,
    type: InteractionType.values.byName(json['type'] as String),
    title: json['title'] as String,
    description: json['description'] as String,
    occurredAt: DateTime.parse(json['occurredAt'] as String),
  );
}

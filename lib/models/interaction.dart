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
}

import '../models/person.dart';
import 'reminder_service.dart';

class RelationshipPriority {
  const RelationshipPriority({
    required this.person,
    required this.headline,
    required this.detail,
    required this.action,
    required this.score,
  });

  final Person person;
  final String headline;
  final String detail;
  final String action;
  final int score;
}

class RelationshipAttentionService {
  const RelationshipAttentionService({ReminderService reminderService = const ReminderService()})
      : _reminderService = reminderService;

  final ReminderService _reminderService;

  List<Person> prioritize(List<Person> people, {DateTime? now, int limit = 5}) {
    final reference = now ?? DateTime.now();
    final ranked = people.toList()
      ..sort((a, b) => score(b, now: reference).compareTo(score(a, now: reference)));
    return ranked.take(limit).toList(growable: false);
  }

  List<RelationshipPriority> prioritizeWithIntelligence(
    List<Person> people, {
    DateTime? now,
    int limit = 5,
  }) {
    final reference = now ?? DateTime.now();
    final ranked = people.toList()
      ..sort((a, b) => score(b, now: reference).compareTo(score(a, now: reference)));

    return ranked.take(limit).map((person) {
      return RelationshipPriority(
        person: person,
        headline: priorityHeadline(person, now: reference),
        detail: priorityDetail(person, now: reference),
        action: priorityAction(person, now: reference),
        score: score(person, now: reference),
      );
    }).toList(growable: false);
  }

  int score(Person person, {DateTime? now}) {
    final reference = now ?? DateTime.now();
    var score = 0;

    if (person.lastInteractionAt == null) {
      score += 70;
    } else {
      final due = _reminderService.nextDue(person);
      final overdueDays = reference.isAfter(due) ? reference.difference(due).inDays : 0;
      score += (overdueDays * 12).clamp(0, 72);

      final daysSinceContact = reference.difference(person.lastInteractionAt!).inDays;
      final cadenceDays = _cadenceDays(person.cadence);
      if (daysSinceContact >= cadenceDays) score += 35;
      if (daysSinceContact >= cadenceDays * 2) score += 25;
    }

    if (_reminderService.isDue(person, now: reference)) score += 100;

    score += switch (person.state) {
      BondState.needsAttention => 40,
      BondState.steady => 18,
      BondState.strong => 6,
      BondState.thriving => 0,
    };

    if (person.importantDates.isNotEmpty) score += 8;
    if (person.memoryCount == 0) score += 5;

    return score;
  }

  String reason(Person person, {DateTime? now}) {
    final reference = now ?? DateTime.now();
    if (person.lastInteractionAt == null) return 'No meaningful contact recorded yet';

    final due = _reminderService.nextDue(person);
    if (reference.isAfter(due)) {
      final days = reference.difference(due).inDays;
      return days <= 1 ? 'Contact is due today' : '$days days overdue';
    }

    final daysSinceContact = reference.difference(person.lastInteractionAt!).inDays;
    final cadenceDays = _cadenceDays(person.cadence);
    if (daysSinceContact >= cadenceDays) return 'Past your ${person.cadence.name} cadence';
    if (person.state == BondState.needsAttention) return 'Bond health is declining';
    if (person.memoryCount == 0) return 'Capture a memory to strengthen context';
    return 'Keep the connection active';
  }

  String nextBestAction(Person person, {DateTime? now}) {
    final reference = now ?? DateTime.now();
    if (person.lastInteractionAt == null) return 'Reach out and establish the first touchpoint';
    if (_reminderService.isDue(person, now: reference)) return 'Reach out today';
    if (person.memoryCount == 0) return 'Capture something worth remembering';
    if (person.state == BondState.needsAttention) return 'Reconnect with a meaningful conversation';
    if (person.importantDates.isNotEmpty) return 'Review an upcoming important date';
    return 'Keep the bond active';
  }

  String priorityHeadline(Person person, {DateTime? now}) {
    final reference = now ?? DateTime.now();
    if (person.lastInteractionAt == null) return 'FIRST TOUCHPOINT';

    final due = _reminderService.nextDue(person);
    if (reference.isAfter(due)) {
      final days = reference.difference(due).inDays;
      return days <= 1 ? 'DUE TODAY' : '$days DAYS OVERDUE';
    }

    final daysSinceContact = reference.difference(person.lastInteractionAt!).inDays;
    final cadenceDays = _cadenceDays(person.cadence);
    if (daysSinceContact >= cadenceDays) return 'CADENCE MISSED';
    if (person.state == BondState.needsAttention) return 'BOND NEEDS CARE';
    return 'STAY CONNECTED';
  }

  String priorityDetail(Person person, {DateTime? now}) => reason(person, now: now);

  String priorityAction(Person person, {DateTime? now}) => nextBestAction(person, now: now);

  int _cadenceDays(Cadence cadence) => switch (cadence) {
        Cadence.daily => 1,
        Cadence.weekly => 7,
        Cadence.occasional => 30,
      };
}

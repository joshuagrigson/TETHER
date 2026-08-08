import '../models/person.dart';
import 'reminder_service.dart';

class RelationshipAttentionService {
  const RelationshipAttentionService({ReminderService reminderService = const ReminderService()}) : _reminderService = reminderService;

  final ReminderService _reminderService;

  List<Person> prioritize(List<Person> people, {DateTime? now, int limit = 5}) {
    final reference = now ?? DateTime.now();
    final ranked = people.toList()
      ..sort((a, b) => _score(b, reference).compareTo(_score(a, reference)));
    return ranked.take(limit).toList(growable: false);
  }

  int _score(Person person, DateTime now) {
    var score = 0;
    if (_reminderService.isDue(person, now: now)) score += 100;
    if (person.lastInteractionAt == null) {
      score += 40;
    } else {
      final due = _reminderService.nextDue(person);
      final overdueDays = now.isAfter(due) ? now.difference(due).inDays : 0;
      score += (overdueDays * 8).clamp(0, 64);
    }

    score += switch (person.state) {
      BondState.needsAttention => 30,
      BondState.steady => 15,
      BondState.strong => 5,
      BondState.thriving => 0,
    };
    return score;
  }

  String reason(Person person, {DateTime? now}) {
    final reference = now ?? DateTime.now();
    if (person.lastInteractionAt == null) return 'No interaction recorded yet';
    final due = _reminderService.nextDue(person);
    if (reference.isAfter(due)) {
      final days = reference.difference(due).inDays;
      return days <= 1 ? 'Due today' : '$days days overdue';
    }
    final days = due.difference(reference).inDays;
    return days <= 1 ? 'Due today' : 'Due in $days days';
  }
}

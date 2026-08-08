import '../models/person.dart';
import 'notification_service.dart';
import 'relationship_attention_service.dart';
import 'reminder_service.dart';

class ReminderNotificationCoordinator {
  const ReminderNotificationCoordinator({
    NotificationService notificationService = const NotificationService(),
    RelationshipAttentionService attentionService = const RelationshipAttentionService(),
    ReminderService reminderService = const ReminderService(),
  }) : _notificationService = notificationService,
       _attentionService = attentionService,
       _reminderService = reminderService;

  final NotificationService _notificationService;
  final RelationshipAttentionService _attentionService;
  final ReminderService _reminderService;

  Future<void> sync(List<Person> people, {DateTime? now}) async {
    final reference = now ?? DateTime.now();
    await _notificationService.cancelAll();

    final candidates = _attentionService.prioritize(people, now: reference, limit: 5);
    for (final person in candidates) {
      final due = _reminderService.nextDue(person, from: reference);
      final when = due.isBefore(reference) ? reference.add(const Duration(minutes: 1)) : due;
      await _notificationService.scheduleRelationshipReminder(
        id: _notificationId(person.id),
        personName: person.name,
        reason: _attentionService.reason(person, now: reference),
        when: when,
      );
    }
  }

  int _notificationId(String personId) {
    var hash = 17;
    for (final codeUnit in personId.codeUnits) {
      hash = 37 * hash + codeUnit;
    }
    return hash & 0x7fffffff;
  }
}

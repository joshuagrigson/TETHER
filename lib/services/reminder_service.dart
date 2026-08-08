import '../models/person.dart';

class ReminderService {
  const ReminderService();

  Duration cadenceWindow(Cadence cadence) => switch (cadence) {
    Cadence.daily => const Duration(days: 1),
    Cadence.weekly => const Duration(days: 7),
    Cadence.occasional => const Duration(days: 30),
  };

  bool isDue(Person person, {DateTime? now}) {
    if (person.lastInteractionAt == null) return true;
    final reference = now ?? DateTime.now();
    return !reference.isBefore(person.lastInteractionAt!.add(cadenceWindow(person.cadence)));
  }

  DateTime nextDue(Person person, {DateTime? from}) =>
      (person.lastInteractionAt ?? from ?? DateTime.now()).add(cadenceWindow(person.cadence));
}

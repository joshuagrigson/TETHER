import '../models/person.dart';

class RelationshipRepository {
  RelationshipRepository([List<Person>? seed]) : _people = List.of(seed ?? _defaults);

  final List<Person> _people;

  List<Person> get people => List.unmodifiable(_people);

  Person? findById(String id) {
    for (final person in _people) {
      if (person.id == id) return person;
    }
    return null;
  }

  void save(Person person) {
    final index = _people.indexWhere((item) => item.id == person.id);
    if (index == -1) {
      _people.add(person);
    } else {
      _people[index] = person;
    }
  }

  void delete(String id) => _people.removeWhere((person) => person.id == id);

  static const _defaults = <Person>[
    Person(id: '1', name: 'Alex', initials: 'AX', bondXp: 920, recentInteractions: 7, cadence: Cadence.daily, state: BondState.thriving, tags: ['Best friend', 'Daily'], notes: ['Prefers spontaneous plans'], importantDates: ['Birthday · Oct 12'], memoryCount: 14),
    Person(id: '2', name: 'Jordan', initials: 'JD', bondXp: 640, recentInteractions: 4, cadence: Cadence.weekly, state: BondState.strong, tags: ['Family', 'Weekly'], notes: ['Ask about the new project'], importantDates: ['Anniversary · Jun 4'], memoryCount: 9),
    Person(id: '3', name: 'Morgan', initials: 'MG', bondXp: 310, recentInteractions: 2, cadence: Cadence.weekly, state: BondState.steady, tags: ['Friend'], notes: ['Follow up after the trip'], importantDates: [], memoryCount: 5),
  ];
}

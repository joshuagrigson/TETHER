import 'package:flutter/foundation.dart';
import '../models/person.dart';
import '../repositories/relationship_repository.dart';

class RelationshipProvider extends ChangeNotifier {
  RelationshipProvider([RelationshipRepository? repository])
      : _repository = repository ?? RelationshipRepository();

  final RelationshipRepository _repository;

  List<Person> get people => _repository.people;

  Person? findById(String id) => _repository.findById(id);

  void save(Person person) {
    _repository.save(person);
    notifyListeners();
  }

  void delete(String id) {
    _repository.delete(id);
    notifyListeners();
  }
}

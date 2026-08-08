import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/person.dart';
import '../repositories/relationship_repository.dart';

class RelationshipProvider extends ChangeNotifier {
  RelationshipProvider([RelationshipRepository? repository]) : _repository = repository ?? RelationshipRepository() {
    unawaited(_hydrate());
  }

  final RelationshipRepository _repository;
  bool _isLoading = true;

  List<Person> get people => _repository.people;
  bool get isLoading => _isLoading;
  Person? findById(String id) => _repository.findById(id);

  Future<void> _hydrate() async {
    await _repository.load();
    _isLoading = false;
    notifyListeners();
  }

  void save(Person person) {
    _repository.save(person);
    notifyListeners();
    unawaited(_repository.persist());
  }

  void delete(String id) {
    _repository.delete(id);
    notifyListeners();
    unawaited(_repository.persist());
  }
}

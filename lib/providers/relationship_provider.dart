import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/person.dart';
import '../repositories/relationship_repository.dart';
import '../services/relationship_health_service.dart';

class RelationshipProvider extends ChangeNotifier {
  RelationshipProvider([RelationshipRepository? repository]) : _repository = repository ?? RelationshipRepository() {
    unawaited(_hydrate());
  }

  final RelationshipRepository _repository;
  static const _healthService = RelationshipHealthService();
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
    final normalized = person.copyWith(state: _healthService.classify(person));
    _repository.save(normalized);
    notifyListeners();
    unawaited(_repository.persist());
  }

  void recordInteraction(String id, {int xp = 25}) {
    final person = findById(id);
    if (person == null) return;
    save(person.copyWith(
      recentInteractions: person.recentInteractions + 1,
      bondXp: person.bondXp + xp,
      lastInteractionAt: DateTime.now(),
    ));
  }

  void delete(String id) {
    _repository.delete(id);
    notifyListeners();
    unawaited(_repository.persist());
  }
}

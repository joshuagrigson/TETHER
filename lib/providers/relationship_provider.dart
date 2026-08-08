import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/interaction.dart';
import '../models/person.dart';
import '../repositories/interaction_repository.dart';
import '../repositories/relationship_repository.dart';
import '../services/relationship_health_service.dart';

class RelationshipProvider extends ChangeNotifier {
  RelationshipProvider([RelationshipRepository? repository, InteractionRepository? interactionRepository])
      : _repository = repository ?? RelationshipRepository(),
        _interactionRepository = interactionRepository ?? InteractionRepository() {
    unawaited(_hydrate());
  }

  final RelationshipRepository _repository;
  final InteractionRepository _interactionRepository;
  static const _healthService = RelationshipHealthService();
  bool _isLoading = true;

  List<Person> get people => _repository.people;
  List<Interaction> get interactions => _interactionRepository.all;
  bool get isLoading => _isLoading;
  Person? findById(String id) => _repository.findById(id);
  List<Interaction> interactionsFor(String personId) => _interactionRepository.forPerson(personId);

  Future<void> _hydrate() async {
    await Future.wait([_repository.load(), _interactionRepository.load()]);
    _isLoading = false;
    notifyListeners();
  }

  void save(Person person) {
    final normalized = person.copyWith(state: _healthService.classify(person));
    _repository.save(normalized);
    notifyListeners();
    unawaited(_repository.persist());
  }

  void recordInteraction(String id, {required InteractionType type, int xp = 25, String? description}) {
    final person = findById(id);
    if (person == null) return;
    final now = DateTime.now();
    final label = type == InteractionType.call ? 'Call' : 'Conversation';
    _interactionRepository.add(Interaction(id: '${now.microsecondsSinceEpoch}', personId: id, type: type, title: '$label logged', description: description ?? 'Interaction recorded with ${person.name}.', occurredAt: now));
    save(person.copyWith(recentInteractions: person.recentInteractions + 1, bondXp: person.bondXp + xp, lastInteractionAt: now));
    unawaited(_interactionRepository.persist());
  }

  void addNote(String id, String note) {
    final person = findById(id);
    if (person == null || note.trim().isEmpty) return;
    final now = DateTime.now();
    _interactionRepository.add(Interaction(id: '${now.microsecondsSinceEpoch}', personId: id, type: InteractionType.note, title: 'Note captured', description: note.trim(), occurredAt: now));
    save(person.copyWith(notes: [note.trim(), ...person.notes]));
    unawaited(_interactionRepository.persist());
  }

  void delete(String id) {
    _repository.delete(id);
    notifyListeners();
    unawaited(_repository.persist());
  }
}

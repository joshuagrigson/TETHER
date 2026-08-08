import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/interaction.dart';

class InteractionRepository {
  static const _storageKey = 'tether.interactions.v1';
  final List<Interaction> _items = [];

  List<Interaction> get all => List.unmodifiable(_items);

  List<Interaction> forPerson(String personId) => _items.where((item) => item.personId == personId).toList(growable: false);

  Future<void> load() async {
    final preferences = await SharedPreferences.getInstance();
    final raw = preferences.getString(_storageKey);
    if (raw == null) return;
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      _items
        ..clear()
        ..addAll(decoded.map((item) => Interaction.fromJson(Map<String, dynamic>.from(item as Map))));
    } on FormatException {
      _items.clear();
    }
  }

  Future<void> persist() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_storageKey, jsonEncode(_items.map((item) => item.toJson()).toList()));
  }

  void add(Interaction interaction) => _items.add(interaction);
}

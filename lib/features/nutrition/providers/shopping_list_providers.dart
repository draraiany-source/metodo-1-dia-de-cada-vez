import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/food_database_models.dart';
import '../domain/shopping_list_models.dart';

class ShoppingListNotifier extends StateNotifier<List<ShoppingItem>> {
  ShoppingListNotifier() : super([]) {
    _load();
  }

  static const _key = 'shopping_list';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    final list = <ShoppingItem>[];
    for (final s in raw) {
      try {
        list.add(ShoppingItem.fromMap(jsonDecode(s) as Map<String, dynamic>));
      } catch (_) {/* entrada corrompida descartada */}
    }
    state = list;
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
        _key, state.map((e) => jsonEncode(e.toMap())).toList());
  }

  Future<void> add(String name, FoodCategory category, {String quantity = ''}) async {
    state = [
      ...state,
      ShoppingItem(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          name: name,
          category: category,
          quantity: quantity),
    ];
    await _persist();
  }

  Future<void> toggle(String id) async {
    state = state
        .map((e) => e.id == id ? e.copyWith(bought: !e.bought) : e)
        .toList();
    await _persist();
  }

  Future<void> remove(String id) async {
    state = state.where((e) => e.id != id).toList();
    await _persist();
  }

  Future<void> clearBought() async {
    state = state.where((e) => !e.bought).toList();
    await _persist();
  }
}

final shoppingListProvider =
    StateNotifierProvider<ShoppingListNotifier, List<ShoppingItem>>((ref) {
  return ShoppingListNotifier();
});

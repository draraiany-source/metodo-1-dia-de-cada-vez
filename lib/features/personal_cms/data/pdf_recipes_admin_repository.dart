import 'package:cloud_firestore/cloud_firestore.dart';

import '../../pdf_recipes/domain/pdf_recipe_models.dart';

/// CRUD mínimo de metadados em `pdf_recipes` (sem inventar coleção nova).
/// A URL do PDF em `/private/file` fica isolada; o stub grava só metadados
/// públicos + flag `active` para soft-delete.
class PdfRecipesAdminRepository {
  CollectionReference<Map<String, dynamic>> get _col =>
      FirebaseFirestore.instance.collection('pdf_recipes');

  Stream<List<PdfRecipe>> watchAll() {
    return _col.snapshots().map((snap) => snap.docs
        .map((d) => PdfRecipe.fromMap(d.id, d.data()))
        .toList()
      ..sort((a, b) => a.title.compareTo(b.title)));
  }

  Future<String> create({
    required String title,
    required PdfRecipeCategory category,
    required String coverUrl,
    required int minutes,
    required RecipeDifficulty difficulty,
    required int kcal,
    required int protein,
    required int carbs,
    required int fat,
    required bool isPremium,
  }) async {
    final ref = await _col.add({
      'title': title,
      'category': category.name,
      'coverUrl': coverUrl,
      'minutes': minutes,
      'difficulty': difficulty.name,
      'kcal': kcal,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'isPremium': isPremium,
      'active': true,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return ref.id;
  }

  Future<void> setActive(String id, bool active) async {
    await _col.doc(id).set({'active': active}, SetOptions(merge: true));
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/services/firebase_service.dart';
import '../../domain/food_analysis_models.dart';
import '../../domain/nutrition_firestore_paths.dart';

/// Persistência do diário alimentar em `users/{uid}/nutritionDiary/{id}`.
class NutritionDiaryRepository {
  NutritionDiaryRepository({required this.userId});

  final String userId;

  bool get _ready => FirebaseService.isReady && userId.isNotEmpty;

  CollectionReference<Map<String, dynamic>> get _col =>
      FirebaseFirestore.instance.collection(
        NutritionFirestorePaths.nutritionDiary(userId),
      );

  Future<String> save(NutritionDiaryEntry entry) async {
    if (!_ready) {
      throw StateError('Firebase indisponível ou usuário não autenticado.');
    }
    final doc = _col.doc(entry.id);
    await doc.set({
      ...entry.toFirestore(),
      'userId': userId,
      'createdAt': FieldValue.serverTimestamp(),
      'createdAtClient': entry.createdAt.toIso8601String(),
    }, SetOptions(merge: true));
    return entry.id;
  }

  Future<void> delete(String entryId) async {
    if (!_ready || entryId.isEmpty) return;
    await _col.doc(entryId).delete();
  }

  Future<List<NutritionDiaryEntry>> fetchForDate(String dateKey) async {
    if (!_ready) return [];
    try {
      final snap =
          await _col.where('date', isEqualTo: dateKey).limit(50).get();
      return snap.docs.map((d) {
        final m = d.data();
        return NutritionDiaryEntry(
          id: d.id,
          mealType: (m['mealType'] ?? 'lunch') as String,
          date: (m['date'] ?? dateKey) as String,
          createdAt: DateTime.tryParse(
                (m['createdAtClient'] ?? '') as String,
              ) ??
              DateTime.now(),
          imageUrl: m['imageUrl'] as String?,
          source: (m['source'] ?? 'ai_food_scan') as String,
          foods: ((m['foods'] as List?) ?? [])
              .whereType<Map>()
              .map((e) => Map<String, dynamic>.from(e))
              .toList(),
          totalCalories: ((m['totalCalories'] ?? 0) as num).round(),
          proteinG: ((m['proteinG'] ?? 0) as num).round(),
          carbsG: ((m['carbsG'] ?? 0) as num).round(),
          fatG: ((m['fatG'] ?? 0) as num).round(),
          fiberG: ((m['fiberG'] ?? 0) as num).round(),
        );
      }).toList()
        ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    } catch (_) {
      return [];
    }
  }
}

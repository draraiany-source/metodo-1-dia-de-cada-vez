import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';

import '../../../core/services/firebase_service.dart';
import '../domain/nutrition_firestore_paths.dart';

/// Upload comprimido de fotos de refeição para o Firebase Storage.
class MealPhotoStorageService {
  const MealPhotoStorageService();

  /// Retorna a download URL ou null se falhar / Firebase indisponível.
  Future<String?> uploadMealPhoto({
    required String userId,
    required String imageId,
    required List<int> bytes,
  }) async {
    if (!FirebaseService.isReady || userId.isEmpty || bytes.isEmpty) {
      return null;
    }
    try {
      final now = DateTime.now();
      final path = NutritionFirestorePaths.nutritionPhoto(
        userId,
        now.year,
        now.month,
        imageId,
      );
      final ref = FirebaseStorage.instance.ref(path);
      await ref.putData(
        Uint8List.fromList(bytes),
        SettableMetadata(contentType: 'image/jpeg'),
      );
      return await ref.getDownloadURL();
    } catch (_) {
      return null;
    }
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/auth/user_role.dart';
import '../../../core/services/firebase_service.dart';
import '../../../models/app_user.dart';

/// Gestão de papéis — somente Admin Técnico (`admins/{uid}`).
///
/// Nunca promove Admin Técnico por e-mail fixo no código: a fonte de verdade
/// é a coleção `admins/{uid}` (bootstrap via Console Firebase / Admin SDK).
class RolesAdminRepository {
  FirebaseFirestore get _db => FirebaseFirestore.instance;
  bool get isReady => FirebaseService.isReady;

  Future<List<AppUser>> listUsers({int limit = 80}) async {
    if (!isReady) return const [];
    final snap = await _db.collection('users').limit(limit).get();
    final users = snap.docs
        .map((d) => AppUser.fromMap(d.id, d.data()))
        .toList();

    // Enriquece isAdmin com a coleção canônica `admins`.
    final enriched = <AppUser>[];
    for (final u in users) {
      final adminDoc = await _db.collection('admins').doc(u.id).get();
      if (adminDoc.exists && !u.isAdmin) {
        enriched.add(u.copyWith(isAdmin: true));
      } else {
        enriched.add(u);
      }
    }
    enriched.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return enriched;
  }

  /// Aplica papel. [actorUid] não pode remover o próprio Admin Técnico.
  Future<void> setUserRole({
    required String actorUid,
    required String targetUid,
    required UserRole role,
  }) async {
    if (!isReady) {
      throw StateError('Firebase indisponível.');
    }
    if (targetUid.isEmpty) {
      throw ArgumentError('targetUid vazio');
    }
    if (actorUid == targetUid && role != UserRole.admin) {
      throw StateError(
          'Você não pode remover o próprio acesso de Admin Técnico.');
    }

    final userRef = _db.collection('users').doc(targetUid);
    final adminRef = _db.collection('admins').doc(targetUid);

    switch (role) {
      case UserRole.admin:
        await adminRef.set({
          'uid': targetUid,
          'role': UserRole.admin.firestoreValue,
          'updatedAt': DateTime.now().toIso8601String(),
          'updatedBy': actorUid,
        }, SetOptions(merge: true));
        await userRef.set({
          'isAdmin': true,
          'isPersonalTrainer': true, // Admin Técnico também opera a Central
          'role': UserRole.admin.firestoreValue,
        }, SetOptions(merge: true));
        break;
      case UserRole.personal:
        try {
          await adminRef.delete();
        } catch (_) {}
        await userRef.set({
          'isAdmin': false,
          'isPersonalTrainer': true,
          'role': UserRole.personal.firestoreValue,
        }, SetOptions(merge: true));
        break;
      case UserRole.aluno:
        try {
          await adminRef.delete();
        } catch (_) {}
        await userRef.set({
          'isAdmin': false,
          'isPersonalTrainer': false,
          'role': UserRole.aluno.firestoreValue,
        }, SetOptions(merge: true));
        break;
    }
  }
}

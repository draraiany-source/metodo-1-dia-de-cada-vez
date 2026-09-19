import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../../core/constants/app_constants.dart';
import '../../../core/services/firebase_service.dart';
import '../domain/subscription_models.dart';

class SubscriptionException implements Exception {
  const SubscriptionException(this.message);
  final String message;
  @override
  String toString() => message;
}

class SubscriptionRepository {
  FirebaseFirestore get _db => FirebaseFirestore.instance;

  Stream<SubscriptionRecord?> watchMine(String uid) {
    if (!FirebaseService.isReady || uid.isEmpty) {
      return Stream.value(null);
    }
    return _db
        .collection(AppConstants.cSubscriptions)
        .doc(uid)
        .snapshots()
        .map((doc) {
      if (!doc.exists || doc.data() == null) return null;
      return SubscriptionRecord.fromMap(uid, doc.data()!);
    });
  }

  Future<SubscriptionRecord?> getByUserId(String uid) async {
    if (!FirebaseService.isReady || uid.isEmpty) return null;
    try {
      final doc =
          await _db.collection(AppConstants.cSubscriptions).doc(uid).get();
      if (!doc.exists || doc.data() == null) return null;
      return SubscriptionRecord.fromMap(uid, doc.data()!);
    } catch (_) {
      return null;
    }
  }

  /// Inicia o teste de 7 dias. Prefere Cloud Function; cai no create
  /// restrito das rules se a function ainda não estiver publicada.
  Future<SubscriptionRecord> startFreeTrial(String uid) async {
    if (uid.isEmpty) {
      throw const SubscriptionException('Entre na sua conta para começar o teste.');
    }
    final existing = await getByUserId(uid);
    if (existing != null && (existing.trialUsed || existing.trialActive)) {
      throw const SubscriptionException(
        'Este teste grátis já foi utilizado nesta conta.',
      );
    }

    final fromFn = await _startTrialViaFunction();
    if (fromFn != null) return fromFn;

    if (!FirebaseService.isReady) {
      throw const SubscriptionException(
        'Não foi possível iniciar o teste agora. Tente de novo em instantes.',
      );
    }
    final record = SubscriptionRecord(
      userId: uid,
      plan: CatalogPlan.trial,
      status: SubscriptionLifecycle.trial,
      trialUsed: true,
      startedAt: DateTime.now(),
      trialStartedAt: DateTime.now(),
      trialEndsAt: DateTime.now().add(const Duration(days: PlanCatalog.trialDays)),
      source: 'trial',
    );
    try {
      await _db
          .collection(AppConstants.cSubscriptions)
          .doc(uid)
          .set(record.toTrialCreateMap());
    } on FirebaseException catch (e) {
      if (e.code == 'already-exists' || e.code == 'permission-denied') {
        throw const SubscriptionException(
          'Este teste grátis já foi utilizado nesta conta.',
        );
      }
      throw SubscriptionException(
        'Não foi possível iniciar o teste. ${e.message ?? e.code}',
      );
    }
    return record;
  }

  Future<SubscriptionRecord?> _startTrialViaFunction() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;
    try {
      final token = await user.getIdToken();
      final res = await http.post(
        Uri.parse(AppConstants.startFreeTrialFunctionUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(const {}),
      );
      if (res.statusCode >= 200 && res.statusCode < 300) {
        final body = jsonDecode(res.body) as Map<String, dynamic>;
        final data = (body['subscription'] as Map?)?.cast<String, dynamic>();
        if (data != null) {
          return SubscriptionRecord.fromMap(user.uid, data);
        }
        return getByUserId(user.uid);
      }
      if (res.statusCode == 409) {
        throw const SubscriptionException(
          'Este teste grátis já foi utilizado nesta conta.',
        );
      }
    } catch (e) {
      if (e is SubscriptionException) rethrow;
      debugPrint('startFreeTrial function: $e');
    }
    return null;
  }

  Stream<List<SubscriptionRecord>> watchAllForAdmin() {
    if (!FirebaseService.isReady) return Stream.value(const []);
    return _db.collection(AppConstants.cSubscriptions).snapshots().map((snap) {
      return snap.docs
          .map((d) => SubscriptionRecord.fromMap(d.id, d.data()))
          .toList();
    });
  }

  Future<void> writeAdminAudit({
    required String actorUid,
    required String targetUid,
    required String action,
    required String note,
  }) async {
    if (!FirebaseService.isReady) return;
    await _db.collection('subscription_audit').add({
      'actorUid': actorUid,
      'targetUid': targetUid,
      'action': action,
      'note': note,
      'at': DateTime.now().toIso8601String(),
    });
  }
}

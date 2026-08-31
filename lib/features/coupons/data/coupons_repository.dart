import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

import '../../../core/constants/app_constants.dart';
import '../../../core/services/firebase_service.dart';
import '../domain/coupon_models.dart';

class CouponRedeemResult {
  const CouponRedeemResult({required this.success, required this.message});
  final bool success;
  final String message;
}

class CouponsRepository {
  bool get isReady => FirebaseService.isReady;

  // ---------------- Admin: CRUD direto (regra exige isAdmin) ----------------

  Future<List<Coupon>> fetchAll() async {
    if (!isReady) return [];
    try {
      final snap = await FirebaseFirestore.instance.collection('coupons').get();
      return snap.docs.map((d) => Coupon.fromMap(d.id, d.data())).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> create(Coupon coupon) async {
    await FirebaseFirestore.instance
        .collection('coupons')
        .doc(coupon.code.toUpperCase())
        .set(coupon.toMap());
  }

  Future<void> delete(String code) async {
    await FirebaseFirestore.instance.collection('coupons').doc(code).delete();
  }

  // ---------------- Usuária: resgate via Cloud Function ----------------
  // O resgate NUNCA escreve direto no Firestore pelo cliente — a Cloud
  // Function valida (expiração, limite de uso, duplicidade) e credita a
  // recompensa com o Admin SDK, ignorando as regras de campo privilegiado.

  String get _functionUrl => AppConstants.redeemCouponFunctionUrl;

  Future<CouponRedeemResult> redeem(String code) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const CouponRedeemResult(
          success: false, message: 'Entre na sua conta pra resgatar cupons.');
    }
    if (_functionUrl.contains('SEU-PROJETO')) {
      return const CouponRedeemResult(
          success: false,
          message: 'Resgate de cupons ainda não configurado neste app.');
    }
    try {
      final token = await user.getIdToken();
      final res = await http
          .post(
            Uri.parse(_functionUrl),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode({'code': code.trim().toUpperCase()}),
          )
          .timeout(const Duration(seconds: 15));
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      return CouponRedeemResult(
        success: (data['success'] ?? false) as bool,
        message: (data['message'] ?? 'Não foi possível resgatar.') as String,
      );
    } catch (_) {
      return const CouponRedeemResult(
          success: false,
          message: 'Não consegui resgatar agora. Tente novamente.');
    }
  }
}

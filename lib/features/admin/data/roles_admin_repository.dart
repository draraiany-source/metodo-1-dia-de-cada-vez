import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

import '../../../core/auth/user_role.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/auth_http_headers.dart';
import '../../../core/services/firebase_service.dart';
import '../../../models/app_user.dart';

class AdminActionResult {
  const AdminActionResult({required this.ok, required this.message, this.uid});
  final bool ok;
  final String message;
  final String? uid;
}

/// Gestão de papéis — somente Admin Técnico (`admins/{uid}`).
///
/// Nunca promove Admin Técnico por e-mail fixo no código: a fonte de verdade
/// é a coleção `admins/{uid}` (bootstrap via Console Firebase / Admin SDK).
class RolesAdminRepository {
  FirebaseFirestore get _db => FirebaseFirestore.instance;
  bool get isReady => FirebaseService.isReady;

  Future<List<AppUser>> listUsers({int limit = 120}) async {
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
        enriched.add(u.copyWith(
          isAdmin: true,
          isPersonalTrainer: true,
          role: UserRole.admin.firestoreValue,
        ));
      } else {
        enriched.add(u);
      }
    }
    enriched.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return enriched;
  }

  List<AppUser> listPersonals(List<AppUser> users) {
    return users
        .where((u) =>
            resolveUserRole(
              isPersonalTrainer: u.isPersonalTrainer,
              isAdmin: u.isAdmin,
            ).isStaff)
        .toList();
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

  /// Bloqueia ou reativa no Firestore. O Auth disable é feito na Cloud Function.
  Future<AdminActionResult> setDisabled({
    required String actorUid,
    required String targetUid,
    required bool disabled,
  }) async {
    if (!isReady) {
      return const AdminActionResult(
          ok: false, message: 'Firebase indisponível.');
    }
    if (actorUid == targetUid) {
      return const AdminActionResult(
          ok: false, message: 'Você não pode bloquear a própria conta.');
    }
    await _db.collection('users').doc(targetUid).set({
      'disabled': disabled,
    }, SetOptions(merge: true));

    final remote = await _callManageUser({
      'action': 'setDisabled',
      'targetUid': targetUid,
      'disabled': disabled,
    });
    if (!remote.ok) {
      return AdminActionResult(
        ok: true,
        message: disabled
            ? 'Conta marcada como bloqueada no app. Auth: ${remote.message}'
            : 'Conta reativada no app. Auth: ${remote.message}',
        uid: targetUid,
      );
    }
    return AdminActionResult(
      ok: true,
      message: disabled ? 'Conta bloqueada.' : 'Conta reativada.',
      uid: targetUid,
    );
  }

  /// Vincula aluna existente a uma Personal via `pt_students.trainerId`.
  Future<void> assignStudentToPersonal({
    required AppUser student,
    required String trainerId,
  }) async {
    if (!isReady) throw StateError('Firebase indisponível.');
    if (trainerId.isEmpty) throw ArgumentError('Personal vazia.');
    if (student.id == trainerId) {
      throw StateError('Não é possível vincular a pessoa a si mesma.');
    }

    final existing = await _db
        .collection('pt_students')
        .where('userId', isEqualTo: student.id)
        .limit(1)
        .get();

    final payload = <String, dynamic>{
      'trainerId': trainerId,
      'userId': student.id,
      'name': student.name,
      'email': student.email.trim().toLowerCase(),
      'photoUrl': student.photoUrl ?? '',
      'active': true,
      'startDate': DateTime.now().toIso8601String(),
    };

    if (existing.docs.isNotEmpty) {
      await existing.docs.first.reference.set(payload, SetOptions(merge: true));
      return;
    }

    await _db.collection('pt_students').doc().set({
      ...payload,
      'objective': '',
      'phone': '',
      'sex': '',
      'level': 'iniciante',
      'notes': '',
    });
  }

  /// Cria conta Auth + perfil. Papel Admin/Personal só daqui (nunca no cadastro público).
  Future<AdminActionResult> createUser({
    required String name,
    required String email,
    required String password,
    required UserRole role,
  }) async {
    return _callManageUser({
      'action': 'createUser',
      'name': name.trim(),
      'email': email.trim().toLowerCase(),
      'password': password,
      'role': role.firestoreValue,
    });
  }

  Future<AdminActionResult> _callManageUser(Map<String, dynamic> body) async {
    final url = AppConstants.adminManageUserFunctionUrl;
    try {
      final headers = await AuthHttpHeaders.forCloudFunction();
      final res = await http
          .post(
            Uri.parse(url),
            headers: headers,
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 20));
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final ok = (data['success'] ?? data['ok'] ?? false) == true;
      return AdminActionResult(
        ok: ok,
        message: (data['message'] ?? data['error'] ?? 'Falha na operação.')
            as String,
        uid: data['uid'] as String?,
      );
    } catch (e) {
      return AdminActionResult(
        ok: false,
        message:
            'Cloud Function adminManageUser indisponível. Publique a function para criar/bloquear no Auth. ($e)',
      );
    }
  }
}

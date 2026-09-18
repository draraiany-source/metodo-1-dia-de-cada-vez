import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/auth/user_role.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/firebase_service.dart';
import '../../../models/app_user.dart';


/// Erro de autenticação já traduzido para a usuária.
///
/// Antes, o `FirebaseAuthException` cru chegava à UI, que exibia algo como
/// "[firebase_auth/wrong-password] The password is invalid...".
class AuthFailure implements Exception {
  const AuthFailure(this.message);
  final String message;
  @override
  String toString() => message;
}

String _traduzErroAuth(FirebaseAuthException e) {
  switch (e.code) {
    case 'invalid-email':
      return 'E-mail inválido. Confira e tente de novo.';
    case 'user-disabled':
      return 'Esta conta foi desativada.';
    case 'user-not-found':
    case 'wrong-password':
    case 'invalid-credential':
      return 'E-mail ou senha incorretos.';
    case 'email-already-in-use':
      return 'Este e-mail já está cadastrado. Tente entrar.';
    case 'weak-password':
      return 'Senha muito fraca. Use ao menos 6 caracteres.';
    case 'operation-not-allowed':
      return 'Cadastro por e-mail está desativado no momento.';
    case 'too-many-requests':
      return 'Muitas tentativas. Aguarde alguns minutos.';
    case 'network-request-failed':
      return 'Sem conexão. Verifique sua internet.';
    default:
      return 'Não foi possível continuar. Tente novamente.';
  }
}

/// Repositório de autenticação.
///
/// Quando o Firebase não está configurado, opera em "modo local":
/// aceita qualquer credencial e devolve a usuária demo, para que o app
/// seja totalmente navegável durante o desenvolvimento.
class AuthRepository {
  FirebaseAuth get _auth => FirebaseAuth.instance;
  FirebaseFirestore get _db => FirebaseFirestore.instance;

  bool get _local => !FirebaseService.isReady;

  /// Stream do usuário atual (null = deslogado).
  Stream<AppUser?> authState() async* {
    if (_local) {
      yield null; // começa deslogado no modo local
      return;
    }
    await for (final u in _auth.authStateChanges()) {
      if (u == null) {
        yield null;
      } else {
        try {
          final profile =
              await _loadProfile(u.uid, u.email ?? '', u.displayName ?? '');
          if (profile.disabled) {
            await _auth.signOut();
            yield null;
          } else {
            yield profile;
          }
        } on AuthFailure {
          yield null;
        }
      }
    }
  }

  Future<AppUser> _loadProfile(String uid, String email, String name,
      {String? referredByCode}) async {
    final doc = await _db.collection(AppConstants.cUsers).doc(uid).get();
    AppUser user;
    if (doc.exists) {
      user = AppUser.fromMap(uid, doc.data()!);
    } else {
      // Cadastro público sempre nasce ALUNO. Personal/Admin só via Admin Técnico.
      final myCode = uid.substring(0, 6).toUpperCase();
      user = AppUser(
        id: uid,
        name: name.isEmpty ? 'Nova usuária' : name,
        email: email,
        memberSince: DateTime.now(),
        referralCode: myCode,
        role: UserRole.aluno.firestoreValue,
        isAdmin: false,
        isPersonalTrainer: false,
        isPremium: false,
        disabled: false,
      );
      final data = user.toMap();
      data['role'] = UserRole.aluno.firestoreValue;
      data['isAdmin'] = false;
      data['isPersonalTrainer'] = false;
      data['isPremium'] = false;
      data['disabled'] = false;
      // Campo só lido pela Cloud Function `onUserCreated` (concede a
      // recompensa a quem indicou); não é reutilizado depois.
      if (referredByCode != null && referredByCode.trim().isNotEmpty) {
        data['referredByCode'] = referredByCode.trim().toUpperCase();
      }
      await _db.collection(AppConstants.cUsers).doc(uid).set(data);
      // Mapa código -> dono, pra Cloud Function encontrar quem indicou em O(1).
      await _db.collection('referral_codes').doc(myCode).set({'ownerUid': uid});
    }

    if (user.disabled) {
      await _auth.signOut();
      throw const AuthFailure('Esta conta foi desativada.');
    }

    // Fonte de verdade do Admin Técnico: coleção `admins/{uid}` (não e-mail).
    try {
      final adminDoc = await _db.collection('admins').doc(uid).get();
      if (adminDoc.exists) {
        user = user.copyWith(
          isAdmin: true,
          isPersonalTrainer: true,
          role: UserRole.admin.firestoreValue,
        );
      } else if (user.isAdmin) {
        // Flag órfã no doc users sem membership em admins → não eleva no app.
        user = user.copyWith(
          isAdmin: false,
          role: user.isPersonalTrainer
              ? UserRole.personal.firestoreValue
              : UserRole.aluno.firestoreValue,
        );
      }
    } catch (_) {
      // Sem permissão de leitura em admins = não é técnico.
      if (user.isAdmin) {
        user = user.copyWith(
          isAdmin: false,
          role: user.isPersonalTrainer
              ? UserRole.personal.firestoreValue
              : UserRole.aluno.firestoreValue,
        );
      }
    }

    final resolved = resolveUserRole(
      isPersonalTrainer: user.isPersonalTrainer,
      isAdmin: user.isAdmin,
    );
    if (user.role != resolved.firestoreValue) {
      user = user.copyWith(role: resolved.firestoreValue);
    }
    return user;
  }

  Future<AppUser> signIn(String email, String password) async {
    if (_local) return AppUser.demo();
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final u = cred.user;
      if (u == null) throw const AuthFailure('Não foi possível entrar.');
      return _loadProfile(u.uid, u.email ?? email, u.displayName ?? '');
    } on FirebaseAuthException catch (e) {
      throw AuthFailure(_traduzErroAuth(e));
    } on AuthFailure {
      rethrow;
    } catch (_) {
      throw const AuthFailure('Falha inesperada ao entrar. Tente novamente.');
    }
  }

  Future<AppUser> register(String name, String email, String password,
      {String? referredByCode}) async {
    if (_local) return AppUser.demo().copyWith(name: name);
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final u = cred.user;
      if (u == null) throw const AuthFailure('Não foi possível criar a conta.');
      await u.updateDisplayName(name);
      return _loadProfile(u.uid, email, name, referredByCode: referredByCode);
    } on FirebaseAuthException catch (e) {
      throw AuthFailure(_traduzErroAuth(e));
    } on AuthFailure {
      rethrow;
    } catch (_) {
      throw const AuthFailure('Falha inesperada no cadastro. Tente novamente.');
    }
  }

  Future<void> signOut() async {
    if (_local) return;
    await _auth.signOut();
  }

  Future<void> resetPassword(String email) async {
    if (_local) return;
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw AuthFailure(_traduzErroAuth(e));
    }
  }

  /// Exclui a conta da usuária (Firebase Auth) e seu documento de perfil
  /// no Firestore. Operação irreversível — a UI que chama isto é
  /// responsável por confirmar a intenção antes (ver `ProfileScreen`/
  /// tela de Configurações).
  ///
  /// Se o Firebase exigir reautenticação recente (`requires-recent-login`),
  /// propaga um [AuthFailure] com mensagem clara para a usuária tentar
  /// entrar novamente antes de excluir.
  Future<void> deleteAccount() async {
    if (_local) return;
    final user = _auth.currentUser;
    if (user == null) return;
    try {
      await _db.collection('users').doc(user.uid).delete();
      await user.delete();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        throw const AuthFailure(
            'Por segurança, entre novamente antes de excluir sua conta.');
      }
      throw AuthFailure(_traduzErroAuth(e));
    }
  }

  /// Atualiza campos do perfil (peso, altura, meta etc.) de forma parcial.
  /// Usado pela calculadora de IMC, registro de peso na Evolução etc.
  /// No modo local (sem Firebase) é um no-op — quem chama também deve
  /// atualizar o [localSessionProvider] para refletir a mudança na UI.
  Future<void> updateProfile(String uid, Map<String, dynamic> data) async {
    if (_local) return;
    await _db.collection('users').doc(uid).set(data, SetOptions(merge: true));
  }
}

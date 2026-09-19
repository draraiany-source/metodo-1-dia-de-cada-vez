import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/services/firebase_service.dart';
import '../../../models/app_user.dart';
import '../data/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

/// Estado de autenticação reativo. Guia o redirecionamento do GoRouter.
final authStateProvider = StreamProvider<AppUser?>((ref) {
  return ref.watch(authRepositoryProvider).authState();
});

/// Notifier local para login/registro no modo local (sem Firebase).
/// Mantém a usuária logada em memória quando o Firebase não está pronto.
class LocalSessionNotifier extends StateNotifier<AppUser?> {
  LocalSessionNotifier() : super(null);

  void setUser(AppUser? user) => state = user;
  void clear() => state = null;
}

final localSessionProvider =
    StateNotifierProvider<LocalSessionNotifier, AppUser?>((ref) {
  return LocalSessionNotifier();
});

/// Usuária efetiva: Firebase se disponível, senão sessão local.
///
/// Auditoria/teste: quando `AppConstants.debugUnlockAllPremiumContent` é
/// `true`, força `isPremium: true` aqui — é o único lugar que precisa
/// mudar, porque toda tela de conteúdo (vídeos, e-books, cursos, receitas,
/// treinos) já lê o Premium através de `user.isPremium`, vindo deste
/// provider. Nenhuma tela precisou ser alterada individualmente.
final currentUserProvider = Provider<AppUser?>((ref) {
  final fromFirebase = ref.watch(authStateProvider).value;
  final local = ref.watch(localSessionProvider);
  final effective = fromFirebase ?? local;
  if (effective == null) return null;
  if (AppConstants.debugUnlockAllPremiumContent && !effective.isPremium) {
    return effective.copyWith(isPremium: true);
  }
  return effective;
});

/// Sessão de "visitante" — permite navegar pelo app sem criar conta.
///
/// Persistida em `SharedPreferences` (não só em memória) porque no Flutter
/// Web o estado do Riverpod é recriado a cada F5/recarregamento de página;
/// sem essa persistência a pessoa era jogada de volta para o cadastro toda
/// vez que atualizava o navegador dentro da Home.
class GuestSessionNotifier extends StateNotifier<bool> {
  GuestSessionNotifier() : super(false) {
    _hydrate();
  }

  Future<void> _hydrate() async {
    final prefs = await SharedPreferences.getInstance();
    if (!AppConstants.enableGuestMode) {
      state = false;
      await prefs.setBool(AppConstants.kGuestMode, false);
      return;
    }
    state = prefs.getBool(AppConstants.kGuestMode) ?? false;
  }

  /// Entra em modo visitante e persiste a escolha.
  Future<void> enter() async {
    if (!AppConstants.enableGuestMode) {
      state = false;
      return;
    }
    state = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.kGuestMode, true);
  }

  /// Sai do modo visitante (ex.: ao fazer login/logout de verdade).
  Future<void> exit() async {
    state = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.kGuestMode, false);
  }
}

final guestSessionProvider =
    StateNotifierProvider<GuestSessionNotifier, bool>((ref) {
  return GuestSessionNotifier();
});

/// Verdadeiro quando há usuária autenticada (Firebase/local) OU visitante.
/// É o que o GoRouter usa para decidir se libera acesso à Home.
final isAuthenticatedOrGuestProvider = Provider<bool>((ref) {
  final user = ref.watch(currentUserProvider);
  final isGuest = ref.watch(guestSessionProvider);
  return user != null || isGuest;
});

/// Atualiza o perfil da usuária atual (peso, altura, meta etc.), persistindo
/// no Firestore quando disponível e sempre refletindo na sessão local — usado
/// pela calculadora de IMC e pelo registro de peso da tela de Evolução.
///
/// Continua funcionando no modo local/demo (sem Firebase configurado).
final profileUpdaterProvider =
    Provider<Future<void> Function(AppUser)>((ref) {
  return (AppUser updated) async {
    if (FirebaseService.isReady) {
      await ref
          .read(authRepositoryProvider)
          .updateProfile(updated.id, updated.toMap());
    }
    // Mantém a sessão local em dia mesmo com Firebase (evita esperar o
    // round-trip do stream) e é o único caminho quando não há Firebase.
    ref.read(localSessionProvider.notifier).setUser(updated);
  };
});

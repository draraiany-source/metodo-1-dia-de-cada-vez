import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Categorias da loja.
enum RewardCategory {
  avatares,
  temas,
  badges,
  frases,
  desafios,
  premium,
}

extension RewardCategoryX on RewardCategory {
  String get label => switch (this) {
        RewardCategory.avatares => 'Avatares',
        RewardCategory.temas => 'Temas',
        RewardCategory.badges => 'Badges especiais',
        RewardCategory.frases => 'Frases motivacionais',
        RewardCategory.desafios => 'Desafios extras',
        RewardCategory.premium => 'Itens premium',
      };

  String get emoji => switch (this) {
        RewardCategory.avatares => '🧑‍🎤',
        RewardCategory.temas => '🎨',
        RewardCategory.badges => '🎖️',
        RewardCategory.frases => '💬',
        RewardCategory.desafios => '🔥',
        RewardCategory.premium => '👑',
      };
}

/// Um item resgatável na loja.
@immutable
class RewardItem {
  const RewardItem({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.category,
    this.emoji = '✨',
    this.premiumOnly = false,
  });

  final String id;
  final String title;
  final String description;
  final int price;
  final RewardCategory category;
  final String emoji;
  final bool premiumOnly;
}

/// Uma linha do histórico de resgates.
@immutable
class RedeemRecord {
  const RedeemRecord({
    required this.itemId,
    required this.title,
    required this.price,
    required this.date,
  });

  final String itemId;
  final String title;
  final int price;
  final DateTime date;

  Map<String, dynamic> toMap() => {
        'itemId': itemId,
        'title': title,
        'price': price,
        'date': date.toIso8601String(),
      };

  static RedeemRecord fromMap(Map<String, dynamic> m) => RedeemRecord(
        itemId: m['itemId'] as String,
        title: m['title'] as String,
        price: m['price'] as int,
        date: DateTime.parse(m['date'] as String),
      );
}

/// Estado da economia do usuário (moedas + itens + histórico).
@immutable
class RewardsState {
  const RewardsState({
    this.coins = 0,
    this.owned = const {},
    this.history = const [],
    this.loading = true,
  });

  final int coins;
  final Set<String> owned; // ids de itens já resgatados
  final List<RedeemRecord> history;
  final bool loading;

  RewardsState copyWith({
    int? coins,
    Set<String>? owned,
    List<RedeemRecord>? history,
    bool? loading,
  }) =>
      RewardsState(
        coins: coins ?? this.coins,
        owned: owned ?? this.owned,
        history: history ?? this.history,
        loading: loading ?? this.loading,
      );
}

/// Catálogo estático da loja (mesmo estilo/valores do app).
class RewardsCatalog {
  RewardsCatalog._();

  static const List<RewardItem> all = [
    // Avatares
    RewardItem(
        id: 'av_rainha',
        title: 'Avatar Rainha',
        description: 'A Lili com coroa dourada para seu perfil.',
        price: 500,
        category: RewardCategory.avatares,
        emoji: '👸'),
    RewardItem(
        id: 'av_atleta',
        title: 'Avatar Atleta',
        description: 'Versão musculosa e poderosa da mascote.',
        price: 300,
        category: RewardCategory.avatares,
        emoji: '💪'),
    // Temas
    RewardItem(
        id: 'tema_neon',
        title: 'Tema Neon',
        description: 'Visual com brilhos neon roxo e rosa.',
        price: 400,
        category: RewardCategory.temas,
        emoji: '🌈'),
    RewardItem(
        id: 'tema_gold',
        title: 'Tema Gold',
        description: 'Detalhes dourados premium na interface.',
        price: 600,
        category: RewardCategory.temas,
        emoji: '✨'),
    // Badges
    RewardItem(
        id: 'badge_lenda',
        title: 'Badge Lendária',
        description: 'Ostente a medalha lendária no seu perfil.',
        price: 800,
        category: RewardCategory.badges,
        emoji: '🏆'),
    RewardItem(
        id: 'badge_foco',
        title: 'Badge Foco Total',
        description: 'Para quem não perde um dia de treino.',
        price: 250,
        category: RewardCategory.badges,
        emoji: '🎯'),
    // Frases
    RewardItem(
        id: 'frases_pack1',
        title: 'Pack de Frases Vol. 1',
        description: '30 novas frases motivacionais da Amanda.',
        price: 150,
        category: RewardCategory.frases,
        emoji: '💬'),
    // Desafios
    RewardItem(
        id: 'desafio_30d',
        title: 'Desafio 30 Dias Extremo',
        description: 'Desbloqueie o desafio avançado de 30 dias.',
        price: 350,
        category: RewardCategory.desafios,
        emoji: '🔥'),
    // Premium
    RewardItem(
        id: 'premium_boost',
        title: 'Boost de XP (7 dias)',
        description: 'Ganhe XP em dobro por uma semana.',
        price: 1000,
        category: RewardCategory.premium,
        emoji: '⚡',
        premiumOnly: false),
  ];

  static List<RewardItem> byCategory(RewardCategory c) =>
      all.where((r) => r.category == c).toList();
}

/// Notifier da economia: moedas, resgates e histórico, com persistência local.
///
/// Integração Firebase: quando o Firestore estiver ativo, sincronize os campos
/// `coins`, `owned` e `history` no doc `users/{uid}` (o método [syncToCloud]
/// é o ponto de extensão — hoje é no-op para não quebrar em modo local).
class RewardsNotifier extends StateNotifier<RewardsState> {
  RewardsNotifier() : super(const RewardsState()) {
    _load();
  }

  static const _kCoins = 'rewards_coins';
  static const _kOwned = 'rewards_owned';
  static const _kHistory = 'rewards_history';

  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    final coins = p.getInt(_kCoins) ?? 120; // saldo inicial de boas-vindas
    final owned = (p.getStringList(_kOwned) ?? []).toSet();
    // Parse defensivo: um registro corrompido não pode derrubar o app no boot.
    final history = <RedeemRecord>[];
    for (final s in p.getStringList(_kHistory) ?? <String>[]) {
      try {
        history.add(
            RedeemRecord.fromMap(jsonDecode(s) as Map<String, dynamic>));
      } catch (_) {
        // registro inválido é descartado silenciosamente
      }
    }
    history.sort((a, b) => b.date.compareTo(a.date));
    state = RewardsState(
        coins: coins, owned: owned, history: history, loading: false);
  }

  Future<void> _persist() async {
    final p = await SharedPreferences.getInstance();
    await p.setInt(_kCoins, state.coins);
    await p.setStringList(_kOwned, state.owned.toList());
    await p.setStringList(
        _kHistory, state.history.map((r) => jsonEncode(r.toMap())).toList());
    syncToCloud();
  }

  /// Ponto de extensão para Firestore (no-op enquanto em modo local).
  void syncToCloud() {
    // if (FirebaseService.isReady) { /* atualizar users/{uid} */ }
  }

  /// Adiciona moedas ao concluir treino, desafio, streak ou meta.
  void earn(int amount) {
    if (amount <= 0) return;
    state = state.copyWith(coins: state.coins + amount);
    _persist();
  }

  bool owns(String id) => state.owned.contains(id);

  /// Tenta resgatar um item. Retorna null em sucesso, ou uma mensagem de erro.
  String? redeem(RewardItem item) {
    if (state.owned.contains(item.id)) return 'Você já resgatou este item.';
    if (state.coins < item.price) return 'Moedas insuficientes.';
    final newHistory = [
      RedeemRecord(
          itemId: item.id,
          title: item.title,
          price: item.price,
          date: DateTime.now()),
      ...state.history,
    ];
    state = state.copyWith(
      coins: state.coins - item.price,
      owned: {...state.owned, item.id},
      history: newHistory,
    );
    _persist();
    return null;
  }

  /// Útil para testes/reset.
  Future<void> reset() async {
    state = const RewardsState(coins: 120, owned: {}, history: [], loading: false);
    await _persist();
  }
}

final rewardsProvider =
    StateNotifierProvider<RewardsNotifier, RewardsState>(
        (ref) => RewardsNotifier());

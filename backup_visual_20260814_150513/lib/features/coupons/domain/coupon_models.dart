enum CouponReward { coins, xp, premiumDays }

extension CouponRewardInfo on CouponReward {
  String get label => switch (this) {
        CouponReward.coins => 'Moedas',
        CouponReward.xp => 'XP',
        CouponReward.premiumDays => 'Dias Premium',
      };
}

/// Um cupom promocional cadastrado pelo admin.
class Coupon {
  const Coupon({
    required this.code,
    required this.reward,
    required this.value,
    required this.usageLimit,
    required this.usageCount,
    this.expiresAt,
    this.active = true,
  });

  final String code;
  final CouponReward reward;
  final int value;
  final int usageLimit;
  final int usageCount;
  final DateTime? expiresAt;
  final bool active;

  bool get expired =>
      expiresAt != null && expiresAt!.isBefore(DateTime.now());
  bool get exhausted => usageCount >= usageLimit;
  bool get valid => active && !expired && !exhausted;

  Map<String, dynamic> toMap() => {
        'reward': reward.name,
        'value': value,
        'usageLimit': usageLimit,
        'usageCount': usageCount,
        'expiresAt': expiresAt?.toIso8601String(),
        'active': active,
      };

  static Coupon fromMap(String code, Map<String, dynamic> m) => Coupon(
        code: code,
        reward: CouponReward.values.firstWhere((r) => r.name == m['reward'],
            orElse: () => CouponReward.coins),
        value: (m['value'] ?? 0) as int,
        usageLimit: (m['usageLimit'] ?? 1) as int,
        usageCount: (m['usageCount'] ?? 0) as int,
        expiresAt:
            m['expiresAt'] != null ? DateTime.parse(m['expiresAt']) : null,
        active: (m['active'] ?? true) as bool,
      );
}

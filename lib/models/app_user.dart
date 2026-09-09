import '../core/constants/app_constants.dart';
import '../core/services/firebase_service.dart';

/// Modelo da usuária do app.
class AppUser {
  final String id;
  final String name;
  final String email;
  final String? photoUrl;
  final String? city;
  final DateTime? memberSince;
  final DateTime? birthDate;

  // Dados corporais
  final double? startWeight;
  final double? currentWeight;
  final double? goalWeight;
  final double? height; // em metros

  // Gamificação
  final int xp;
  final int level;
  final int streak;
  final int totalWorkouts;
  final double totalKm;

  /// Código único pra indicar amigas (Módulo 7 do prompt master).
  final String? referralCode;

  /// Quantas pessoas se cadastraram usando o código desta usuária.
  final int referralCount;

  final bool isPremium;
  final bool isAdmin;
  final bool isPersonalTrainer;

  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    this.photoUrl,
    this.city,
    this.memberSince,
    this.birthDate,
    this.startWeight,
    this.currentWeight,
    this.goalWeight,
    this.height,
    this.xp = 0,
    this.level = 1,
    this.streak = 0,
    this.totalWorkouts = 0,
    this.totalKm = 0,
    this.referralCode,
    this.referralCount = 0,
    this.isPremium = false,
    this.isAdmin = false,
    this.isPersonalTrainer = false,
  });

  /// IMC calculado (ou null se faltar dado).
  double? get bmi {
    if (currentWeight == null || height == null || height == 0) return null;
    return currentWeight! / (height! * height!);
  }

  String get bmiLabel {
    final b = bmi;
    if (b == null) return '—';
    if (b < 18.5) return 'Abaixo do peso';
    if (b < 25) return 'Peso normal';
    if (b < 30) return 'Sobrepeso leve';
    return 'Obesidade';
  }

  double? get lostWeight {
    if (startWeight == null || currentWeight == null) return null;
    return startWeight! - currentWeight!;
  }

  /// Idade calculada a partir de [birthDate] (ou `null` se não cadastrada).
  int? get age {
    final b = birthDate;
    if (b == null) return null;
    final now = DateTime.now();
    var a = now.year - b.year;
    if (now.month < b.month || (now.month == b.month && now.day < b.day)) {
      a--;
    }
    return a;
  }

  /// Progresso de XP dentro do nível atual (0..1).
  double get levelProgress => (xp % 1000) / 1000.0;

  factory AppUser.fromMap(String id, Map<String, dynamic> m) {
    return AppUser(
      id: id,
      name: (m['name'] ?? '') as String,
      email: (m['email'] ?? '') as String,
      photoUrl: m['photoUrl'] as String?,
      city: m['city'] as String?,
      memberSince: _toDate(m['memberSince']),
      birthDate: _toDate(m['birthDate']),
      startWeight: _toDouble(m['startWeight']),
      currentWeight: _toDouble(m['currentWeight']),
      goalWeight: _toDouble(m['goalWeight']),
      height: _toDouble(m['height']),
      xp: (m['xp'] ?? 0) as int,
      level: (m['level'] ?? 1) as int,
      streak: (m['streak'] ?? 0) as int,
      totalWorkouts: (m['totalWorkouts'] ?? 0) as int,
      totalKm: _toDouble(m['totalKm']) ?? 0,
      referralCode: m['referralCode'] as String?,
      referralCount: (m['referralCount'] ?? 0) as int,
      isPremium: (m['isPremium'] ?? false) as bool,
      isAdmin: (m['isAdmin'] ?? false) as bool,
      isPersonalTrainer: (m['isPersonalTrainer'] ?? false) as bool,
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'email': email,
        'photoUrl': photoUrl,
        'city': city,
        'memberSince': memberSince?.toIso8601String(),
        'birthDate': birthDate?.toIso8601String(),
        'startWeight': startWeight,
        'currentWeight': currentWeight,
        'goalWeight': goalWeight,
        'height': height,
        'xp': xp,
        'level': level,
        'streak': streak,
        'totalWorkouts': totalWorkouts,
        'totalKm': totalKm,
        'referralCode': referralCode,
        'referralCount': referralCount,
        'isPremium': isPremium,
        'isAdmin': isAdmin,
        'isPersonalTrainer': isPersonalTrainer,
      };

  AppUser copyWith({
    String? name,
    String? photoUrl,
    String? city,
    DateTime? birthDate,
    double? startWeight,
    double? currentWeight,
    double? goalWeight,
    double? height,
    int? xp,
    int? level,
    int? streak,
    int? totalWorkouts,
    double? totalKm,
    bool? isPremium,
    bool? isAdmin,
    bool? isPersonalTrainer,
  }) {
    return AppUser(
      id: id,
      name: name ?? this.name,
      email: email,
      photoUrl: photoUrl ?? this.photoUrl,
      city: city ?? this.city,
      memberSince: memberSince,
      birthDate: birthDate ?? this.birthDate,
      startWeight: startWeight ?? this.startWeight,
      currentWeight: currentWeight ?? this.currentWeight,
      goalWeight: goalWeight ?? this.goalWeight,
      height: height ?? this.height,
      xp: xp ?? this.xp,
      level: level ?? this.level,
      streak: streak ?? this.streak,
      totalWorkouts: totalWorkouts ?? this.totalWorkouts,
      totalKm: totalKm ?? this.totalKm,
      referralCode: referralCode,
      referralCount: referralCount,
      isPremium: isPremium ?? this.isPremium,
      isAdmin: isAdmin ?? this.isAdmin,
      isPersonalTrainer: isPersonalTrainer ?? this.isPersonalTrainer,
    );
  }

  /// Usuária demo usada no modo local (sem Firebase) — NÃO usar em produção
  /// autenticada. Preferir [uiFallback].
  static AppUser demo() => AppUser(
        id: 'demo',
        name: 'Ana Silva',
        email: 'ana@exemplo.com',
        city: 'São Paulo',
        memberSince: DateTime(2025, 1, 1),
        startWeight: 78.0,
        currentWeight: 72.5,
        goalWeight: 65.0,
        height: 1.65,
        xp: 850,
        level: 2,
        streak: 8,
        totalWorkouts: 28,
        totalKm: 42.5,
        // Auditoria/teste: com a flag ligada, até a usuária demo/visitante
        // (fallback usado em toda tela quando não há login) enxerga o
        // conteúdo Premium liberado — sem precisar editar cada tela.
        isPremium: AppConstants.debugUnlockAllPremiumContent,
      );

  /// Visitante sem dados fictícios (Firebase pronto, sessão nula).
  static AppUser guest() => AppUser(
        id: 'guest',
        name: 'Visitante',
        email: '',
        memberSince: DateTime.now(),
        isPremium: AppConstants.debugUnlockAllPremiumContent,
      );

  /// Fallback de UI: demo só em modo local; visitante sem “Ana Silva” com Firebase.
  static AppUser uiFallback() =>
      FirebaseService.isReady ? guest() : demo();

  static double? _toDouble(dynamic v) =>
      v == null ? null : (v as num).toDouble();
  static DateTime? _toDate(dynamic v) {
    if (v == null) return null;
    if (v is String) return DateTime.tryParse(v);
    // Firestore Timestamp tem toDate(); usamos dynamic para evitar import.
    try {
      return (v as dynamic).toDate() as DateTime;
    } catch (_) {
      return null;
    }
  }
}

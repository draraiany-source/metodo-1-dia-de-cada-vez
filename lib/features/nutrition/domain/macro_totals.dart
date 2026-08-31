import 'package:flutter/foundation.dart';

@immutable
class MacroTotals {
  const MacroTotals({
    this.kcal = 0,
    this.proteinG = 0,
    this.carbsG = 0,
    this.fatG = 0,
    this.fiberG = 0,
  });

  final int kcal;
  final int proteinG;
  final int carbsG;
  final int fatG;
  final int fiberG;

  static const zero = MacroTotals();

  MacroTotals operator +(MacroTotals other) => MacroTotals(
        kcal: kcal + other.kcal,
        proteinG: proteinG + other.proteinG,
        carbsG: carbsG + other.carbsG,
        fatG: fatG + other.fatG,
        fiberG: fiberG + other.fiberG,
      );

  MacroTotals scale(double factor) {
    if (factor == 1) return this;
    return MacroTotals(
      kcal: (kcal * factor).round(),
      proteinG: (proteinG * factor).round(),
      carbsG: (carbsG * factor).round(),
      fatG: (fatG * factor).round(),
      fiberG: (fiberG * factor).round(),
    );
  }

  Map<String, dynamic> toMap() => {
        'kcal': kcal,
        'proteinG': proteinG,
        'carbsG': carbsG,
        'fatG': fatG,
        'fiberG': fiberG,
      };

  factory MacroTotals.fromMap(Map<String, dynamic> m) => MacroTotals(
        kcal: ((m['kcal'] ?? 0) as num).round(),
        proteinG: ((m['proteinG'] ?? m['protein'] ?? 0) as num).round(),
        carbsG: ((m['carbsG'] ?? m['carbs'] ?? 0) as num).round(),
        fatG: ((m['fatG'] ?? m['fat'] ?? 0) as num).round(),
        fiberG: ((m['fiberG'] ?? m['fiber'] ?? 0) as num).round(),
      );
}

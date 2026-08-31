import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Um registro de medidas corporais (cm) na linha do tempo de evolução.
/// Todos os campos são opcionais — a usuária registra só o que quiser medir.
///
/// Os cinco primeiros campos (`cintura`, `quadril`, `peito`, `braco`, `coxa`)
/// são os originais, mantidos por compatibilidade com registros antigos já
/// salvos no aparelho. Os campos abaixo deles são a expansão pedida na tela
/// de Medidas (lado direito/esquerdo separados, abdômen, busto, panturrilha
/// e percentual de gordura).
class MeasurementEntry {
  const MeasurementEntry({
    required this.date,
    this.cintura,
    this.quadril,
    this.peito,
    this.braco,
    this.coxa,
    this.abdomen,
    this.busto,
    this.panturrilha,
    this.coxaDireita,
    this.coxaEsquerda,
    this.bracoDireito,
    this.bracoEsquerdo,
    this.percentualGordura,
    this.observacao,
  });

  final DateTime date;
  final double? cintura;
  final double? quadril;
  final double? peito;
  final double? braco;
  final double? coxa;

  final double? abdomen;
  final double? busto;
  final double? panturrilha;
  final double? coxaDireita;
  final double? coxaEsquerda;
  final double? bracoDireito;
  final double? bracoEsquerdo;
  final double? percentualGordura;
  final String? observacao;

  bool get isEmpty =>
      cintura == null &&
      quadril == null &&
      peito == null &&
      braco == null &&
      coxa == null &&
      abdomen == null &&
      busto == null &&
      panturrilha == null &&
      coxaDireita == null &&
      coxaEsquerda == null &&
      bracoDireito == null &&
      bracoEsquerdo == null &&
      percentualGordura == null;

  Map<String, dynamic> toMap() => {
        'date': date.toIso8601String(),
        'cintura': cintura,
        'quadril': quadril,
        'peito': peito,
        'braco': braco,
        'coxa': coxa,
        'abdomen': abdomen,
        'busto': busto,
        'panturrilha': panturrilha,
        'coxaDireita': coxaDireita,
        'coxaEsquerda': coxaEsquerda,
        'bracoDireito': bracoDireito,
        'bracoEsquerdo': bracoEsquerdo,
        'percentualGordura': percentualGordura,
        'observacao': observacao,
      };

  static MeasurementEntry fromMap(Map<String, dynamic> m) => MeasurementEntry(
        date: DateTime.parse(m['date'] as String),
        cintura: (m['cintura'] as num?)?.toDouble(),
        quadril: (m['quadril'] as num?)?.toDouble(),
        peito: (m['peito'] as num?)?.toDouble(),
        braco: (m['braco'] as num?)?.toDouble(),
        coxa: (m['coxa'] as num?)?.toDouble(),
        abdomen: (m['abdomen'] as num?)?.toDouble(),
        busto: (m['busto'] as num?)?.toDouble(),
        panturrilha: (m['panturrilha'] as num?)?.toDouble(),
        coxaDireita: (m['coxaDireita'] as num?)?.toDouble(),
        coxaEsquerda: (m['coxaEsquerda'] as num?)?.toDouble(),
        bracoDireito: (m['bracoDireito'] as num?)?.toDouble(),
        bracoEsquerdo: (m['bracoEsquerdo'] as num?)?.toDouble(),
        percentualGordura: (m['percentualGordura'] as num?)?.toDouble(),
        observacao: m['observacao'] as String?,
      );
}

/// Histórico de medidas — mesmo padrão local-first do histórico de peso
/// ([WeightHistoryNotifier]): persiste em SharedPreferences, migra para
/// `users/{uid}/progress` no Firestore quando isso for validado com o dono
/// do projeto.
class MeasurementHistoryNotifier extends StateNotifier<List<MeasurementEntry>> {
  MeasurementHistoryNotifier() : super([]) {
    _load();
  }

  static const _key = 'measurement_history';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    final parsed = <MeasurementEntry>[];
    for (final s in raw) {
      try {
        parsed.add(
            MeasurementEntry.fromMap(jsonDecode(s) as Map<String, dynamic>));
      } catch (_) {/* entrada corrompida descartada */}
    }
    parsed.sort((a, b) => a.date.compareTo(b.date));
    state = parsed;
  }

  Future<void> add(MeasurementEntry entry) async {
    if (entry.isEmpty) return;
    state = [...state, entry];
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
        _key, state.map((e) => jsonEncode(e.toMap())).toList());
  }
}

final measurementHistoryProvider = StateNotifierProvider<
    MeasurementHistoryNotifier, List<MeasurementEntry>>((ref) {
  return MeasurementHistoryNotifier();
});

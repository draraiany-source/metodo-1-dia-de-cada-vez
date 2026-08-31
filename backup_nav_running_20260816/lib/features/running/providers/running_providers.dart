import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/running_repository.dart';

final runningRepositoryProvider = Provider((ref) => RunningRepository());

/// Histórico de corridas da usuária atual — usado pelo Dashboard, pelos
/// Certificados (500km/1000km) e pelos Relatórios.
final runningHistoryProvider =
    FutureProvider.family<List<RunningSession>, String>((ref, userId) {
  return ref.read(runningRepositoryProvider).fetchAll(userId);
});

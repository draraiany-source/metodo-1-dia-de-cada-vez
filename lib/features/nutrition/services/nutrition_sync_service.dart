class NutritionSyncService {
  const NutritionSyncService();

  Future<int> pendingCount({required String userId}) async => 0;

  Future<void> enqueue({required String userId, required String payload}) async {}

  Future<void> flush({required String userId}) async {}
}

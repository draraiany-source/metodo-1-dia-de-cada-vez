import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/coupons_repository.dart';
import '../domain/coupon_models.dart';

final couponsRepositoryProvider = Provider((ref) => CouponsRepository());

final couponsListProvider = FutureProvider<List<Coupon>>((ref) {
  return ref.read(couponsRepositoryProvider).fetchAll();
});

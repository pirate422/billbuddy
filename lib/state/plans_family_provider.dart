import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/plan.dart';
import 'repository_providers.dart';

/// Parameter class for plan family lookup
class PlanQueryParams {
  final String operator;
  final String circle;

  const PlanQueryParams({required this.operator, required this.circle});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlanQueryParams &&
          runtimeType == other.runtimeType &&
          operator == other.operator &&
          circle == other.circle;

  @override
  int get hashCode => operator.hashCode ^ circle.hashCode;
}

/// Family provider fetching recharge plans by operator & circle
final plansFamilyProvider = FutureProvider.family<List<Plan>, PlanQueryParams>((
  ref,
  params,
) async {
  final repository = ref.watch(rechargeRepositoryProvider);
  return repository.fetchPlans(
    operator: params.operator,
    circle: params.circle,
  );
});

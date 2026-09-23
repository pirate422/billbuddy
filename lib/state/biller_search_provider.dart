import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/biller.dart';
import 'repository_providers.dart';

/// Family provider for debounced biller search by query string
final billerSearchProvider =
    FutureProvider.family<List<Biller>, String>((ref, query) async {
  if (query.trim().isEmpty) return [];
  final repository = ref.watch(billerRepositoryProvider);
  return repository.searchBillers(query);
});
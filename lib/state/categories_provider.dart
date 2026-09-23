import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'repository_providers.dart';

/// Fetches and caches the list of biller categories
final categoriesProvider = FutureProvider<List<String>>((ref) async {
  final repository = ref.watch(billerRepositoryProvider);
  return repository.fetchCategories();
});
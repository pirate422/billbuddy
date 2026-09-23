import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/bill.dart';
import '../data/models/saved_biller.dart';
import 'repository_providers.dart';

/// Fetches the user's saved billers
final myBillersProvider = FutureProvider<List<SavedBiller>>((ref) async {
  final repository = ref.watch(myBillerRepositoryProvider);
  return repository.fetchSavedBillers();
});

/// Family provider to fetch bill details for a specific saved biller ID
final billFamilyProvider =
    FutureProvider.family<Bill?, String>((ref, savedBillerId) async {
  final repository = ref.watch(myBillerRepositoryProvider);
  return repository.fetchBill(savedBillerId);
});
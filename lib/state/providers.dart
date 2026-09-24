import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/mock_api.dart';
import '../core/models.dart';
import '../data/repositories.dart';

final prefsProvider = Provider<SharedPreferences>(
    (_) => throw UnimplementedError('override in main()'));
final apiProvider = Provider((r) => MockApi(r.watch(prefsProvider)));
final sessionProvider =
    StateProvider<String?>((r) => r.read(prefsProvider).getString('session'));

final billerRepoProvider =
    Provider((r) => BillerRepository(r.watch(apiProvider)));
final myBillerRepoProvider =
    Provider((r) => MyBillerRepository(r.watch(apiProvider)));
final billRepoProvider = Provider((r) => BillRepository(r.watch(apiProvider)));
final paymentRepoProvider =
    Provider((r) => PaymentRepository(r.watch(apiProvider)));
final rechargeRepoProvider =
    Provider((r) => RechargeRepository(r.watch(apiProvider)));

final categoriesProvider = FutureProvider<List<BillCategory>>(
    (r) => r.watch(billerRepoProvider).categories());
final searchQueryProvider = StateProvider.autoDispose<String>(
    (_) => ''); // set after a 300 ms debounce in the UI
final billersByCategoryProvider = FutureProvider.autoDispose
    .family<List<Biller>, String>(
        (r, cat) => r.watch(billerRepoProvider).search(category: cat));
final billerSearchProvider = FutureProvider.autoDispose<List<Biller>>((r) =>
    r.watch(billerRepoProvider).search(query: r.watch(searchQueryProvider)));
final billerProvider = FutureProvider.autoDispose
    .family<Biller, String>((r, id) => r.watch(billerRepoProvider).byId(id));

final myBillersProvider = FutureProvider.autoDispose<List<SavedBiller>>(
    (r) => r.watch(myBillerRepoProvider).list());
final savedBillerProvider = FutureProvider.autoDispose
    .family<SavedBiller, String>((r, id) async =>
        (await r.watch(myBillersProvider.future))
            .firstWhere((b) => b.id == id));

final upcomingProvider = FutureProvider.autoDispose<List<UpcomingItem>>(
    (r) async => r
        .watch(billRepoProvider)
        .upcoming(await r.watch(myBillersProvider.future)));
final billProvider = FutureProvider.autoDispose
    .family<Bill, String>((r, id) => r.watch(billRepoProvider).fetch(id));
final payInfoProvider =
    FutureProvider.autoDispose.family<PayInfo, String>((r, id) async {
  final s = await r.watch(savedBillerProvider(id).future);
  final bill = await r.watch(billProvider(id).future);
  final biller = await r.watch(billerRepoProvider).byId(s.billerId);
  return PayInfo(s, bill, biller.allowPartial);
});

final historyProvider = FutureProvider.autoDispose<List<Payment>>(
    (r) => r.watch(paymentRepoProvider).history());
final paymentProvider = FutureProvider.autoDispose
    .family<Payment, String>((r, id) => r.watch(paymentRepoProvider).byId(id));
final plansProvider = FutureProvider.autoDispose
    .family<List<Plan>, (String, String)>(
        (r, k) => r.watch(rechargeRepoProvider).plans(k.$1, k.$2));

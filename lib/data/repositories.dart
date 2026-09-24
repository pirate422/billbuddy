import '../core/mock_api.dart';
import '../core/models.dart';

class BillerRepository {
  BillerRepository(this._api);
  final MockApi _api;
  Future<List<BillCategory>> categories() async => (await _api.categories()).map(BillCategory.fromJson).toList();
  Future<List<Biller>> search({String? category, String query = ''}) async =>
      (await _api.billers(category: category, query: query)).map(Biller.fromJson).toList();
  Future<Biller> byId(String id) async => Biller.fromJson(await _api.biller(id));
}

class MyBillerRepository {
  MyBillerRepository(this._api);
  final MockApi _api;
  Future<List<SavedBiller>> list() => _api.myBillers();
  Future<SavedBiller> add(String billerId, String nickname, Map<String, String> fields) =>
      _api.saveBiller(billerId, nickname, fields);
  Future<SavedBiller> setAutopay(String id, {required bool enabled, required int maxPaise, required bool paused}) =>
      _api.setAutopay(id, enabled: enabled, maxPaise: maxPaise, paused: paused);
}

class BillRepository {
  BillRepository(this._api);
  final MockApi _api;
  Future<Bill> fetch(String savedId) => _api.fetchBill(savedId);

  /// Loads every saved biller's bill independently (one outage never breaks the page),
  /// runs autopay, then sorts: overdue -> due soon -> upcoming -> nothing due -> errors.
  Future<List<UpcomingItem>> upcoming(List<SavedBiller> saved) async {
    final items = [...await Future.wait(saved.map(_load))];
    items.sort((a, b) {
      final r = _rank(a).compareTo(_rank(b));
      if (r != 0) return r;
      return (a.bill?.dueDate ?? DateTime(2100)).compareTo(b.bill?.dueDate ?? DateTime(2100));
    });
    return items;
  }

  int _rank(UpcomingItem i) {
    final b = i.bill;
    if (b == null) return 4;
    if (b.noDue) return 3;
    return b.overdue ? 0 : (b.dueSoon ? 1 : 2);
  }

  Future<UpcomingItem> _load(SavedBiller s) async {
    try {
      var bill = await _api.fetchBill(s.id);
      // Autopay: only when due within 3 days/overdue AND within the safety limit.
      if (s.autopay && !s.paused && !bill.noDue && bill.daysLeft <= 3 && bill.amountPaise <= s.maxPaise) {
        await _api.pay(savedId: s.id, amountPaise: bill.amountPaise, account: kAccounts.first, key: 'auto-${s.id}-${bill.period}');
        bill = await _api.fetchBill(s.id);
      }
      return UpcomingItem(s, bill: bill);
    } catch (e) {
      return UpcomingItem(s, error: e is ApiException ? e.message : 'Could not fetch bill');
    }
  }
}

class PaymentRepository {
  PaymentRepository(this._api);
  final MockApi _api;
  Future<Payment> pay({required String savedId, required int amountPaise, required String account, required String key}) =>
      _api.pay(savedId: savedId, amountPaise: amountPaise, account: account, key: key);
  Future<List<Payment>> history() => _api.history();
  Future<Payment> byId(String id) => _api.payment(id);
}

class RechargeRepository {
  RechargeRepository(this._api);
  final MockApi _api;
  Future<(String, String)> detect(String number) async {
    final d = await _api.detect(number);
    return (d['operator']!, d['circle']!);
  }

  Future<List<Plan>> plans(String op, String circle) async => (await _api.plans(op, circle)).map(Plan.fromJson).toList();
  Future<Payment> recharge({required String number, required String operator, required int amountPaise, required String account, required String key}) =>
      _api.recharge(number: number, operator: operator, amountPaise: amountPaise, account: account, key: key);
}

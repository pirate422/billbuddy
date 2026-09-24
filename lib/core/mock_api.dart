import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'models.dart';

/// Simulated backend (billers, my-billers, bills, payments, autopay, recharge).
/// State is persisted in SharedPreferences so payment history survives restarts.
/// Replace this class with Dio calls to plug in a real server.
class MockApi {
  MockApi(this._p);
  final SharedPreferences _p;
  final _rnd = Random();

  Future<void> _lag() =>
      Future.delayed(Duration(milliseconds: 250 + _rnd.nextInt(350)));
  List<Map<String, dynamic>> _read(String k) =>
      (jsonDecode(_p.getString(k) ?? '[]') as List)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
  Future<void> _write(String k, List<Map<String, dynamic>> v) =>
      _p.setString(k, jsonEncode(v));
  Map<String, int> _paid() =>
      Map<String, int>.from(jsonDecode(_p.getString('paid') ?? '{}') as Map);

  // ---------- auth ----------
  Future<String> login(String email, String password) async {
    await _lag();
    final users = Map<String, String>.from(
        jsonDecode(_p.getString('users') ?? '{}') as Map);
    final e = email.trim().toLowerCase();
    if (users.containsKey(e) && users[e] != password)
      throw ApiException(401, 'Wrong password for this account');
    users[e] = password; // first login creates the account (mock only!)
    await _p.setString('users', jsonEncode(users));
    await _p.setString('session', e);
    return e;
  }

  Future<void> logout() => _p.remove('session');

  // ---------- biller directory ----------
  static Map<String, dynamic> _f(String k, String l, String re, String hint,
          {bool num = true}) =>
      {'key': k, 'label': l, 'regex': re, 'hint': hint, 'numeric': num};
  static Map<String, dynamic> _b(String id, String name, String cat,
          bool partial, List<Map<String, dynamic>> f) =>
      {
        'id': id,
        'name': name,
        'category': cat,
        'allowPartial': partial,
        'fields': f
      };
  static final _mobile =
      _f('mobile', 'Registered mobile', r'^[6-9]\d{9}$', '10 digits');

  static final _billers = <Map<String, dynamic>>[
    _b('msedcl', 'MSEDCL', 'electricity', true,
        [_f('consumer', 'Consumer number', r'^\d{12}$', '12 digits')]),
    _b('tata_power', 'Tata Power', 'electricity', true,
        [_f('consumer', 'Consumer number', r'^\d{9}$', '9 digits'), _mobile]),
    _b('mcgm', 'MCGM Water', 'water', false,
        [_f('consumer', 'Consumer number', r'^\d{8}$', '8 digits')]),
    _b('mgl', 'Mahanagar Gas', 'gas', false,
        [_f('consumer', 'CA number', r'^\d{10}$', '10 digits')]),
    _b('act', 'ACT Fibernet', 'broadband', false, [
      _f('account', 'Account ID', r'^[A-Za-z0-9]{8,12}$',
          '8-12 letters or digits',
          num: false)
    ]),
    _b('airtel_dth', 'Airtel Digital TV', 'dth', false,
        [_f('consumer', 'Customer ID', r'^\d{10}$', '10 digits')]),
    _b('jio_post', 'Jio Postpaid', 'mobile', false,
        [_f('consumer', 'Mobile number', r'^[6-9]\d{9}$', '10 digits')]),
    _b('hdfc_cc', 'HDFC Credit Card', 'credit_card', true, [
      _f('consumer', 'Card last 4 digits', r'^\d{4}$', '4 digits'),
      _mobile
    ]),
  ];

  Future<List<Map<String, dynamic>>> categories() async {
    await _lag();
    return const [
      {'id': 'electricity', 'name': 'Electricity'},
      {'id': 'water', 'name': 'Water'},
      {'id': 'gas', 'name': 'Gas'},
      {'id': 'broadband', 'name': 'Broadband'},
      {'id': 'mobile', 'name': 'Mobile'},
      {'id': 'dth', 'name': 'DTH'},
      {'id': 'credit_card', 'name': 'Credit card'},
    ];
  }

  Future<List<Map<String, dynamic>>> billers(
      {String? category, String query = ''}) async {
    await _lag();
    final q = query.trim().toLowerCase();
    return _billers
        .where((b) =>
            (category == null || b['category'] == category) &&
            (q.isEmpty || (b['name'] as String).toLowerCase().contains(q)))
        .toList();
  }

  Future<Map<String, dynamic>> biller(String id) async {
    await _lag();
    return _billers.firstWhere((b) => b['id'] == id);
  }

  // ---------- my billers ----------
  SavedBiller _saved(String id) =>
      _read('saved').map(SavedBiller.fromJson).firstWhere((s) => s.id == id,
          orElse: () => throw ApiException(404, 'Biller not found'));

  Future<List<SavedBiller>> myBillers() async {
    await _lag();
    return _read('saved').map(SavedBiller.fromJson).toList();
  }

  Future<SavedBiller> saveBiller(
      String billerId, String nickname, Map<String, String> fields) async {
    await _lag();
    final b = Biller.fromJson(_billers.firstWhere((x) => x['id'] == billerId));
    for (final f in b.fields) {
      final err = validateField(f, fields[f.key]);
      if (err != null) throw ApiException(422, err, field: f.key);
    }
    final first = b.fields.first;
    if (RegExp(r'^(\d)\1+$').hasMatch(fields[first.key]!)) {
      throw ApiException(422, '${first.label} not found with ${b.name}',
          field: first.key); // biller rejected it
    }
    final s = SavedBiller(
        id: 's${DateTime.now().millisecondsSinceEpoch}',
        billerId: b.id,
        billerName: b.name,
        category: b.category,
        nickname: nickname.trim(),
        fields: fields);
    await _write('saved', [..._read('saved'), s.toJson()]);
    return s;
  }

  Future<SavedBiller> setAutopay(String id,
      {required bool enabled,
      required int maxPaise,
      required bool paused}) async {
    await _lag();
    if (enabled && maxPaise <= 0)
      throw ApiException(422, 'Set a maximum amount above zero', field: 'max');
    final all = _read('saved').map(SavedBiller.fromJson).toList();
    final i = all.indexWhere((s) => s.id == id);
    all[i] =
        all[i].copyWith(autopay: enabled, maxPaise: maxPaise, paused: paused);
    await _write('saved', all.map((s) => s.toJson()).toList());
    return all[i];
  }

  // ---------- bills ----------
  /// Deterministic fake bill. Consumer value ending in 0 => "no bill due".
  Bill _bill(SavedBiller s) {
    final now = DateTime.now();
    final period = '${kMonths[now.month - 1]} ${now.year}';
    final first = s.fields.values.first;
    if (first.endsWith('0'))
      return Bill(savedId: s.id, period: period, amountPaise: 0);
    final seed = s.billerId.codeUnits
        .followedBy(first.codeUnits)
        .fold<int>(7, (a, c) => (a * 31 + c) & 0x7fffffff);
    final total = ((seed % 3000) + 200) * 100;
    final paid = _paid()['${s.id}|$period'] ?? 0;
    return Bill(
        savedId: s.id,
        period: period,
        amountPaise: max(0, total - paid),
        totalPaise: total,
        dueDate: DateTime(now.year, now.month, 1 + seed % 28));
  }

  Future<Bill> fetchBill(String savedId) async {
    await _lag();
    if (_rnd.nextInt(100) < 10)
      throw ApiException(
          503, 'BILLER_DOWN: the biller is not responding right now.');
    return _bill(_saved(savedId));
  }

  // ---------- payments ----------
  Payment? _existing(String key) {
    for (final p in _read('payments')) {
      if (p['key'] == key) return Payment.fromJson(p);
    }
    return null;
  }

  Future<Payment> _record({
    required String key,
    required String savedId,
    required String title,
    required String billerName,
    required String category,
    required int amount,
    required String account,
    String? period,
  }) async {
    final r = _rnd.nextInt(100);
    final status = r < 75
        ? PayStatus.success
        : (r < 90 ? PayStatus.pending : PayStatus.failed);
    final p = Payment(
        id: 'p${DateTime.now().microsecondsSinceEpoch}',
        key: key,
        savedId: savedId,
        title: title,
        billerName: billerName,
        category: category,
        amountPaise: amount,
        account: account,
        status: status,
        billerRef: status == PayStatus.failed
            ? '-'
            : 'BR${100000 + _rnd.nextInt(899999)}',
        bankRef: status == PayStatus.failed
            ? '-'
            : 'UTR${10000000 + _rnd.nextInt(89999999)}',
        at: DateTime.now());
    await _write('payments', [..._read('payments'), p.toJson()]);
    if (status != PayStatus.failed && period != null) {
      final paid = _paid();
      final k = '$savedId|$period';
      paid[k] = (paid[k] ?? 0) + amount;
      await _p.setString('paid', jsonEncode(paid));
    }
    return p;
  }

  /// Idempotent: the same [key] always returns the same payment (retry never pays twice).
  Future<Payment> pay(
      {required String savedId,
      required int amountPaise,
      required String account,
      required String key}) async {
    await _lag();
    final dup = _existing(key);
    if (dup != null) return dup;
    final s = _saved(savedId);
    final bill = _bill(s);
    final biller =
        Biller.fromJson(_billers.firstWhere((b) => b['id'] == s.billerId));
    final err =
        validateAmount(amountPaise, bill.amountPaise, biller.allowPartial);
    if (err != null) throw ApiException(422, err, field: 'amount');
    return _record(
        key: key,
        savedId: savedId,
        title: s.nickname,
        billerName: s.billerName,
        category: s.category,
        amount: amountPaise,
        account: account,
        period: bill.period);
  }

  /// Pending payments settle to success once refreshed after ~5 seconds.
  Future<List<Payment>> history() async {
    await _lag();
    final now = DateTime.now();
    var changed = false;
    final all = _read('payments').map(Payment.fromJson).map((p) {
      if (p.status == PayStatus.pending && now.difference(p.at).inSeconds > 5) {
        changed = true;
        return p.copyWith(status: PayStatus.success);
      }
      return p;
    }).toList();
    if (changed) await _write('payments', all.map((p) => p.toJson()).toList());
    final cutoff =
        DateTime(now.year - 1, now.month, now.day); // receipts kept 12 months
    return all.where((p) => p.at.isAfter(cutoff)).toList()
      ..sort((a, b) => b.at.compareTo(a.at));
  }

  Future<Payment> payment(String id) async =>
      (await history()).firstWhere((p) => p.id == id,
          orElse: () => throw ApiException(404, 'Payment not found'));

  // ---------- mobile recharge ----------
  static const operators = ['Jio', 'Airtel', 'Vi', 'BSNL'];
  static const circles = [
    'Maharashtra',
    'Delhi',
    'Karnataka',
    'Tamil Nadu',
    'Gujarat'
  ];

  Future<Map<String, String>> detect(String number) async {
    await _lag();
    final d = number.codeUnits.map((c) => c - 48).toList();
    return {
      'operator': operators[d[1] % 4],
      'circle': circles[d[2] % circles.length]
    };
  }

  Future<List<Map<String, dynamic>>> plans(String op, String circle) async {
    await _lag();
    const types = ['Data', 'Unlimited', 'Talktime'];
    const validity = [1, 7, 14, 28, 56, 84, 365];
    return List.generate(500, (i) {
      final t = types[i % 3];
      return {
        'id': '$op-$i',
        'type': t,
        'price': (19 + i * 6) * 100,
        'validity': validity[i % 7],
        'benefit': switch (t) {
          'Data' => '${1 + i % 4} GB/day data',
          'Unlimited' => 'Unlimited calls + 100 SMS/day',
          _ => 'Talktime ₹${10 + i % 50}',
        },
      };
    });
  }

  Future<Payment> recharge(
      {required String number,
      required String operator,
      required int amountPaise,
      required String account,
      required String key}) async {
    await _lag();
    final dup = _existing(key);
    if (dup != null) return dup;
    if (!RegExp(r'^[6-9]\d{9}$').hasMatch(number))
      throw ApiException(422, 'Enter a valid 10-digit mobile number',
          field: 'number');
    return _record(
        key: key,
        savedId: 'recharge',
        title: 'Recharge $number',
        billerName: '$operator prepaid',
        category: 'mobile',
        amount: amountPaise,
        account: account);
  }
}

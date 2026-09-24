import 'dart:math';

const kMonths = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
const kAccounts = ['HDFC Savings ••1234', 'SBI Salary ••5678'];

/// All money is integer paise (per the spec).
String rupees(int paise) => '₹${(paise / 100).toStringAsFixed(2)}';
String fmtDate(DateTime d) => '${d.day} ${kMonths[d.month - 1]} ${d.year}';
DateTime today() {
  final n = DateTime.now();
  return DateTime(n.year, n.month, n.day);
}

/// Idempotency key: create once per payment attempt, reuse on retry.
String newKey() => '${DateTime.now().microsecondsSinceEpoch}-${Random().nextInt(1 << 30)}';

class ApiException implements Exception {
  ApiException(this.code, this.message, {this.field});
  final int code;
  final String message;
  final String? field;
  @override
  String toString() => 'ApiException($code): $message';
}

class BillCategory {
  BillCategory.fromJson(Map j)
      : id = j['id'],
        name = j['name'];
  final String id, name;
}

class FieldDef {
  FieldDef.fromJson(Map j)
      : key = j['key'],
        label = j['label'],
        regex = j['regex'],
        hint = j['hint'] ?? '',
        numeric = j['numeric'] == true;
  final String key, label, regex, hint;
  final bool numeric;
}

class Biller {
  Biller.fromJson(Map j)
      : id = j['id'],
        name = j['name'],
        category = j['category'],
        allowPartial = j['allowPartial'] == true,
        fields = (j['fields'] as List).map((e) => FieldDef.fromJson(e as Map)).toList();
  final String id, name, category;
  final bool allowPartial;
  final List<FieldDef> fields;
}

/// Validators driven by the biller definition (unit-tested).
String? validateField(FieldDef f, String? v) {
  final t = (v ?? '').trim();
  if (t.isEmpty) return '${f.label} is required';
  if (!RegExp(f.regex).hasMatch(t)) return 'Enter a valid ${f.label.toLowerCase()} (${f.hint})';
  return null;
}

String? validateAmount(int paise, int due, bool allowPartial) {
  if (paise <= 0) return 'Enter an amount greater than zero';
  if (paise > due) return 'Amount cannot exceed the due amount';
  if (!allowPartial && paise != due) return 'This biller does not allow partial payments';
  return null;
}

class SavedBiller {
  const SavedBiller({
    required this.id, required this.billerId, required this.billerName, required this.category,
    required this.nickname, required this.fields,
    this.autopay = false, this.paused = false, this.maxPaise = 0,
  });
  final String id, billerId, billerName, category, nickname;
  final Map<String, String> fields;
  final bool autopay, paused;
  final int maxPaise;

  SavedBiller copyWith({bool? autopay, bool? paused, int? maxPaise}) => SavedBiller(
      id: id, billerId: billerId, billerName: billerName, category: category, nickname: nickname, fields: fields,
      autopay: autopay ?? this.autopay, paused: paused ?? this.paused, maxPaise: maxPaise ?? this.maxPaise);

  Map<String, dynamic> toJson() => {
        'id': id, 'billerId': billerId, 'billerName': billerName, 'category': category, 'nickname': nickname,
        'fields': fields, 'autopay': autopay, 'paused': paused, 'maxPaise': maxPaise,
      };
  factory SavedBiller.fromJson(Map<String, dynamic> j) => SavedBiller(
      id: j['id'], billerId: j['billerId'], billerName: j['billerName'], category: j['category'],
      nickname: j['nickname'], fields: Map<String, String>.from(j['fields'] as Map),
      autopay: j['autopay'] == true, paused: j['paused'] == true, maxPaise: j['maxPaise'] ?? 0);
}

class Bill {
  const Bill({required this.savedId, required this.period, required this.amountPaise, this.totalPaise = 0, this.dueDate});
  final String savedId, period;
  final int amountPaise, totalPaise;
  final DateTime? dueDate;
  bool get noDue => amountPaise <= 0; // "No bill due" is a normal state, not an error
  bool get settled => totalPaise > 0 && amountPaise <= 0;
  int get daysLeft => dueDate == null ? 999 : dueDate!.difference(today()).inDays;
  bool get overdue => !noDue && daysLeft < 0;
  bool get dueSoon => !noDue && daysLeft >= 0 && daysLeft <= 3;
}

enum PayStatus { success, pending, failed }

class Payment {
  const Payment({
    required this.id, required this.key, required this.savedId, required this.title, required this.billerName,
    required this.category, required this.amountPaise, required this.account, required this.status,
    required this.billerRef, required this.bankRef, required this.at,
  });
  final String id, key, savedId, title, billerName, category, account, billerRef, bankRef;
  final int amountPaise;
  final PayStatus status;
  final DateTime at;

  Payment copyWith({PayStatus? status}) => Payment(
      id: id, key: key, savedId: savedId, title: title, billerName: billerName, category: category,
      amountPaise: amountPaise, account: account, status: status ?? this.status,
      billerRef: billerRef, bankRef: bankRef, at: at);

  Map<String, dynamic> toJson() => {
        'id': id, 'key': key, 'savedId': savedId, 'title': title, 'billerName': billerName, 'category': category,
        'amountPaise': amountPaise, 'account': account, 'status': status.name, 'billerRef': billerRef,
        'bankRef': bankRef, 'at': at.toIso8601String(),
      };
  factory Payment.fromJson(Map<String, dynamic> j) => Payment(
      id: j['id'], key: j['key'], savedId: j['savedId'], title: j['title'], billerName: j['billerName'],
      category: j['category'], amountPaise: j['amountPaise'], account: j['account'],
      status: PayStatus.values.byName(j['status']), billerRef: j['billerRef'], bankRef: j['bankRef'],
      at: DateTime.parse(j['at']));

  String get receiptText => 'BillBuddy receipt\n$title ($billerName)\nAmount: ${rupees(amountPaise)}\n'
      'Date: ${fmtDate(at)}\nPaid from: $account\nBiller ref: $billerRef\nBank ref: $bankRef\nStatus: ${status.name}';
}

class Plan {
  Plan.fromJson(Map j)
      : id = j['id'], type = j['type'], benefit = j['benefit'], pricePaise = j['price'], validityDays = j['validity'];
  final String id, type, benefit;
  final int pricePaise, validityDays;
}

class UpcomingItem {
  const UpcomingItem(this.saved, {this.bill, this.error});
  final SavedBiller saved;
  final Bill? bill;
  final String? error;
  bool get needsApproval =>
      bill != null && !bill!.noDue && saved.autopay && !saved.paused && bill!.amountPaise > saved.maxPaise;
}

class PayInfo {
  const PayInfo(this.saved, this.bill, this.partial);
  final SavedBiller saved;
  final Bill bill;
  final bool partial;
}

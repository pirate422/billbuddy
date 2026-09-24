import 'package:flutter_test/flutter_test.dart';
import 'package:billbuddy/core/models.dart';

void main() {
  final consumer = FieldDef.fromJson({'key': 'c', 'label': 'Consumer number', 'regex': r'^\d{12}$', 'hint': '12 digits', 'numeric': true});
  final account = FieldDef.fromJson({'key': 'a', 'label': 'Account ID', 'regex': r'^[A-Za-z0-9]{8,12}$', 'hint': '8-12 chars'});

  group('validateField', () {
    test('required', () => expect(validateField(consumer, ' '), contains('required')));
    test('numeric ok', () => expect(validateField(consumer, '123456789012'), isNull));
    test('numeric too short', () => expect(validateField(consumer, '1234'), isNotNull));
    test('numeric rejects letters', () => expect(validateField(consumer, '12345678901a'), isNotNull));
    test('alphanumeric ok', () => expect(validateField(account, 'ACT12345XY'), isNull));
    test('alphanumeric rejects symbols', () => expect(validateField(account, 'ACT-1234'), isNotNull));
  });

  group('validateAmount', () {
    test('zero rejected', () => expect(validateAmount(0, 5000, true), isNotNull));
    test('above due rejected', () => expect(validateAmount(6000, 5000, true), isNotNull));
    test('partial allowed', () => expect(validateAmount(2000, 5000, true), isNull));
    test('partial blocked', () => expect(validateAmount(2000, 5000, false), isNotNull));
    test('full always ok', () => expect(validateAmount(5000, 5000, false), isNull));
  });

  test('bill badges', () {
    final overdue = Bill(savedId: 's', period: 'Sep 2026', amountPaise: 100, dueDate: today().subtract(const Duration(days: 2)));
    final soon = Bill(savedId: 's', period: 'Sep 2026', amountPaise: 100, dueDate: today().add(const Duration(days: 2)));
    expect(overdue.overdue, isTrue);
    expect(soon.dueSoon, isTrue);
    expect(const Bill(savedId: 's', period: 'x', amountPaise: 0).noDue, isTrue);
  });
}

import 'package:flutter/foundation.dart';

/// Autopay settings for a saved biller
@immutable
class AutopayConfig {
  final bool enabled;
  final int maxPaise; // Money stored as integer paise

  const AutopayConfig({
    required this.enabled,
    required this.maxPaise,
  });

  factory AutopayConfig.fromJson(Map<String, dynamic> json) {
    return AutopayConfig(
      enabled: json['enabled'] as bool? ?? false,
      maxPaise: json['maxPaise'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'enabled': enabled,
      'maxPaise': maxPaise,
    };
  }
}

/// Represents a biller saved by the user with account parameters
@immutable
class SavedBiller {
  final String id;
  final String billerId;
  final String nickname;
  final Map<String, dynamic> params; // e.g. consumer number or account ID
  final AutopayConfig autopay;

  const SavedBiller({
    required this.id,
    required this.billerId,
    required this.nickname,
    required this.params,
    required this.autopay,
  });

  factory SavedBiller.fromJson(Map<String, dynamic> json) {
    return SavedBiller(
      id: json['id'] as String? ?? '',
      billerId: json['billerId'] as String? ?? '',
      nickname: json['nickname'] as String? ?? '',
      params: json['params'] as Map<String, dynamic>? ?? {},
      autopay: json['autopay'] != null
          ? AutopayConfig.fromJson(json['autopay'] as Map<String, dynamic>)
          : const AutopayConfig(enabled: false, maxPaise: 0),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'billerId': billerId,
      'nickname': nickname,
      'params': params,
      'autopay': autopay.toJson(),
    };
  }
}
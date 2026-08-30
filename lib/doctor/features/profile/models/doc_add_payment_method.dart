// lib/features/profile/models/add_payment_method.dart

import 'package:doctor/core/constants/color_constants.dart';
import 'package:flutter/material.dart';

/// Payment method types supported by the platform
enum PayoutMethod { jazzcash, easypaisa, bank }

extension PayoutMethodExtension on PayoutMethod {
  String get displayName {
    switch (this) {
      case PayoutMethod.jazzcash:
        return 'JazzCash';
      case PayoutMethod.easypaisa:
        return 'EasyPaisa';
      case PayoutMethod.bank:
        return 'Bank Transfer';
    }
  }

  IconData get icon {
    switch (this) {
      case PayoutMethod.jazzcash:
        return Icons.payments_rounded;
      case PayoutMethod.easypaisa:
        return Icons.account_balance_wallet_rounded;
      case PayoutMethod.bank:
        return Icons.account_balance_rounded;
    }
  }

  Color get iconColor {
    switch (this) {
      case PayoutMethod.jazzcash:
        return const Color(0xFFE31B23); // JazzCash red
      case PayoutMethod.easypaisa:
        return const Color(0xFF00A651); // EasyPaisa green
      case PayoutMethod.bank:
        return AppColors.primary;
    }
  }
}

/// Doctor's current payment method details
class PaymentMethodDetails {
  final PayoutMethod? method;
  final String? jazzcashNumber;
  final String? jazzcashAccountTitle;
  final String? easypaisaNumber;
  final String? easypaisaAccountTitle;
  final String? bankName;
  final String? bankAccountTitle;
  final String? bankAccountNumber;
  final String? bankIban;

  PaymentMethodDetails({
    this.method,
    this.jazzcashNumber,
    this.jazzcashAccountTitle,
    this.easypaisaNumber,
    this.easypaisaAccountTitle,
    this.bankName,
    this.bankAccountTitle,
    this.bankAccountNumber,
    this.bankIban,
  });

  factory PaymentMethodDetails.fromJson(Map<String, dynamic> json) {
    final payoutMethod = json['payout_method'] as String?;
    return PaymentMethodDetails(
      method: _parsePayoutMethod(payoutMethod),
      jazzcashNumber: json['payout_jazzcash_number'] as String?,
      jazzcashAccountTitle: json['payout_jazzcash_account_title'] as String?,
      easypaisaNumber: json['payout_easypaisa_number'] as String?,
      easypaisaAccountTitle: json['payout_easypaisa_account_title'] as String?,
      bankName: json['payout_bank_name'] as String?,
      bankAccountTitle: json['payout_bank_account_title'] as String?,
      bankAccountNumber: json['payout_bank_account_number'] as String?,
      bankIban: json['payout_bank_iban'] as String?,
    );
  }

  static PayoutMethod? _parsePayoutMethod(String? value) {
    switch (value) {
      case 'jazzcash':
        return PayoutMethod.jazzcash;
      case 'easypaisa':
        return PayoutMethod.easypaisa;
      case 'bank':
        return PayoutMethod.bank;
      default:
        return null;
    }
  }

  /// Get masked display value for current method
  String get maskedDisplay {
    switch (method) {
      case PayoutMethod.jazzcash:
        return _maskValue(jazzcashNumber);
      case PayoutMethod.easypaisa:
        return _maskValue(easypaisaNumber);
      case PayoutMethod.bank:
        return bankName ?? '';
      default:
        return '';
    }
  }

  String _maskValue(String? value) {
    if (value == null || value.isEmpty) return '';
    if (value.length <= 4) return value;
    return '••••${value.substring(value.length - 4)}';
  }

  /// Check if payment method is set
  bool get isSet => method != null;

  /// Get the display name of the current method
  String get displayName => method?.displayName ?? 'Not set';
}

/// Request model for updating payment method
class AddPaymentMethodRequest {
  final PayoutMethod method;
  final String? jazzcashNumber;
  final String? jazzcashAccountTitle;
  final String? easypaisaNumber;
  final String? easypaisaAccountTitle;
  final String? bankName;
  final String? bankAccountTitle;
  final String? bankAccountNumber;
  final String? bankIban;

  AddPaymentMethodRequest({
    required this.method,
    this.jazzcashNumber,
    this.jazzcashAccountTitle,
    this.easypaisaNumber,
    this.easypaisaAccountTitle,
    this.bankName,
    this.bankAccountTitle,
    this.bankAccountNumber,
    this.bankIban,
  });

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{'payout_method': method.name};

    switch (method) {
      case PayoutMethod.jazzcash:
        data['payout_jazzcash_number'] = jazzcashNumber ?? '';
        data['payout_jazzcash_account_title'] = jazzcashAccountTitle ?? '';
        break;
      case PayoutMethod.easypaisa:
        data['payout_easypaisa_number'] = easypaisaNumber ?? '';
        data['payout_easypaisa_account_title'] = easypaisaAccountTitle ?? '';
        break;
      case PayoutMethod.bank:
        data['payout_bank_name'] = bankName ?? '';
        data['payout_bank_account_title'] = bankAccountTitle ?? '';
        data['payout_bank_account_number'] = bankAccountNumber ?? '';
        data['payout_bank_iban'] = bankIban ?? '';
        break;
    }

    return data;
  }
}

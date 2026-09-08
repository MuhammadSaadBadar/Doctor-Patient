class PlatformPaymentMethod {
  final String? jazzcashNumber;
  final String? jazzcashAccountTitle;
  final String? easypaisaNumber;
  final String? easypaisaAccountTitle;
  final String? bankName;
  final String? bankAccountTitle;
  final String? bankAccountNumber;
  final String? bankIban;
  final String? subscriptionPriceAmount;
  final String? subscriptionPriceCurrency;
  final String? commissionPercentage;
  final DateTime? updatedAt;

  PlatformPaymentMethod({
    this.jazzcashNumber,
    this.jazzcashAccountTitle,
    this.easypaisaNumber,
    this.easypaisaAccountTitle,
    this.bankName,
    this.bankAccountTitle,
    this.bankAccountNumber,
    this.bankIban,
    this.subscriptionPriceAmount,
    this.subscriptionPriceCurrency,
    this.commissionPercentage,
    this.updatedAt,
  });

  factory PlatformPaymentMethod.fromJson(Map<String, dynamic> json) {
    return PlatformPaymentMethod(
      jazzcashNumber: json['jazzcash_number'] as String?,
      jazzcashAccountTitle: json['jazzcash_account_title'] as String?,
      easypaisaNumber: json['easypaisa_number'] as String?,
      easypaisaAccountTitle: json['easypaisa_account_title'] as String?,
      bankName: json['bank_name'] as String?,
      bankAccountTitle: json['bank_account_title'] as String?,
      bankAccountNumber: json['bank_account_number'] as String?,
      bankIban: json['bank_iban'] as String?,
      subscriptionPriceAmount: json['subscription_price_amount'] as String?,
      subscriptionPriceCurrency: json['subscription_price_currency'] as String?,
      commissionPercentage: json['commission_percentage'] as String?,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String)
          : null,
    );
  }

  bool get hasJazzCash =>
      jazzcashNumber != null && jazzcashNumber!.isNotEmpty;

  bool get hasEasyPaisa =>
      easypaisaNumber != null && easypaisaNumber!.isNotEmpty;

  bool get hasBank =>
      bankName != null &&
      bankName!.isNotEmpty &&
      bankAccountNumber != null &&
      bankAccountNumber!.isNotEmpty;

  bool get hasAnyMethod => hasJazzCash || hasEasyPaisa || hasBank;

  double? get commissionPercentageValue {
    if (commissionPercentage == null || commissionPercentage!.isEmpty) {
      return null;
    }
    return double.tryParse(commissionPercentage!);
  }

  String get subscriptionPriceDisplay {
    if (subscriptionPriceAmount == null || subscriptionPriceAmount!.isEmpty) {
      return 'Not set';
    }
    final currency = subscriptionPriceCurrency ?? 'PKR';
    return '$currency ${double.tryParse(subscriptionPriceAmount!)?.toStringAsFixed(0) ?? subscriptionPriceAmount}';
  }

  String get formattedCommission {
    if (commissionPercentage == null || commissionPercentage!.isEmpty) {
      return 'Not set';
    }
    return '${double.tryParse(commissionPercentage!)?.toStringAsFixed(0) ?? commissionPercentage}%';
  }
}

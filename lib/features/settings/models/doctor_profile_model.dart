// lib/features/profile/models/profile_models.dart

import 'package:doctor/core/constants/app_constants.dart';

class DoctorProfile {
  final String? specialization;
  final String? licenseNumber;
  final int? yearsOfExperience;
  final String? bio;
  final bool isAcceptingPatients;
  final String? city;
  final String? area;
  final String? latitude;
  final String? longitude;
  final String? consultationFee;

  // ============ PAYOUT FIELDS ============
  final String? payoutMethod;
  final String? payoutJazzcashNumber;
  final String? payoutJazzcashAccountTitle;
  final String? payoutEasypaisaNumber;
  final String? payoutEasypaisaAccountTitle;
  final String? payoutBankName;
  final String? payoutBankAccountTitle;
  final String? payoutBankAccountNumber;
  final String? payoutBankIban;
  // ========================================

  DoctorProfile({
    this.specialization,
    this.licenseNumber,
    this.yearsOfExperience,
    this.bio,
    required this.isAcceptingPatients,
    this.city,
    this.area,
    this.latitude,
    this.longitude,
    this.consultationFee,
    // Payout fields
    this.payoutMethod,
    this.payoutJazzcashNumber,
    this.payoutJazzcashAccountTitle,
    this.payoutEasypaisaNumber,
    this.payoutEasypaisaAccountTitle,
    this.payoutBankName,
    this.payoutBankAccountTitle,
    this.payoutBankAccountNumber,
    this.payoutBankIban,
  });

  factory DoctorProfile.fromJson(Map<String, dynamic> json) {
    return DoctorProfile(
      specialization: json['specialization'] as String?,
      licenseNumber: json['license_number'] as String?,
      yearsOfExperience: json['years_of_experience'] as int?,
      bio: json['bio'] as String?,
      isAcceptingPatients: json['is_accepting_patients'] as bool? ?? true,
      city: json['city'] as String?,
      area: json['area'] as String?,
      latitude: json['latitude'] as String?,
      longitude: json['longitude'] as String?,
      consultationFee: json['consultation_fee'] as String?,
      // Payout fields
      payoutMethod: json['payout_method'] as String?,
      payoutJazzcashNumber: json['payout_jazzcash_number'] as String?,
      payoutJazzcashAccountTitle:
          json['payout_jazzcash_account_title'] as String?,
      payoutEasypaisaNumber: json['payout_easypaisa_number'] as String?,
      payoutEasypaisaAccountTitle:
          json['payout_easypaisa_account_title'] as String?,
      payoutBankName: json['payout_bank_name'] as String?,
      payoutBankAccountTitle: json['payout_bank_account_title'] as String?,
      payoutBankAccountNumber: json['payout_bank_account_number'] as String?,
      payoutBankIban: json['payout_bank_iban'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (specialization != null && specialization!.isNotEmpty)
        'specialization': specialization,
      if (licenseNumber != null && licenseNumber!.isNotEmpty)
        'license_number': licenseNumber,
      if (yearsOfExperience != null) 'years_of_experience': yearsOfExperience,
      if (bio != null && bio!.isNotEmpty) 'bio': bio,
      'is_accepting_patients': isAcceptingPatients,
      if (city != null && city!.isNotEmpty) 'city': city,
      if (area != null && area!.isNotEmpty) 'area': area,
      if (latitude != null && latitude!.isNotEmpty) 'latitude': latitude,
      if (longitude != null && longitude!.isNotEmpty) 'longitude': longitude,
      if (consultationFee != null && consultationFee!.isNotEmpty)
        'consultation_fee': consultationFee,
      // Payout fields
      if (payoutMethod != null && payoutMethod!.isNotEmpty)
        'payout_method': payoutMethod,
      if (payoutJazzcashNumber != null && payoutJazzcashNumber!.isNotEmpty)
        'payout_jazzcash_number': payoutJazzcashNumber,
      if (payoutJazzcashAccountTitle != null &&
          payoutJazzcashAccountTitle!.isNotEmpty)
        'payout_jazzcash_account_title': payoutJazzcashAccountTitle,
      if (payoutEasypaisaNumber != null && payoutEasypaisaNumber!.isNotEmpty)
        'payout_easypaisa_number': payoutEasypaisaNumber,
      if (payoutEasypaisaAccountTitle != null &&
          payoutEasypaisaAccountTitle!.isNotEmpty)
        'payout_easypaisa_account_title': payoutEasypaisaAccountTitle,
      if (payoutBankName != null && payoutBankName!.isNotEmpty)
        'payout_bank_name': payoutBankName,
      if (payoutBankAccountTitle != null && payoutBankAccountTitle!.isNotEmpty)
        'payout_bank_account_title': payoutBankAccountTitle,
      if (payoutBankAccountNumber != null &&
          payoutBankAccountNumber!.isNotEmpty)
        'payout_bank_account_number': payoutBankAccountNumber,
      if (payoutBankIban != null && payoutBankIban!.isNotEmpty)
        'payout_bank_iban': payoutBankIban,
    };
  }

  String get consultationFeeDisplay {
    if (consultationFee == null || consultationFee!.isEmpty) {
      return 'Not set';
    }
    return 'Rs. $consultationFee';
  }

  String get specializationDisplay {
    return specialization ?? 'Not specified';
  }

  String get locationDisplay {
    if (city != null && city!.isNotEmpty && area != null && area!.isNotEmpty) {
      return '$area, $city';
    } else if (city != null && city!.isNotEmpty) {
      return city!;
    } else if (area != null && area!.isNotEmpty) {
      return area!;
    }
    return 'Location not set';
  }

  String get experienceDisplay {
    if (yearsOfExperience != null && yearsOfExperience! > 0) {
      return '${yearsOfExperience!} years';
    }
    return 'Not specified';
  }

  /// Check if payout method is set
  bool get hasPayoutMethod => payoutMethod != null && payoutMethod!.isNotEmpty;

  /// Get display name for payout method
  String get payoutMethodDisplay {
    switch (payoutMethod) {
      case 'jazzcash':
        return 'JazzCash';
      case 'easypaisa':
        return 'EasyPaisa';
      case 'bank':
        return 'Bank Transfer';
      default:
        return 'Not set';
    }
  }

  /// Get masked payout details for display
  String get maskedPayoutDetails {
    switch (payoutMethod) {
      case 'jazzcash':
        return _maskValue(payoutJazzcashNumber);
      case 'easypaisa':
        return _maskValue(payoutEasypaisaNumber);
      case 'bank':
        return payoutBankName ?? '';
      default:
        return '';
    }
  }

  String _maskValue(String? value) {
    if (value == null || value.isEmpty) return '';
    if (value.length <= 4) return value;
    return '••••${value.substring(value.length - 4)}';
  }

  DoctorProfile copyWith({
    String? specialization,
    String? licenseNumber,
    int? yearsOfExperience,
    String? bio,
    bool? isAcceptingPatients,
    String? city,
    String? area,
    String? latitude,
    String? longitude,
    String? consultationFee,
    // Payout fields
    String? payoutMethod,
    String? payoutJazzcashNumber,
    String? payoutJazzcashAccountTitle,
    String? payoutEasypaisaNumber,
    String? payoutEasypaisaAccountTitle,
    String? payoutBankName,
    String? payoutBankAccountTitle,
    String? payoutBankAccountNumber,
    String? payoutBankIban,
  }) {
    return DoctorProfile(
      specialization: specialization ?? this.specialization,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      yearsOfExperience: yearsOfExperience ?? this.yearsOfExperience,
      bio: bio ?? this.bio,
      isAcceptingPatients: isAcceptingPatients ?? this.isAcceptingPatients,
      city: city ?? this.city,
      area: area ?? this.area,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      consultationFee: consultationFee ?? this.consultationFee,
      // Payout fields
      payoutMethod: payoutMethod ?? this.payoutMethod,
      payoutJazzcashNumber: payoutJazzcashNumber ?? this.payoutJazzcashNumber,
      payoutJazzcashAccountTitle:
          payoutJazzcashAccountTitle ?? this.payoutJazzcashAccountTitle,
      payoutEasypaisaNumber:
          payoutEasypaisaNumber ?? this.payoutEasypaisaNumber,
      payoutEasypaisaAccountTitle:
          payoutEasypaisaAccountTitle ?? this.payoutEasypaisaAccountTitle,
      payoutBankName: payoutBankName ?? this.payoutBankName,
      payoutBankAccountTitle:
          payoutBankAccountTitle ?? this.payoutBankAccountTitle,
      payoutBankAccountNumber:
          payoutBankAccountNumber ?? this.payoutBankAccountNumber,
      payoutBankIban: payoutBankIban ?? this.payoutBankIban,
    );
  }
}

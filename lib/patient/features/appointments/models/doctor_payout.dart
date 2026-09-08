// lib/patient/features/appointments/models/doctor_payout.dart

class DoctorPayout {
  final String status;
  final String amount;

  DoctorPayout({required this.status, required this.amount});

  factory DoctorPayout.fromJson(Map<String, dynamic> json) {
    return DoctorPayout(
      status: json['status'] as String? ?? 'pending',
      amount: json['amount'] as String? ?? '0.00',
    );
  }

  String get statusDisplay {
    switch (status.toLowerCase()) {
      case 'paid':
        return 'Paid';
      case 'pending':
      default:
        return 'Pending';
    }
  }

  bool get isPaid => status.toLowerCase() == 'paid';
  bool get isPending => status.toLowerCase() == 'pending';
}
// lib/patient/features/appointments/models/appointment_payment.dart

class AppointmentPayment {
  final String doctorFee;
  final String commissionPercentage;
  final String commissionAmount;
  final String totalAmount;
  final String status;
  final DateTime? patientMarkedPaidAt;
  final DateTime? confirmedAt;
  final String paymentReference;

  AppointmentPayment({
    required this.doctorFee,
    required this.commissionPercentage,
    required this.commissionAmount,
    required this.totalAmount,
    required this.status,
    this.patientMarkedPaidAt,
    this.confirmedAt,
    required this.paymentReference,
  });

  factory AppointmentPayment.fromJson(Map<String, dynamic> json) {
    return AppointmentPayment(
      doctorFee: json['doctor_fee'] ?? '0.00',
      commissionPercentage: json['commission_percentage'] ?? '0.00',
      commissionAmount: json['commission_amount'] ?? '0.00',
      totalAmount: json['total_amount'] ?? '0.00',
      status: json['status'] ?? 'pending',
      patientMarkedPaidAt: json['patient_marked_paid_at'] != null
          ? DateTime.tryParse(json['patient_marked_paid_at'])
          : null,
      confirmedAt: json['confirmed_at'] != null
          ? DateTime.tryParse(json['confirmed_at'])
          : null,
      paymentReference: json['payment_reference'] ?? '',
    );
  }

  bool get isPending => status == 'pending';
  bool get isAwaitingVerification => status == 'awaiting_verification';
  bool get isConfirmed => status == 'confirmed';

  String get formattedTotal =>
      'Rs. ${double.tryParse(totalAmount)?.toStringAsFixed(0) ?? totalAmount}';
  String get formattedDoctorFee =>
      'Rs. ${double.tryParse(doctorFee)?.toStringAsFixed(0) ?? doctorFee}';
  String get formattedCommission =>
      'Rs. ${double.tryParse(commissionAmount)?.toStringAsFixed(0) ?? commissionAmount}';
}

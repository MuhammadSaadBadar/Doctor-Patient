// lib/patient/features/appointments/widgets/booking_fee_summary.dart

import 'package:doctor/patient/features/appointments/models/platform_payment_method.dart';
import 'package:doctor/patient/features/doctors/models/doctor.dart';
import 'package:flutter/material.dart';

class BookingFeeSummary extends StatelessWidget {
  final Doctor doctor;
  final PlatformPaymentMethod? paymentMethod;
  final String consultationFee;
  final String totalPayable;

  const BookingFeeSummary({
    super.key,
    required this.doctor,
    this.paymentMethod,
    required this.consultationFee,
    required this.totalPayable,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textScale = MediaQuery.textScalerOf(context);
    final pm = paymentMethod;
    final isFree = doctor.doctorProfile?.consultationFee == null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primary.withValues(alpha: 0.08),
            colorScheme.primary.withValues(alpha: 0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.receipt_long_rounded,
                  size: 18,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Fee Summary',
                style: TextStyle(
                  fontSize: textScale.scale(14).clamp(12.0, 16.0),
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (isFree) ...[
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle_rounded,
                    size: 16,
                    color: Colors.green.shade600,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Free consultation - no payment required',
                      style: TextStyle(
                        fontSize: textScale.scale(12).clamp(10.0, 13.0),
                        fontWeight: FontWeight.w500,
                        color: Colors.green.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            _buildFeeRow(
              context,
              label: 'Doctor Consultation Fee',
              value: consultationFee,
            ),

            const SizedBox(height: 10),
            Divider(
              color: colorScheme.outlineVariant.withValues(alpha: 0.3),
              thickness: 1,
            ),
            const SizedBox(height: 10),
            _buildFeeRow(
              context,
              label: 'Total Payable Amount',
              value: totalPayable,
              isTotal: true,
            ),
            if (pm != null && pm.hasAnyMethod) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.green.withValues(alpha: 0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.account_balance_wallet_rounded,
                          size: 16,
                          color: Colors.green.shade700,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Payment Method',
                          style: TextStyle(
                            fontSize: textScale.scale(12).clamp(10.0, 13.0),
                            fontWeight: FontWeight.w600,
                            color: Colors.green.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (pm.hasJazzCash)
                      _buildPaymentRow(
                        'JazzCash',
                        '${pm.jazzcashNumber} - ${pm.jazzcashAccountTitle}',
                      ),
                    if (pm.hasEasyPaisa)
                      _buildPaymentRow(
                        'EasyPaisa',
                        '${pm.easypaisaNumber} - ${pm.easypaisaAccountTitle}',
                      ),
                    if (pm.hasBank)
                      _buildPaymentRow(
                        'Bank',
                        '${pm.bankName} - ${pm.bankAccountNumber}',
                      ),
                  ],
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildFeeRow(
    BuildContext context, {
    required String label,
    required String value,
    bool isTotal = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final textScale = MediaQuery.textScalerOf(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: textScale.scale(isTotal ? 13 : 12).clamp(10.0, isTotal ? 15.0 : 13.0),
              fontWeight: isTotal ? FontWeight.w700 : FontWeight.w400,
              color: isTotal
                  ? colorScheme.onSurface
                  : colorScheme.onSurfaceVariant,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: textScale.scale(isTotal ? 14 : 12).clamp(10.0, isTotal ? 16.0 : 13.0),
            fontWeight: isTotal ? FontWeight.w800 : FontWeight.w600,
            color: isTotal ? colorScheme.primary : colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Colors.green.shade600,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.green.shade800,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

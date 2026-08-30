// lib/features/appointments/widgets/payment_status_widget.dart
import 'package:doctor/core/constants/color_constants.dart';
import 'package:doctor/core/themes/app_theme.dart';
import 'package:doctor/doctor/features/appointments/models/doc_appointment_schedule.dart';
import 'package:flutter/material.dart';

class PaymentStatusWidget extends StatelessWidget {
  final AppointmentPayment? payment;
  final bool isLoading;
  final VoidCallback? onConfirmPayment;

  const PaymentStatusWidget({
    super.key,
    required this.payment,
    this.isLoading = false,
    this.onConfirmPayment,
  });

  @override
  Widget build(BuildContext context) {
    if (payment == null) {
      return _buildNoPaymentCard();
    }

    return _buildPaymentCard();
  }

  Widget _buildNoPaymentCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outlineVariant, width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.payment_outlined,
              size: 22,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Payment',
                  style: AppTheme.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurface,
                  ),
                ),
                Text(
                  'No payment required for this consultation',
                  style: AppTheme.bodySmall.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(9999),
            ),
            child: Text(
              'Free',
              style: AppTheme.labelSmall.copyWith(
                color: AppColors.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentCard() {
    final status = payment!.status;
    final isAwaitingVerification =
        status == AppointmentPaymentStatus.awaitingVerification;
    final isConfirmed = status == AppointmentPaymentStatus.confirmed;
    final isPending = status == AppointmentPaymentStatus.pending;
    final canConfirm = isPending || isAwaitingVerification;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outlineVariant, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: payment!.statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  isConfirmed ? Icons.payment_rounded : Icons.pending_rounded,
                  size: 22,
                  color: payment!.statusColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Payment Status',
                      style: AppTheme.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.onSurface,
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: payment!.statusColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          payment!.statusDisplay,
                          style: AppTheme.bodySmall.copyWith(
                            color: payment!.statusColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Text(
                payment!.totalAmount,
                style: AppTheme.titleMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          const Divider(color: AppColors.surfaceContainerLow, height: 1),
          const SizedBox(height: 12),

          // Payment Details
          _buildDetailRow('Doctor Fee', payment!.doctorFee),
          _buildDetailRow('Commission', payment!.commissionAmount),
          _buildDetailRow('Total', payment!.totalAmount, isBold: true),

          if (payment!.patientMarkedPaidAt != null) ...[
            const SizedBox(height: 8),
            _buildDetailRow(
              'Patient Marked Paid',
              _formatDateTime(payment!.patientMarkedPaidAt!),
            ),
          ],

          if (payment!.confirmedAt != null) ...[
            const SizedBox(height: 8),
            _buildDetailRow(
              'Confirmed At',
              _formatDateTime(payment!.confirmedAt!),
            ),
          ],

          if (payment!.paymentReference.isNotEmpty) ...[
            const SizedBox(height: 8),
            _buildDetailRow('Reference', payment!.paymentReference),
          ],

          // Action Button
          if (canConfirm && onConfirmPayment != null) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: isLoading ? null : onConfirmPayment,
                icon: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.onPrimary,
                        ),
                      )
                    : const Icon(Icons.check_circle_outline_rounded, size: 20),
                label: Text(
                  isLoading ? 'Confirming...' : 'Confirm Payment Received',
                  style: AppTheme.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
              ),
            ),
            if (isAwaitingVerification) ...[
              const SizedBox(height: 8),
              Text(
                'Patient has marked this as paid. Verify the payment in your bank account and confirm.',
                style: AppTheme.bodySmall.copyWith(
                  color: AppColors.onSurfaceVariant,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],

          if (isConfirmed) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.08),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle_rounded,
                    size: 18,
                    color: Colors.green.shade700,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Payment confirmed. Appointment is confirmed.',
                      style: AppTheme.bodySmall.copyWith(
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTheme.bodySmall.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              '$value PKR',
              style: AppTheme.bodySmall.copyWith(
                color: isBold
                    ? AppColors.onSurface
                    : AppColors.onSurfaceVariant,
                fontWeight: isBold ? FontWeight.w700 : FontWeight.w400,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return '—';
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

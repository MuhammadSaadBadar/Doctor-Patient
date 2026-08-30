// lib/features/profile/widgets/add_payment_method_option.dart

import 'package:doctor/core/constants/color_constants.dart';
import 'package:doctor/core/themes/app_theme.dart';
import 'package:doctor/doctor/features/profile/models/doc_add_payment_method.dart';
import 'package:flutter/material.dart';

class AddPaymentMethodOption extends StatelessWidget {
  final PayoutMethod method;
  final bool isSelected;
  final VoidCallback onTap;

  const AddPaymentMethodOption({
    super.key,
    required this.method,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.05)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.outlineVariant,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Radio button
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.outline,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            // Icon
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: method.iconColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(method.icon, size: 18, color: method.iconColor),
            ),
            const SizedBox(width: 12),
            // Label
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    method.displayName,
                    style: AppTheme.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurface,
                      fontSize: isMobile ? 14 : 16,
                    ),
                  ),
                  Text(
                    _getSubtitle(method),
                    style: AppTheme.bodySmall.copyWith(
                      color: AppColors.onSurfaceVariant,
                      fontSize: isMobile ? 11 : 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getSubtitle(PayoutMethod method) {
    switch (method) {
      case PayoutMethod.jazzcash:
        return 'Receive payments via JazzCash';
      case PayoutMethod.easypaisa:
        return 'Receive payments via EasyPaisa';
      case PayoutMethod.bank:
        return 'Receive payments via bank transfer';
    }
  }
}

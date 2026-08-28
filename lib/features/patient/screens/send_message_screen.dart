// lib/features/patient/screens/send_message_screen.dart

import 'package:doctor/core/constants/color_constants.dart';
import 'package:doctor/core/themes/app_theme.dart';
import 'package:doctor/core/widgets/top_app_bar.dart';
import 'package:doctor/features/patient/controllers/send_message_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SendMessageScreen extends GetView<SendMessageController> {
  const SendMessageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 1024;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
      body: Column(
        children: [
          const TopAppNavBar.gradient(
            title: 'Send Message',
            height: 64,
            showBackButton: true,
          ),
          Expanded(
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 32.0 : 16.0,
                vertical: 16.0,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPatientCard(),
                    const SizedBox(height: 20),
                    _buildMessageForm(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPatientCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.cardDecoration(context: Get.context!),
      child: Row(
        children: [
          // Patient avatar
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                controller.patientInitials,
                style: AppTheme.headlineSmall.copyWith(
                  color: AppColors.onPrimaryContainer,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Patient info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  controller.patientName,
                  style: AppTheme.headlineSmall.copyWith(
                    color: AppColors.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                // const SizedBox(height: 4),
                // Wrap(
                //   spacing: 16,
                //   runSpacing: 4,
                //   children: [
                //     _buildPatientInfoChip(
                //       icon: Icons.cake_rounded,
                //       label: 'DOB: ${controller.patient?.age ?? 'N/A'} yrs',
                //     ),
                //     _buildPatientInfoChip(
                //       icon: Icons.pregnant_woman_rounded,
                //       label: 'Week ${controller.patientWeek}',
                //     ),
                //     _buildPatientInfoChip(
                //       icon: Icons.badge_rounded,
                //       label: 'ID: ${controller.patientDisplayId}',
                //     ),
                //   ],
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPatientInfoChip({
    required IconData icon,
    required String label,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.onSurfaceVariant),
        const SizedBox(width: 4),
        Text(
          label,
          style: AppTheme.bodySmall.copyWith(color: AppColors.onSurfaceVariant),
        ),
      ],
    );
  }

  Widget _buildMessageForm() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.cardDecoration(context: Get.context!),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Subject Field
          _buildSubjectField(),
          const SizedBox(height: 20),

          // Message Body Field
          _buildMessageField(),
          const SizedBox(height: 20),

          // Urgent Toggle
          _buildUrgentToggle(),
          const SizedBox(height: 20),

          // Divider
          const Divider(color: AppColors.surfaceContainerLow, height: 1),

          // Action Buttons
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildSubjectField() {
    return Obx(
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Subject',
                style: AppTheme.labelMedium.copyWith(
                  color: AppColors.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Text(' *', style: TextStyle(color: AppColors.error)),
            ],
          ),
          const SizedBox(height: 6),
          TextField(
            controller: controller.subjectController,
            maxLength: SendMessageController.maxSubjectLength,
            decoration: InputDecoration(
              hintText: 'Enter message subject',
              hintStyle: TextStyle(
                color: AppColors.onSurfaceVariant.withOpacity(0.5),
              ),
              filled: true,
              fillColor: AppColors.surfaceContainerLow,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.transparent),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.transparent),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: AppColors.secondary, width: 2),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: AppColors.error, width: 2),
              ),
              errorText: controller.subjectError.value.isNotEmpty
                  ? controller.subjectError.value
                  : null,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
              counter: Container(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  '${controller.subjectCount.value}/${SendMessageController.maxSubjectLength}',
                  style: AppTheme.bodySmall.copyWith(color: AppColors.outline),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageField() {
    return Obx(
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Message Body',
                style: AppTheme.labelMedium.copyWith(
                  color: AppColors.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Text(' *', style: TextStyle(color: AppColors.error)),
            ],
          ),
          const SizedBox(height: 6),
          TextField(
            controller: controller.messageController,
            maxLength: SendMessageController.maxMessageLength,
            maxLines: 6,
            minLines: 4,
            decoration: InputDecoration(
              hintText: 'Type your message here...',
              hintStyle: TextStyle(
                color: AppColors.onSurfaceVariant.withOpacity(0.5),
              ),
              filled: true,
              fillColor: AppColors.surfaceContainerLow,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.transparent),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.transparent),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: AppColors.secondary, width: 2),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: AppColors.error, width: 2),
              ),
              errorText: controller.messageError.value.isNotEmpty
                  ? controller.messageError.value
                  : null,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
              counter: Container(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  '${controller.messageCount.value}/${SendMessageController.maxMessageLength}',
                  style: AppTheme.bodySmall.copyWith(color: AppColors.outline),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUrgentToggle() {
    return Obx(
      () => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.outlineVariant, width: 1),
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.errorContainer,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.priority_high_rounded,
                size: 18,
                color: AppColors.error,
              ),
            ),
            const SizedBox(width: 12),
            // Labels
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mark as Important',
                    style: AppTheme.headlineSmall.copyWith(
                      fontSize: 14,
                      color: AppColors.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Patient will receive an urgent notification',
                    style: AppTheme.bodySmall.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            // Toggle
            GestureDetector(
              onTap: () => controller.isUrgent.toggle(),
              child: Container(
                width: 44,
                height: 24,
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: controller.isUrgent.value
                      ? AppColors.error
                      : AppColors.outlineVariant,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: AnimatedAlign(
                  duration: const Duration(milliseconds: 200),
                  alignment: controller.isUrgent.value
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Obx(
      () => Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Cancel Button
          Expanded(
            flex: 1,
            child: SizedBox(
              height: 48,
              child: OutlinedButton(
                onPressed: controller.isSubmitting.value
                    ? null
                    : controller.cancel,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  disabledForegroundColor: AppColors.onSurfaceVariant
                      .withOpacity(0.4),
                ),
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.05,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Send Button
          Expanded(
            flex: 2,
            child: SizedBox(
              height: 48,
              child: ElevatedButton.icon(
                onPressed: controller.isSubmitting.value
                    ? null
                    : controller.sendMessage,
                icon: controller.isSubmitting.value
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.onPrimary,
                        ),
                      )
                    : const Icon(
                        Icons.send_rounded,
                        size: 18,
                        color: AppColors.onPrimary,
                      ),
                label: Text(
                  controller.isSubmitting.value ? 'Sending...' : 'Send Message',
                  style: const TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.05,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  disabledBackgroundColor: AppColors.primary.withOpacity(0.4),
                  disabledForegroundColor: AppColors.onPrimary.withOpacity(0.6),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
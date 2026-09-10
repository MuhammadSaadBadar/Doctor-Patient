// lib/patient/features/emergency/screens/generate_sos_screen.dart

import 'package:doctor/core/localization/translation_keys.dart';
import 'package:doctor/core/widgets/patient_top_app_bar.dart';
import 'package:doctor/patient/features/emergency/controllers/generate_sos_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class GenerateSosScreen extends GetView<GenerateSosController> {
  const GenerateSosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colors.background,
      appBar: PatientTopAppBar(title: TranslationKeys.sosGenerate.tr),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
        child: Obx(
          () => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Hero ─────────────────────────────────────────────────
              _buildHero(colors),
              const SizedBox(height: 28),

              // ── Notes ────────────────────────────────────────────────
              _buildNotesSection(colors),
              const SizedBox(height: 16),

              // ── Location ─────────────────────────────────────────────
              _buildLocationRow(colors),
              const SizedBox(height: 32),

              // ── SOS Button ───────────────────────────────────────────
              _buildSosButton(colors),
              const SizedBox(height: 20),

              // ── Disclaimer ───────────────────────────────────────────
              _buildDisclaimer(colors),
            ],
          ),
        ),
      ),
    );
  }

  // ── Hero section with concentric ring effect ──────────────────────────────
  Widget _buildHero(ColorScheme colors) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
      decoration: BoxDecoration(
        color: colors.errorContainer.withOpacity(0.10),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colors.error.withOpacity(0.18), width: 1.5),
      ),
      child: Column(
        children: [
          // Concentric rings around the emergency icon
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 112,
                height: 112,
                decoration: BoxDecoration(
                  color: colors.errorContainer.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
              ),
              Container(
                width: 82,
                height: 82,
                decoration: BoxDecoration(
                  color: colors.errorContainer.withOpacity(0.22),
                  shape: BoxShape.circle,
                ),
              ),
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: colors.errorContainer.withOpacity(0.50),
                  shape: BoxShape.circle,
                ),
              ),
              Icon(Icons.emergency_rounded, size: 30, color: colors.error),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            TranslationKeys.sosEmergencyAlert.tr,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: colors.error,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            TranslationKeys.sosAlertDesc.tr,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: colors.onSurfaceVariant,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // ── Notes input section ───────────────────────────────────────────────────
  Widget _buildNotesSection(ColorScheme colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.edit_note_rounded,
              size: 16,
              color: colors.onSurfaceVariant,
            ),
            const SizedBox(width: 6),
            Text(
              TranslationKeys.sosAdditionalDetails.tr,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: colors.onSurface,
              ),
            ),
            Text(
              ' — ${TranslationKeys.sosOptional.tr}',
              style: TextStyle(fontSize: 13, color: colors.onSurfaceVariant),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller.notesController,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: TranslationKeys.sosNotesHint.tr,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: colors.outlineVariant),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: colors.outlineVariant),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: colors.primary, width: 1.5),
            ),
            filled: true,
            fillColor: colors.surfaceContainerLowest,
            contentPadding: const EdgeInsets.all(16),
            alignLabelWithHint: true,
          ),
        ),
      ],
    );
  }

  // ── Location capture row ──────────────────────────────────────────────────
  Widget _buildLocationRow(ColorScheme colors) {
    final hasLocation = controller.locationMessage.value.isNotEmpty;
    final isLoading = controller.isLoadingLocation.value;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      decoration: BoxDecoration(
        color: hasLocation
            ? colors.primaryContainer.withOpacity(0.40)
            : colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: hasLocation
              ? colors.primary.withOpacity(0.35)
              : colors.outlineVariant,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: isLoading ? null : controller.captureLocation,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            child: Row(
              children: [
                // Icon container
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: hasLocation
                        ? colors.primary.withOpacity(0.12)
                        : colors.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: isLoading
                      ? Center(
                          child: SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: colors.primary,
                            ),
                          ),
                        )
                      : Icon(
                          hasLocation
                              ? Icons.location_on_rounded
                              : Icons.add_location_alt_rounded,
                          size: 20,
                          color: hasLocation
                              ? colors.primary
                              : colors.onSurfaceVariant,
                        ),
                ),
                const SizedBox(width: 12),
                // Label + message
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hasLocation
                            ? TranslationKeys.sosLocationCaptured.tr
                            : TranslationKeys.sosAddLocation.tr,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: hasLocation
                              ? colors.primary
                              : colors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        hasLocation
                            ? controller.locationMessage.value
                            : '${TranslationKeys.sosOptional.tr} — ${TranslationKeys.sosCheckLocation.tr}',
                        style: TextStyle(
                          fontSize: 12,
                          color: colors.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Trailing indicator
                hasLocation
                    ? Icon(
                        Icons.check_circle_rounded,
                        color: colors.primary,
                        size: 20,
                      )
                    : Icon(
                        Icons.chevron_right_rounded,
                        color: colors.onSurfaceVariant,
                        size: 20,
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── SOS submit button ─────────────────────────────────────────────────────
  Widget _buildSosButton(ColorScheme colors) {
    final isSubmitting = controller.isSubmitting.value;
    return SizedBox(
      height: 58,
      child: ElevatedButton(
        onPressed: isSubmitting ? null : controller.submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.error,
          foregroundColor: colors.onError,
          disabledBackgroundColor: colors.error.withOpacity(0.55),
          disabledForegroundColor: colors.onError.withOpacity(0.70),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: isSubmitting
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: colors.onError,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    TranslationKeys.sosSend.tr,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: colors.onError,
                    ),
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.sos_rounded, size: 22),
                  SizedBox(width: 10),
                  Text(
                    TranslationKeys.sosSend.tr,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
      ),
    );
  }

  // ── Disclaimer ────────────────────────────────────────────────────────────
  Widget _buildDisclaimer(ColorScheme colors) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 1),
          child: Icon(
            Icons.info_outline_rounded,
            size: 14,
            color: colors.onSurfaceVariant,
          ),
        ),
        const SizedBox(width: 7),
        Expanded(
          child: Text(
            TranslationKeys.sosDisclaimer.tr,
            style: TextStyle(
              fontSize: 12,
              color: colors.onSurfaceVariant,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}

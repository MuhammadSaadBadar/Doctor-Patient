// lib/patient/features/symptoms/screens/symptoms_screen.dart

import 'package:doctor/patient/features/symptoms/controllers/symptoms_controller.dart';
import 'package:doctor/patient/features/symptoms/models/symptom_log.dart';
import 'package:doctor/core/widgets/patient_top_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SymptomsScreen extends GetView<SymptomsController> {
  const SymptomsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textScale = MediaQuery.textScalerOf(context);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: PatientTopAppBar(
        title: 'Symptoms Tracker',
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.symptomLogs.isEmpty) {
          return _buildLoadingState(context);
        }

        if (controller.hasError.value) {
          return _buildErrorState(context);
        }

        return RefreshIndicator(
          onRefresh: controller.refreshData,
          color: colorScheme.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize:
                  MainAxisSize.min, // ✅ Prevents unbounded height issues
              children: [
                _buildLogSymptomsCard(context),
                const SizedBox(height: 24),
                _buildHistorySection(context),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildLogSymptomsCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textScale = MediaQuery.textScalerOf(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min, // ✅ Prevents unbounded height issues
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.pink.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.sick_rounded,
                  size: 20,
                  color: Colors.pink,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Log Today\'s Symptoms',
                  style: TextStyle(
                    fontSize: textScale.scale(14).clamp(12.0, 18.0),
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            // ✅ Removed Flexible wrapper
            'How are you feeling today?',
            style: TextStyle(
              fontSize: textScale.scale(12).clamp(10.0, 16.0),
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          Obx(
            () => Wrap(
              spacing: 8,
              runSpacing: 8,
              children: controller.symptomTypes.map((type) {
                final id = type['id'] as int;
                final name = type['name'] as String;
                final isSelected = controller.selectedSymptomIds.contains(id);
                return FilterChip(
                  label: Text(name),
                  selected: isSelected,
                  onSelected: (_) => controller.toggleSymptom(id),
                  selectedColor: colorScheme.primary.withValues(alpha: 0.2),
                  checkmarkColor: colorScheme.primary,
                  labelStyle: TextStyle(
                    color: isSelected
                        ? colorScheme.primary
                        : colorScheme.onSurface,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: controller.notesController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Additional notes (optional)',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colorScheme.outlineVariant),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colorScheme.primary, width: 2),
              ),
              contentPadding: const EdgeInsets.all(12),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: Obx(
              () => ElevatedButton(
                onPressed: controller.isLoading.value
                    ? null
                    : controller.saveTodaysSymptoms,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: controller.isLoading.value
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        'Save Symptoms',
                        style: TextStyle(
                          fontSize: textScale.scale(14).clamp(12.0, 18.0),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistorySection(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textScale = MediaQuery.textScalerOf(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min, // ✅ Prevents unbounded height issues
      children: [
        Text(
          'Recent Logs',
          style: TextStyle(
            fontSize: textScale.scale(16).clamp(14.0, 20.0),
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        Obx(() {
          if (controller.symptomLogs.isEmpty) {
            return Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min, // ✅ Added
                  children: [
                    Icon(
                      Icons.sick_rounded,
                      size: 48,
                      color: colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No symptoms logged yet',
                      style: TextStyle(
                        fontSize: textScale.scale(14).clamp(12.0, 18.0),
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      // ✅ Removed Flexible wrapper
                      'Tap above to log how you\'re feeling',
                      style: TextStyle(
                        fontSize: textScale.scale(11).clamp(9.0, 15.0),
                        color: colorScheme.onSurfaceVariant.withValues(
                          alpha: 0.7,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return Column(
            mainAxisSize: MainAxisSize.min, // ✅ Added
            children: controller.symptomLogs
                .map((log) => _buildSymptomLogCard(context, log))
                .toList(),
          );
        }),
      ],
    );
  }

  Widget _buildSymptomLogCard(BuildContext context, SymptomLog log) {
    final colorScheme = Theme.of(context).colorScheme;
    final textScale = MediaQuery.textScalerOf(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min, // ✅ Prevents unbounded height issues
        children: [
          Row(
            children: [
              Text(
                // ✅ Removed Flexible wrapper
                log.dateLabel,
                style: TextStyle(
                  fontSize: textScale.scale(12).clamp(10.0, 16.0),
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              if (log.isToday) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'TODAY',
                    style: TextStyle(
                      fontSize: textScale.scale(9).clamp(7.0, 12.0),
                      fontWeight: FontWeight.w600,
                      color: colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: log.symptoms.map((symptom) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  symptom.name,
                  style: TextStyle(
                    fontSize: textScale.scale(11).clamp(9.0, 15.0),
                    fontWeight: FontWeight.w500,
                    color: colorScheme.primary,
                  ),
                ),
              );
            }).toList(),
          ),
          if (log.notes != null && log.notes!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              // ✅ Removed Flexible wrapper
              log.notes!,
              style: TextStyle(
                fontSize: textScale.scale(11).clamp(9.0, 15.0),
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: colorScheme.primary),
          const SizedBox(height: 16),
          Text(
            'Loading symptoms...',
            style: TextStyle(
              fontSize: MediaQuery.textScalerOf(
                context,
              ).scale(14).clamp(12.0, 18.0),
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textScale = MediaQuery.textScalerOf(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min, // ✅ Prevents unbounded height issues
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load',
              style: TextStyle(
                fontSize: textScale.scale(16).clamp(14.0, 20.0),
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              // ✅ Removed Flexible wrapper
              controller.errorMessage.value,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: textScale.scale(12).clamp(10.0, 16.0),
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: controller.refreshData,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

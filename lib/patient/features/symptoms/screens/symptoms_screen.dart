// lib/patient/features/symptoms/screens/symptoms_screen.dart

import 'package:doctor/core/constants/color_constants.dart';
import 'package:doctor/patient/features/symptoms/controllers/symptoms_controller.dart';
import 'package:doctor/patient/features/symptoms/models/symptom_log.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SymptomsScreen extends GetView<SymptomsController> {
  const SymptomsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: colorScheme.onSurface),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Symptoms Tracker',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
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

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.pink.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.sick_rounded, size: 20, color: Colors.pink),
              ),
              const SizedBox(width: 12),
              Text(
                'Log Today\'s Symptoms',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'How are you feeling today?',
            style: TextStyle(
              fontSize: 14,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          Obx(() => Wrap(
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
                selectedColor: colorScheme.primary.withOpacity(0.2),
                checkmarkColor: colorScheme.primary,
                labelStyle: TextStyle(
                  color: isSelected ? colorScheme.primary : colorScheme.onSurface,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              );
            }).toList(),
          )),
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
            child: Obx(() => ElevatedButton(
              onPressed: controller.isLoading.value ? null : controller.saveTodaysSymptoms,
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: controller.isLoading.value
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Save Symptoms', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            )),
          ),
        ],
      ),
    );
  }

  Widget _buildHistorySection(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Logs',
          style: TextStyle(
            fontSize: 18,
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
                border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.3)),
              ),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.sick_rounded, size: 48, color: colorScheme.onSurfaceVariant.withOpacity(0.5)),
                    const SizedBox(height: 12),
                    Text(
                      'No symptoms logged yet',
                      style: TextStyle(fontSize: 16, color: colorScheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tap above to log how you\'re feeling',
                      style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant.withOpacity(0.7)),
                    ),
                  ],
                ),
              ),
            );
          }

          return Column(
            children: controller.symptomLogs.map((log) => _buildSymptomLogCard(log, colorScheme)).toList(),
          );
        }),
      ],
    );
  }

  Widget _buildSymptomLogCard(SymptomLog log, ColorScheme colorScheme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                log.dateLabel,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              if (log.isToday) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'TODAY',
                    style: TextStyle(
                      fontSize: 10,
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
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  symptom.name,
                  style: TextStyle(
                    fontSize: 13,
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
              log.notes!,
              style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant),
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
          Text('Loading symptoms...', style: TextStyle(color: colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline_rounded, size: 48, color: colorScheme.error),
            const SizedBox(height: 16),
            Text('Failed to load', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: colorScheme.onSurface)),
            const SizedBox(height: 8),
            Text(controller.errorMessage.value, textAlign: TextAlign.center, style: TextStyle(color: colorScheme.onSurfaceVariant)),
            const SizedBox(height: 24),
            ElevatedButton(onPressed: controller.refreshData, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
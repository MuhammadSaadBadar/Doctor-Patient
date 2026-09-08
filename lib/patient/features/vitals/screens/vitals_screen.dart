// lib/patient/features/vitals/screens/vitals_screen.dart

import 'package:doctor/core/constants/color_constants.dart';
import 'package:doctor/patient/features/vitals/controllers/vitals_controller.dart';
import 'package:doctor/patient/features/vitals/models/vital_reading.dart';
import 'package:doctor/core/widgets/patient_top_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class VitalsScreen extends GetView<VitalsController> {
  const VitalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: PatientTopAppBar(
        title: 'Vitals',
      ),
      body: Column(
        children: [
          Obx(
            () => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: colorScheme.outlineVariant.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    _buildTabButton(
                      'Blood Pressure',
                      0,
                      Icons.favorite_rounded,
                      colorScheme,
                    ),
                    _buildTabButton(
                      'Blood Sugar',
                      1,
                      Icons.bloodtype_rounded,
                      colorScheme,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value &&
                  (controller.bpHistory.isEmpty && controller.sugarHistory.isEmpty)) {
                return _buildLoadingState(context);
              }

              if (controller.hasError.value) {
                return _buildErrorState(context);
              }

              return RefreshIndicator(
                onRefresh: controller.refreshData,
                color: colorScheme.primary,
                child: controller.selectedTab.value == 0
                    ? _buildBPTab(context)
                    : _buildSugarTab(context),
              );
            }),
          ),
        ],
      ),
      floatingActionButton: Obx(
        () => FloatingActionButton(
          onPressed: () =>
              _showLogDialog(context, controller.selectedTab.value),
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          child: Icon(
            controller.selectedTab.value == 0
                ? Icons.favorite_rounded
                : Icons.bloodtype_rounded,
          ),
        ),
      ),
    );
  }

  Widget _buildTabButton(
    String label,
    int index,
    IconData icon,
    ColorScheme colorScheme,
  ) {
    final isSelected = controller.selectedTab.value == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => controller.selectedTab.value = index,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? colorScheme.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected
                    ? colorScheme.onPrimary
                    : colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isSelected
                      ? colorScheme.onPrimary
                      : colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBPTab(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (controller.bpHistory.isNotEmpty)
            _buildLatestBPCard(controller.bpHistory.first, colorScheme),
          const SizedBox(height: 16),
          _buildHistoryList(
            controller.bpHistory,
            'Blood Pressure History',
            (bp) => _buildBPHistoryItem(bp, colorScheme),
            colorScheme,
          ),
        ],
      ),
    );
  }

  Widget _buildSugarTab(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (controller.sugarHistory.isNotEmpty)
            _buildLatestSugarCard(controller.sugarHistory.first, colorScheme),
          const SizedBox(height: 16),
          _buildHistoryList(
            controller.sugarHistory,
            'Blood Sugar History',
            (sugar) => _buildSugarHistoryItem(sugar, colorScheme),
            colorScheme,
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList<T>(
    List<T> items,
    String title,
    Widget Function(T) itemBuilder,
    ColorScheme colorScheme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        if (items.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: colorScheme.outlineVariant.withOpacity(0.3),
              ),
            ),
            child: Center(
              child: Text(
                'No readings yet',
                style: TextStyle(color: colorScheme.onSurfaceVariant),
              ),
            ),
          )
        else
          Column(children: items.map((e) => itemBuilder(e)).toList()),
      ],
    );
  }

  Widget _buildLatestBPCard(BloodPressureReading bp, ColorScheme colorScheme) {
    final isNormal = bp.isNormal;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            (isNormal ? Colors.green : Colors.orange).withOpacity(0.12),
            (isNormal ? Colors.green : Colors.orange).withOpacity(0.04),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: (isNormal ? Colors.green : Colors.orange).withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.favorite_rounded,
                size: 20,
                color: isNormal ? Colors.green : Colors.orange,
              ),
              const SizedBox(width: 8),
              Text(
                'Latest Reading',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: (isNormal ? Colors.green : Colors.orange).withOpacity(
                    0.12,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  bp.status,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isNormal ? Colors.green : Colors.orange,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildVitalStat(
                'Systolic',
                '${bp.systolic}',
                'mmHg',
                colorScheme,
              ),
              _buildVitalStat(
                'Diastolic',
                '${bp.diastolic}',
                'mmHg',
                colorScheme,
              ),
              if (bp.pulse != null)
                _buildVitalStat('Pulse', '${bp.pulse}', 'bpm', colorScheme),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _formatDateTime(bp.recordedAt),
            style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Widget _buildLatestSugarCard(
    BloodSugarReading sugar,
    ColorScheme colorScheme,
  ) {
    final isNormal = sugar.isNormal;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            (isNormal ? Colors.green : Colors.red).withOpacity(0.12),
            (isNormal ? Colors.green : Colors.red).withOpacity(0.04),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: (isNormal ? Colors.green : Colors.red).withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.bloodtype_rounded,
                size: 20,
                color: isNormal ? Colors.green : Colors.red,
              ),
              const SizedBox(width: 8),
              Text(
                'Latest Reading',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: (isNormal ? Colors.green : Colors.red).withOpacity(
                    0.12,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  isNormal ? 'Normal' : 'High',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isNormal ? Colors.green : Colors.red,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${sugar.valueMgDl}',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w800,
                  color: colorScheme.onSurface,
                ),
              ),
              Text(
                ' mg/dL',
                style: TextStyle(
                  fontSize: 18,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Center(
            child: Text(
              sugar.contextLabel,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _formatDateTime(sugar.recordedAt),
            style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildVitalStat(
    String label,
    String value,
    String unit,
    ColorScheme colorScheme,
  ) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
          ),
        ),
        Text(
          unit,
          style: TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }

  Widget _buildBPHistoryItem(BloodPressureReading bp, ColorScheme colorScheme) {
    final isNormal = bp.isNormal;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: (isNormal ? Colors.green : Colors.orange).withOpacity(
                0.12,
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.favorite_rounded,
              size: 22,
              color: isNormal ? Colors.green : Colors.orange,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${bp.systolic}/${bp.diastolic} mmHg',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                Text(
                  '${bp.pulse != null ? '♥ ${bp.pulse} bpm • ' : ''}${_formatDateTime(bp.recordedAt)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: (isNormal ? Colors.green : Colors.orange).withOpacity(
                0.12,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              bp.status,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: isNormal ? Colors.green : Colors.orange,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSugarHistoryItem(
    BloodSugarReading sugar,
    ColorScheme colorScheme,
  ) {
    final isNormal = sugar.isNormal;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: (isNormal ? Colors.green : Colors.red).withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.bloodtype_rounded,
              size: 22,
              color: isNormal ? Colors.green : Colors.red,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${sugar.valueMgDl} mg/dL',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                Text(
                  '${sugar.contextLabel} • ${_formatDateTime(sugar.recordedAt)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: (isNormal ? Colors.green : Colors.red).withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              isNormal ? 'Normal' : 'High',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: isNormal ? Colors.green : Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLogDialog(BuildContext context, int tab) {
    final colorScheme = Theme.of(context).colorScheme;
    final isBP = tab == 0;

    if (isBP) {
      final systolicController = TextEditingController();
      final diastolicController = TextEditingController();
      final pulseController = TextEditingController();

      Get.dialog(
        AlertDialog(
          title: const Text('Log Blood Pressure'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: systolicController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Systolic',
                        hintText: '120',
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: diastolicController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Diastolic',
                        hintText: '80',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: pulseController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Pulse (optional)',
                  hintText: '72',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final sys = int.tryParse(systolicController.text);
                final dia = int.tryParse(diastolicController.text);
                final pulse = int.tryParse(pulseController.text);
                if (sys != null && dia != null) {
                  Get.back();
                  controller.logBloodPressure(
                    systolic: sys,
                    diastolic: dia,
                    pulse: pulse,
                  );
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      );
    } else {
      final valueController = TextEditingController();
      String selectedContext = 'fasting';

      Get.dialog(
        AlertDialog(
          title: const Text('Log Blood Sugar'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: valueController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Value (mg/dL)',
                  hintText: '95',
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: selectedContext,
                decoration: const InputDecoration(labelText: 'Context'),
                items: const [
                  DropdownMenuItem(value: 'fasting', child: Text('Fasting')),
                  DropdownMenuItem(
                    value: 'post_meal',
                    child: Text('Post-Meal'),
                  ),
                  DropdownMenuItem(value: 'random', child: Text('Random')),
                ],
                onChanged: (v) => selectedContext = v!,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final val = int.tryParse(valueController.text);
                if (val != null) {
                  Get.back();
                  controller.logBloodSugar(
                    valueMgDl: val,
                    readingContext: selectedContext,
                  );
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      );
    }
  }

  String _formatDateTime(DateTime date) {
    final hour = date.hour > 12
        ? date.hour - 12
        : (date.hour == 0 ? 12 : date.hour);
    final minute = date.minute.toString().padLeft(2, '0');
    final amPm = date.hour >= 12 ? 'PM' : 'AM';
    return '${date.day}/${date.month}/${date.year} $hour:$minute $amPm';
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
            'Loading...',
            style: TextStyle(color: colorScheme.onSurfaceVariant),
          ),
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
            Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              controller.errorMessage.value,
              textAlign: TextAlign.center,
              style: TextStyle(color: colorScheme.onSurfaceVariant),
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

// lib/patient/features/surgical_procedures/controllers/surgical_procedure_controller.dart

import 'package:doctor/patient/features/surgical_procedures/models/procedure_request.dart';
import 'package:doctor/patient/features/surgical_procedures/models/surgical_procedure.dart';
import 'package:doctor/patient/features/surgical_procedures/repositories/surgical_procedure_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SurgicalProcedureController extends GetxController {
  final SurgicalProcedureRepository _repository = Get.find<SurgicalProcedureRepository>();

  // State
  final isLoading = false.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;
  final isSubmitting = false.obs;

  // Data
  final procedures = <SurgicalProcedure>[].obs;
  final filteredProcedures = <SurgicalProcedure>[].obs;

  // Pagination
  final currentPage = 1.obs;
  final hasMoreData = true.obs;
  final totalCount = 0.obs;

  // Filter
  final selectedCategory = 'All'.obs;
  final List<String> categories = [
    'All',
    'Obstetric',
    'General',
    'Gynecological',
    'Other',
  ];

  // Form
  final procedureNameController = TextEditingController();
  final hospitalNameController = TextEditingController();
  final notesController = TextEditingController();
  final selectedDate = Rx<DateTime?>(null);
  final editingProcedure = Rx<SurgicalProcedure?>(null);

  // Computed getters
  bool get hasProcedures => procedures.isNotEmpty;
  bool get isEmpty => !hasProcedures && !isLoading.value;
  bool get isEditing => editingProcedure.value != null;

  int get totalProcedures => procedures.length;
  int get thisYearCount {
    final currentYear = DateTime.now().year;
    return procedures.where((p) => p.procedureDate.year == currentYear).length;
  }

  String get lastRecordedDate {
    if (procedures.isEmpty) return 'N/A';
    final sorted = List<SurgicalProcedure>.from(procedures)
      ..sort((a, b) => b.procedureDate.compareTo(a.procedureDate));
    return sorted.first.formattedDate;
  }

  @override
  void onInit() {
    super.onInit();
    loadProcedures();
  }

  @override
  void onClose() {
    procedureNameController.dispose();
    hospitalNameController.dispose();
    notesController.dispose();
    super.onClose();
  }

  Future<void> loadProcedures({bool refresh = false}) async {
    if (refresh) {
      currentPage.value = 1;
      hasMoreData.value = true;
      procedures.clear();
    }

    if (!hasMoreData.value) return;

    isLoading.value = procedures.isEmpty;
    hasError.value = false;
    errorMessage.value = '';

    try {
      final result = await _repository.getProcedures(
        page: currentPage.value,
        pageSize: 20,
      );

      if (result != null) {
        procedures.addAll(result.results);
        totalCount.value = result.count;
        hasMoreData.value = result.hasNext;
        currentPage.value++;
        _applyFilter();
        debugPrint(
          '[SURGICAL] Loaded ${procedures.length} of ${result.count} procedures',
        );
      } else {
        hasError.value = true;
        errorMessage.value =
            'Failed to load surgical procedures. Please try again.';
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Something went wrong. Please try again.';
      debugPrint('[SURGICAL] Error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshData() async {
    await loadProcedures(refresh: true);
  }

  Future<void> loadMore() async {
    if (!hasMoreData.value || isLoading.value) return;
    await loadProcedures();
  }

  void _applyFilter() {
    if (selectedCategory.value == 'All') {
      filteredProcedures.value = List.from(procedures);
    } else {
      filteredProcedures.value = procedures
          .where((p) => p.category == selectedCategory.value)
          .toList();
    }
  }

  void setCategory(String category) {
    selectedCategory.value = category;
    _applyFilter();
  }

  int getCategoryCount(String category) {
    if (category == 'All') return procedures.length;
    return procedures.where((p) => p.category == category).length;
  }

  // ==================== CRUD Operations ====================

  Future<void> createProcedure() async {
    if (!_validateForm()) return;

    isSubmitting.value = true;

    try {
      final request = ProcedureRequest(
        procedureName: procedureNameController.text.trim(),
        procedureDate: selectedDate.value!,
        hospitalName: hospitalNameController.text.trim().isEmpty
            ? null
            : hospitalNameController.text.trim(),
        notes: notesController.text.trim().isEmpty
            ? null
            : notesController.text.trim(),
      );

      final result = await _repository.createProcedure(request);

      if (result != null) {
        procedures.insert(0, result);
        _applyFilter();
        _clearForm();
        Get.back();
        _showToast('Procedure added successfully');
        debugPrint('[SURGICAL] Created procedure: ${result.procedureName}');
      } else {
        _showErrorToast('Failed to add procedure. Please try again.');
      }
    } catch (e) {
      _showErrorToast('Something went wrong. Please try again.');
      debugPrint('[SURGICAL] Error creating: $e');
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> updateProcedure() async {
    if (!_validateForm()) return;
    if (editingProcedure.value == null) return;

    isSubmitting.value = true;

    try {
      final request = ProcedureRequest(
        procedureName: procedureNameController.text.trim(),
        procedureDate: selectedDate.value!,
        hospitalName: hospitalNameController.text.trim().isEmpty
            ? null
            : hospitalNameController.text.trim(),
        notes: notesController.text.trim().isEmpty
            ? null
            : notesController.text.trim(),
      );

      final result = await _repository.updateProcedure(
        editingProcedure.value!.id,
        request,
      );

      if (result != null) {
        final index = procedures.indexWhere((p) => p.id == result.id);
        if (index != -1) {
          procedures[index] = result;
        }
        _applyFilter();
        _clearForm();
        Get.back();
        _showToast('Procedure updated successfully');
        debugPrint('[SURGICAL] Updated procedure: ${result.procedureName}');
      } else {
        _showErrorToast('Failed to update procedure. Please try again.');
      }
    } catch (e) {
      _showErrorToast('Something went wrong. Please try again.');
      debugPrint('[SURGICAL] Error updating: $e');
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> deleteProcedure(SurgicalProcedure procedure) async {
    final confirm = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Delete Procedure?'),
        content: Text(
          'Are you sure you want to delete "${procedure.procedureName}" performed on ${procedure.formattedDate}? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final success = await _repository.deleteProcedure(procedure.id);
      if (success) {
        procedures.removeWhere((p) => p.id == procedure.id);
        _applyFilter();
        _showToast('Procedure deleted successfully');
        debugPrint('[SURGICAL] Deleted procedure: ${procedure.procedureName}');
      } else {
        _showErrorToast('Failed to delete procedure. Please try again.');
      }
    } catch (e) {
      _showErrorToast('Something went wrong. Please try again.');
      debugPrint('[SURGICAL] Error deleting: $e');
    }
  }

  // ==================== Form Methods ====================

  bool _validateForm() {
    if (procedureNameController.text.trim().isEmpty) {
      _showErrorToast('Please enter a procedure name');
      return false;
    }
    if (selectedDate.value == null) {
      _showErrorToast('Please select a procedure date');
      return false;
    }
    return true;
  }

  void _clearForm() {
    procedureNameController.clear();
    hospitalNameController.clear();
    notesController.clear();
    selectedDate.value = null;
    editingProcedure.value = null;
  }

  void startEdit(SurgicalProcedure procedure) {
    editingProcedure.value = procedure;
    procedureNameController.text = procedure.procedureName;
    selectedDate.value = procedure.procedureDate;
    hospitalNameController.text = procedure.hospitalName ?? '';
    notesController.text = procedure.notes ?? '';
  }

  // ==================== Navigation ====================

  void navigateBack() {
    Get.back();
  }

  void openAddModal() {
    _clearForm();
    Get.bottomSheet(
      _buildFormSheet(
        title: 'Add Surgical Procedure',
        submitLabel: 'Save Procedure',
        onSubmit: createProcedure,
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  void openEditModal(SurgicalProcedure procedure) {
    startEdit(procedure);
    Get.bottomSheet(
      _buildFormSheet(
        title: 'Edit ${procedure.procedureName}',
        submitLabel: 'Update Procedure',
        onSubmit: updateProcedure,
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  // ==================== UI Builders ====================

  Widget _buildFormSheet({
    required String title,
    required String submitLabel,
    required VoidCallback onSubmit,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Color(0xFFFDF6F0),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          // Title
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF221919),
                  fontFamily: 'PlayfairDisplay',
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => Get.back(),
                style: IconButton.styleFrom(
                  backgroundColor: const Color(0xFFF6E4E4),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Form
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Procedure Name
                  _buildFormField(
                    label: 'Procedure Name',
                    controller: procedureNameController,
                    hint: 'e.g., Laparoscopy, C-Section',
                    icon: Icons.medical_services_rounded,
                  ),
                  const SizedBox(height: 16),
                  // Date
                  _buildDateField(),
                  const SizedBox(height: 16),
                  // Hospital Name
                  _buildFormField(
                    label: 'Hospital / Facility Name',
                    controller: hospitalNameController,
                    hint: 'e.g., St. Jude Medical Center',
                    icon: Icons.local_hospital_rounded,
                  ),
                  const SizedBox(height: 16),
                  // Notes
                  _buildNotesField(),
                  const SizedBox(height: 24),
                  // Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Get.back(),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF221919),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            side: const BorderSide(color: Color(0xFFD8C1C3)),
                          ),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Obx(
                          () => ElevatedButton(
                            onPressed: isSubmitting.value ? null : onSubmit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF934656),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              elevation: 4,
                              disabledBackgroundColor: Colors.grey[300],
                            ),
                            child: isSubmitting.value
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(submitLabel),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
  }) {
    final colorScheme = Get.theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(
              icon,
              size: 20,
              color: colorScheme.onSurfaceVariant,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: colorScheme.outlineVariant.withOpacity(0.5),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: colorScheme.outlineVariant.withOpacity(0.5),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: colorScheme.primary, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateField() {
    final colorScheme = Get.theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Procedure Date',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 6),
        Obx(
          () => InkWell(
            onTap: () => _pickDate(),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                border: Border.all(
                  color: colorScheme.outlineVariant.withOpacity(0.5),
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today_rounded,
                    size: 20,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      selectedDate.value != null
                          ? _formatDate(selectedDate.value!)
                          : 'Select date',
                      style: TextStyle(
                        color: selectedDate.value != null
                            ? colorScheme.onSurface
                            : colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 14,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNotesField() {
    final colorScheme = Get.theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Clinical Notes & Recovery Details',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: notesController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Add any relevant notes...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: colorScheme.outlineVariant.withOpacity(0.5),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: colorScheme.outlineVariant.withOpacity(0.5),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: colorScheme.primary, width: 2),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
      ],
    );
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: Get.context!,
      initialDate: selectedDate.value ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      selectedDate.value = date;
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  void _showToast(String message) {
    Get.snackbar(
      'Success',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
      margin: const EdgeInsets.all(16),
      borderRadius: 30,
    );
  }

  void _showErrorToast(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(16),
      borderRadius: 30,
    );
  }
}

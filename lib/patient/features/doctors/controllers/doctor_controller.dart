// lib/patient/features/doctors/controllers/doctor_controller.dart

import 'package:doctor/core/routes/app_routes.dart';
import 'package:doctor/patient/features/doctors/models/doctor.dart';
import 'package:doctor/patient/features/doctors/models/paginated_doctor_list.dart';
import 'package:doctor/patient/features/doctors/repositories/doctor_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DoctorController extends GetxController {
  final DoctorRepository _repository = Get.find<DoctorRepository>();

  // Data
  final doctors = <Doctor>[].obs;
  final paginatedData = Rx<PaginatedDoctorList?>(null);
  final filteredDoctors = <Doctor>[].obs;

  // Filters
  final selectedSpecialization = 'All Experts'.obs;
  final searchQuery = ''.obs;
  final specializations = <String>['All Experts'].obs;

  // Pagination
  final currentPage = 1.obs;
  final hasMoreData = true.obs;
  final totalCount = 0.obs;
  final isLoading = false.obs;
  final isLoadingMore = false.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;

  // Computed getters
  bool get hasDoctors => doctors.isNotEmpty;
  bool get isEmpty => !hasDoctors && !isLoading.value;

  @override
  void onInit() {
    super.onInit();
    loadDoctors();
  }

  Future<void> loadDoctors({bool refresh = false}) async {
    if (refresh) {
      currentPage.value = 1;
      hasMoreData.value = true;
      doctors.clear();
    }

    if (!hasMoreData.value) return;

    isLoading.value = doctors.isEmpty;
    isLoadingMore.value = doctors.isNotEmpty;
    hasError.value = false;
    errorMessage.value = '';

    try {
      final result = await _repository.getDoctors(
        page: currentPage.value,
        pageSize: 20,
      );

      if (result != null) {
        doctors.addAll(result.results);
        paginatedData.value = result;
        hasMoreData.value = result.hasNext;
        totalCount.value = result.count;
        currentPage.value++;

        debugPrint(
          '[DOCTOR] Loaded ${doctors.length} of ${result.count} doctors',
        );
        _applyFilters();
        _loadSpecializationsFromDoctors();
      } else {
        hasError.value = true;
        errorMessage.value = 'Failed to load doctors. Please try again.';
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Something went wrong. Please try again.';
      debugPrint('[DOCTOR] Error: $e');
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  Future<void> refreshData() async {
    await loadDoctors(refresh: true);
  }

  Future<void> loadMore() async {
    if (!hasMoreData.value || isLoadingMore.value) return;
    await loadDoctors();
  }

  void _applyFilters() {
    var filtered = List<Doctor>.from(doctors);

    // Apply specialization filter
    if (selectedSpecialization.value != 'All Experts') {
      filtered = filtered.where((doctor) {
        final spec = doctor.doctorProfile?.specialization ?? '';
        return spec.toLowerCase().contains(
          selectedSpecialization.value.toLowerCase().replaceAll(' Expert', ''),
        );
      }).toList();
    }

    // Apply search query
    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      filtered = filtered.where((doctor) {
        final name = doctor.fullName.toLowerCase();
        final spec = doctor.doctorProfile?.specialization?.toLowerCase() ?? '';
        return name.contains(query) || spec.contains(query);
      }).toList();
    }

    filteredDoctors.value = filtered;
  }

  void setSpecialization(String specialization) {
    selectedSpecialization.value = specialization;
    _applyFilters();
  }

  void _loadSpecializationsFromDoctors() {
    final uniqueSpecs = <String>{};
    final displaySpecs = <String, String>{};

    for (final doctor in doctors) {
      final spec = doctor.doctorProfile?.specialization;
      if (spec != null && spec.isNotEmpty) {
        final normalized = spec.trim().toLowerCase();
        if (!uniqueSpecs.contains(normalized)) {
          uniqueSpecs.add(normalized);
          displaySpecs[normalized] = spec.trim();
        }
      }
    }

    final sortedDisplaySpecs = displaySpecs.values.toList()..sort();
    specializations.value = ['All Experts', ...sortedDisplaySpecs];
  }

  void setSearchQuery(String query) {
    searchQuery.value = query;
    _applyFilters();
  }

  void clearSearch() {
    searchQuery.value = '';
    _applyFilters();
  }

  // Navigation methods
  void navigateToDoctorDetail(int doctorId) {
    Get.toNamed(AppRoutes.doctorDetail, arguments: {'doctorId': doctorId});
  }

  void navigateToBookAppointment(int doctorId) {
    Get.toNamed(AppRoutes.bookAppointment, arguments: {'doctorId': doctorId});
  }

  void navigateToHome() {
    Get.offAllNamed(AppRoutes.patientDashboard);
  }

  void navigateToNotifications() {
    Get.toNamed(AppRoutes.docnotifications);
  }

  void navigateToReports() {
    Get.toNamed('/reports');
  }

  void navigateToHistory() {
    Get.toNamed(AppRoutes.patientKickCountHistory);
  }

  void navigateToProfile() {
    Get.toNamed(AppRoutes.docprofile);
  }
}

// lib/features/emergency/controllers/sos_controller.dart
 
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:doctor/core/constants/color_constants.dart';
import 'package:doctor/core/routes/app_routes.dart';
import 'package:doctor/features/emergency/models/sos_event.dart';
import 'package:doctor/features/emergency/repositories/sos_repository.dart';
 
class SosController extends GetxController {
  final SosRepository _repository = SosRepository();

  // State
  final events = <SosEvent>[].obs;
  final filteredEvents = <SosEvent>[].obs;
  final isLoading = true.obs;
  final isResolving = false.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;

  // Filter
  final selectedFilter = SosFilter.active.obs;

  // Pagination
  int _currentPage = 1;
  bool _hasMoreData = true;
  static const int _pageSize = 20;

  // Computed
  int get activeCount => events.where((e) => e.isActive).length;

  String get filterBadge {
    if (selectedFilter.value == SosFilter.active && activeCount > 0) {
      return activeCount.toString();
    }
    return '';
  }

  @override
  void onInit() {
    super.onInit();
    _loadSosEvents();
  }

  Future<void> _loadSosEvents({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _hasMoreData = true;
      events.clear();
    }

    if (!_hasMoreData) return;

    isLoading.value = true;
    hasError.value = false;
    errorMessage.value = '';

    try {
      String? statusFilter;
      if (selectedFilter.value == SosFilter.active) {
        statusFilter = 'active';
      }

      final result = await _repository.getSosEvents(
        status: statusFilter,
        page: _currentPage,
        pageSize: _pageSize,
      );

      if (refresh) {
        events.value = result;
      } else {
        events.addAll(result);
      }

      _hasMoreData = result.length == _pageSize;
      _currentPage++;

      _applyFilter();

      debugPrint('[SOS] Loaded ${events.length} events');
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Failed to load SOS events. Please try again.';
      debugPrint('[SOS] Error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void _applyFilter() {
    switch (selectedFilter.value) {
      case SosFilter.active:
        filteredEvents.value = events.where((e) => e.isActive).toList();
        break;
      case SosFilter.all:
        filteredEvents.value = List.from(events);
        break;
      case SosFilter.resolved:
        filteredEvents.value = events.where((e) => !e.isActive).toList();
        break;
    }
  }

  void setFilter(SosFilter filter) {
    selectedFilter.value = filter;
    _applyFilter();
  }

  Future<void> refreshSosEvents() async {
    await _loadSosEvents(refresh: true);
  }

  Future<void> loadMore() async {
    if (!isLoading.value && _hasMoreData) {
      await _loadSosEvents();
    }
  }

  Future<void> resolveEvent({
    required SosEvent event,
    required String status,
  }) async {
    isResolving.value = true;

    try {
      final updated = await _repository.resolveSosEvent(
        id: event.id,
        status: status,
      );

      if (updated != null) {
        // Update the event in the list
        final index = events.indexWhere((e) => e.id == event.id);
        if (index != -1) {
          events[index] = updated;
          events.refresh();
          _applyFilter();
        }

        final isResolved = status == 'resolved';
        Get.snackbar(
          'Success',
          isResolved
              ? 'SOS alert marked as resolved'
              : 'SOS alert marked as false alarm',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: isResolved
              ? Colors.green.withOpacity(0.1)
              : Colors.orange.withOpacity(0.1),
          colorText: isResolved ? Colors.green[800] : Colors.orange[800],
        );
      } else {
        throw Exception('Failed to update SOS event');
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red[800],
      );
    } finally {
      isResolving.value = false;
    }
  }

  void navigateToDetail(SosEvent event) {
    Get.toNamed(AppRoutes.sosDetail, arguments: {'eventId': event.id})?.then((_) {
      // Refresh list when returning from detail
      refreshSosEvents();
    });
  }
}

enum SosFilter { active, all, resolved }

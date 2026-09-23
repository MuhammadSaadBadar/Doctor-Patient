import 'package:doctor/core/localization/translation_keys.dart';
import 'package:doctor/patient/features/emergency/models/nearby_hospital.dart';
import 'package:doctor/patient/features/emergency/models/patient_sos_event.dart';
import 'package:doctor/patient/features/emergency/repositories/emergency_repository.dart';
import 'package:doctor/patient/features/emergency/services/location_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

class EmergencyController extends GetxController {
  final EmergencyRepository _repository = Get.find<EmergencyRepository>();
  final LocationService _locationService = LocationService();

  final selectedSection = 0.obs;
  final sosEvents = <PatientSosEvent>[].obs;
  final hospitals = <NearbyHospital>[].obs;
  final isLoadingSos = true.obs;
  final isLoadingHospitals = false.obs;
  final hasSosError = false.obs;
  final hasHospitalError = false.obs;
  final sosError = ''.obs;
  final hospitalError = ''.obs;
  final isResolving = false.obs;
  final hasMoreSos = true.obs;
  final hasMoreHospitals = false.obs;
  final latitude = Rxn<double>();
  final longitude = Rxn<double>();

  int _sosPage = 1;

  @override
  void onInit() {
    super.onInit();
    loadSos(refresh: true);
    loadHospitals(); // Pre-fetch at launch so data is ready when tab is opened
  }

  Future<void> loadSos({bool refresh = false}) async {
    if (refresh) {
      _sosPage = 1;
      hasMoreSos.value = true;
      sosEvents.clear();
    }
    if (!hasMoreSos.value) return;
    isLoadingSos.value = true;
    hasSosError.value = false;
    try {
      final result = await _repository.getSosEvents(page: _sosPage);
      sosEvents.addAll(result.events);
      hasMoreSos.value = result.hasNext;
      _sosPage++;
    } catch (e) {
      hasSosError.value = true;
      sosError.value = TranslationKeys.sosLoadError.tr;
      debugPrint('[EMERGENCY] SOS error: $e');
    } finally {
      isLoadingSos.value = false;
    }
  }

  Future<void> loadHospitals({bool refresh = true}) async {
    if (isLoadingHospitals.value) return;
    isLoadingHospitals.value = true;
    hasHospitalError.value = false;
    if (refresh) hospitals.clear();

    try {
      final position = await _locationService.getCurrentPosition();
      if (position == null) {
        throw Exception('Location permission or GPS is unavailable.');
      }
      latitude.value = position.latitude;
      longitude.value = position.longitude;

      final userLatLng = LatLng(position.latitude, position.longitude);
      const distanceCalc = Distance();

      // Fetch from OSM Overpass (with automatic mirror fallback)
      final result = await _repository.getNearbyHospitals(
        latitude: position.latitude,
        longitude: position.longitude,
      );

      final all = result.hospitals;

      if (all.isEmpty) {
        // Mirrors were all unreachable — show friendly message, not error
        hasHospitalError.value = true;
        hospitalError.value = 'Hospital data is temporarily unavailable. Please try again later.';
        return;
      }

      // Compute distance for each hospital
      for (final h in all) {
        if (h.latitude != null && h.longitude != null) {
          h.distanceMeters = distanceCalc.as(
            LengthUnit.Meter,
            userLatLng,
            LatLng(h.latitude!, h.longitude!),
          );
        }
      }

      // Sort by distance (closest first)
      all.sort((a, b) {
        final da = a.distanceMeters ?? double.infinity;
        final db = b.distanceMeters ?? double.infinity;
        return da.compareTo(db);
      });

      hospitals.assignAll(all);
      hasMoreHospitals.value = false;
    } catch (e) {
      hasHospitalError.value = true;
      hospitalError.value = e.toString().replaceFirst('Exception: ', '');
      debugPrint('[EMERGENCY] Hospital error: $e');
    } finally {
      isLoadingHospitals.value = false;
    }
  }

  Future<void> resolveSos(PatientSosEvent event, String status) async {
    if (isResolving.value) return;
    isResolving.value = true;
    try {
      final updated = await _repository.resolveSos(
        id: event.id,
        status: status,
      );
      if (updated != null) {
        final index = sosEvents.indexWhere((item) => item.id == event.id);
        if (index != -1) {
          sosEvents[index] = updated;
          sosEvents.refresh();
        }
      } else {
        throw Exception(TranslationKeys.sosUpdateRejected.tr);
      }
    } catch (e) {
      Get.snackbar('Error', e.toString().replaceFirst('Exception: ', ''));
    } finally {
      isResolving.value = false;
    }
  }

  List<PatientSosEvent> get activeEvents =>
      sosEvents.where((event) => event.isActive).toList();

  List<PatientSosEvent> get previousEvents =>
      sosEvents.where((event) => !event.isActive).toList();
}

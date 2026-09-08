// lib/patient/features/surgical_procedures/repositories/surgical_procedure_repository.dart

import 'package:dio/dio.dart';
import 'package:doctor/core/constants/api_constants.dart';
import 'package:doctor/core/network/api_client.dart';
import 'package:doctor/core/network/api_error_mapper.dart';
import 'package:doctor/patient/features/surgical_procedures/models/paginated_procedure_list.dart';
import 'package:doctor/patient/features/surgical_procedures/models/procedure_request.dart';
import 'package:doctor/patient/features/surgical_procedures/models/surgical_procedure.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SurgicalProcedureRepository {
  final ApiClient _apiClient = Get.find<ApiClient>();

  /// Get all surgical procedures for the patient
  Future<PaginatedProcedureList?> getProcedures({
    int page = 1,
    int pageSize = 20,
    int? patientId,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {
        'page': page,
        'page_size': pageSize,
      };
      if (patientId != null) {
        queryParams['patient_id'] = patientId;
      }

      final response = await _apiClient.get(
        ApiConstants.healthSurgicalProcedures,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        return PaginatedProcedureList.fromJson(
          response.data as Map<String, dynamic>,
        );
      }

      return null;
    } on DioException catch (e) {
      final apiException = ApiErrorMapper.mapDioException(
        e,
        defaultMessage: 'Failed to load surgical procedures.',
      );
      debugPrint('[SURGICAL_REPO] Error: ${apiException.message}');
      return null;
    } catch (e) {
      debugPrint('[SURGICAL_REPO] Unexpected error: $e');
      return null;
    }
  }

  /// Get a single procedure by ID
  Future<SurgicalProcedure?> getProcedureById(int id) async {
    try {
      final response = await _apiClient.get(
        '${ApiConstants.healthSurgicalProcedures}$id/',
      );

      if (response.statusCode == 200) {
        return SurgicalProcedure.fromJson(
          response.data as Map<String, dynamic>,
        );
      }

      return null;
    } on DioException catch (e) {
      final apiException = ApiErrorMapper.mapDioException(
        e,
        defaultMessage: 'Failed to get procedure details.',
      );
      debugPrint(
        '[SURGICAL_REPO] Error getting procedure: ${apiException.message}',
      );
      return null;
    } catch (e) {
      debugPrint('[SURGICAL_REPO] Unexpected error: $e');
      return null;
    }
  }

  /// Create a new surgical procedure
  Future<SurgicalProcedure?> createProcedure(ProcedureRequest request) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.healthSurgicalProcedures,
        data: request.toJson(),
      );

      if (response.statusCode == 201) {
        return SurgicalProcedure.fromJson(
          response.data as Map<String, dynamic>,
        );
      }

      return null;
    } on DioException catch (e) {
      final apiException = ApiErrorMapper.mapDioException(
        e,
        defaultMessage: 'Failed to create procedure.',
      );
      debugPrint('[SURGICAL_REPO] Error creating: ${apiException.message}');
      return null;
    } catch (e) {
      debugPrint('[SURGICAL_REPO] Unexpected error: $e');
      return null;
    }
  }

  /// Update an existing surgical procedure
  Future<SurgicalProcedure?> updateProcedure(
    int id,
    ProcedureRequest request,
  ) async {
    try {
      final response = await _apiClient.put(
        '${ApiConstants.healthSurgicalProcedures}$id/',
        data: request.toJson(),
      );

      if (response.statusCode == 200) {
        return SurgicalProcedure.fromJson(
          response.data as Map<String, dynamic>,
        );
      }

      return null;
    } on DioException catch (e) {
      final apiException = ApiErrorMapper.mapDioException(
        e,
        defaultMessage: 'Failed to update procedure.',
      );
      debugPrint('[SURGICAL_REPO] Error updating: ${apiException.message}');
      return null;
    } catch (e) {
      debugPrint('[SURGICAL_REPO] Unexpected error: $e');
      return null;
    }
  }

  /// Delete a surgical procedure
  Future<bool> deleteProcedure(int id) async {
    try {
      final response = await _apiClient.delete(
        '${ApiConstants.healthSurgicalProcedures}$id/',
      );

      if (response.statusCode == 204) {
        debugPrint('[SURGICAL_REPO] Deleted procedure $id');
        return true;
      }

      return false;
    } on DioException catch (e) {
      final apiException = ApiErrorMapper.mapDioException(
        e,
        defaultMessage: 'Failed to delete procedure.',
      );
      debugPrint('[SURGICAL_REPO] Error deleting: ${apiException.message}');
      return false;
    } catch (e) {
      debugPrint('[SURGICAL_REPO] Unexpected error: $e');
      return false;
    }
  }
}

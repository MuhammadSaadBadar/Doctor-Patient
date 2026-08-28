// lib/features/profile/repositories/add_payment_method_repository.dart

import 'package:dio/dio.dart';
import 'package:doctor/core/constants/api_constants.dart';
import 'package:doctor/core/network/api_client.dart';
import 'package:doctor/core/network/api_error_mapper.dart';
import 'package:doctor/features/profile/models/add_payment_method.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddPaymentMethodRepository {
  final ApiClient _apiClient = Get.find<ApiClient>();

  /// Update payment method
  Future<bool> updatePaymentMethod(AddPaymentMethodRequest request) async {
    try {
      final response = await _apiClient.patch(
        ApiConstants.accountsMeDoctorProfile,
        data: request.toJson(),
      );

      debugPrint(
        '[ADD_PAYMENT_METHOD] Update response: ${response.statusCode}',
      );
      debugPrint('[ADD_PAYMENT_METHOD] Update body: ${request.toJson()}');

      if (response.statusCode == 200) {
        return true;
      }

      return false;
    } on DioException catch (e) {
      final apiException = ApiErrorMapper.mapDioException(
        e,
        defaultMessage: 'Failed to update payment method.',
      );
      debugPrint(
        '[ADD_PAYMENT_METHOD] Error updating: ${apiException.message}',
      );
      throw apiException;
    } catch (e) {
      debugPrint('[ADD_PAYMENT_METHOD] Unexpected error: $e');
      throw Exception('Failed to update payment method. Please try again.');
    }
  }
}

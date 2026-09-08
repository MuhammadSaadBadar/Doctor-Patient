// lib/patient/features/exercise_videos/repositories/exercise_video_repository.dart

import 'package:dio/dio.dart';
import 'package:doctor/core/constants/api_constants.dart';
import 'package:doctor/core/network/api_client.dart';
import 'package:doctor/core/network/api_error_mapper.dart';
import 'package:doctor/core/network/api_exceptions.dart';
import 'package:doctor/patient/features/exercise_videos/models/paginated_video_list.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

class ExerciseVideoRepository {
  ExerciseVideoRepository({ApiClient? apiClient})
      : _apiClient = apiClient ?? Get.find<ApiClient>();

  final ApiClient _apiClient;

  /// Get paginated exercise videos.
  /// Throws [ApiException] on failure so the controller can surface
  /// a real message instead of swallowing it.
  Future<PaginatedVideoList> getVideos({
    int page = 1,
    int pageSize = 50,
  }) async {
    try {
      final response = await _apiClient.get(
        ApiConstants.healthExerciseVideos,
        queryParameters: {'page': page, 'page_size': pageSize},
      );
      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
        return PaginatedVideoList.fromJson(response.data as Map<String, dynamic>);
      }
      throw ApiException(
        'Unexpected response (${response.statusCode}).',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      debugPrint('[EXERCISE_REPO] Error: $e');
      throw ApiErrorMapper.mapDioException(
        e,
        defaultMessage: 'Failed to load exercise videos.',
      );
    }
  }
}

import 'package:dio/dio.dart';

import 'api_exceptions.dart';

/// Shared helper that converts a [DioException] into an [ApiException].
///
/// Extracts DRF-style structured field errors (`{"detail": ..., "errors":
/// {"field": ["msg", ...]}}`) into the [ApiException.fieldErrors] map so
/// screens/controllers can surface backend validation messages inline.
class ApiErrorMapper {
  ApiErrorMapper._();

  static ApiException mapDioException(
    DioException e, {
    required String defaultMessage,
  }) {
    final statusCode = e.response?.statusCode;
    final serverMessage = _extractServerMessage(e.response?.data);
    final fieldErrors = _extractFieldErrors(e.response?.data);

    // A transport exception can still carry a server response. In that case
    // preserve the HTTP status and response body instead of masking it as a
    // generic network failure.
    if (e.response == null &&
        (e.type == DioExceptionType.connectionError ||
            e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.receiveTimeout ||
            e.type == DioExceptionType.sendTimeout)) {
      return NetworkException();
    }

    // Prefer any server-supplied message before falling back to the fixed
    // subclass messages (UnauthorizedException / NotFoundException /
    // ServerException all hard-code generic strings that hide useful backend
    // context like "Email not found" or "Invalid OTP").
    if (statusCode == 401) {
      return serverMessage != null
          ? ApiException(
              serverMessage,
              statusCode: 401,
              fieldErrors: fieldErrors,
            )
          : UnauthorizedException();
    }
    if (statusCode == 404) {
      return serverMessage != null
          ? ApiException(
              serverMessage,
              statusCode: 404,
              fieldErrors: fieldErrors,
            )
          : NotFoundException();
    }
    if (statusCode != null && statusCode >= 500) {
      return serverMessage != null
          ? ApiException(
              serverMessage,
              statusCode: statusCode,
              fieldErrors: fieldErrors,
            )
          : ServerException();
    }

    return ApiException(
      serverMessage ?? defaultMessage,
      statusCode: statusCode,
      fieldErrors: fieldErrors,
    );
  }

  static String? _extractServerMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      final detail = data['detail'];
      if (detail is String && detail.isNotEmpty) return detail;
      final message = data['message'];
      if (message is String && message.isNotEmpty) return message;
      // Flatten first field-error list as a fallback message when there is no
      // top-level detail/message but structured validation errors exist.
      final errors = data['errors'];
      if (errors is Map && errors.isNotEmpty) {
        final firstKey = errors.keys.first;
        final firstVal = errors[firstKey];
        if (firstVal is List && firstVal.isNotEmpty)
          return firstVal.first.toString();
        return firstVal.toString();
      }
    }
    return null;
  }

  static Map<String, List<String>>? _extractFieldErrors(dynamic data) {
    if (data is! Map<String, dynamic>) return null;
    final rawErrors = data['errors'];
    if (rawErrors is! Map) return null;

    final Map<String, List<String>> result = {};
    rawErrors.forEach((key, value) {
      if (value is List) {
        result[key.toString()] = value.map((e) => e.toString()).toList();
      } else {
        result[key.toString()] = <String>[value.toString()];
      }
    });
    return result.isEmpty ? null : result;
  }
}

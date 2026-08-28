// lib/core/utils/validation_utils.dart

import 'package:get/get.dart';

/// Maps backend field errors (snake_case) to local RxString error observables.
///
/// [fieldErrors] - The fieldErrors map from ApiException
/// [errorMap] - Map of backend field name (snake_case) to local RxString error variable
/// [fallbackSnackbar] - Optional callback for fields not in errorMap
void handleApiFieldErrors(
  Map<String, List<String>>? fieldErrors,
  Map<String, RxString> errorMap, {
  void Function(String field, String message)? fallbackSnackbar,
}) {
  if (fieldErrors == null) return;

  // Clear all local errors first
  for (final error in errorMap.values) {
    error.value = '';
  }

  // Apply backend errors
  fieldErrors.forEach((field, messages) {
    final errorVar = errorMap[field];
    if (errorVar != null && messages.isNotEmpty) {
      errorVar.value = messages.first;
    } else if (fallbackSnackbar != null && messages.isNotEmpty) {
      fallbackSnackbar(field, messages.first);
    }
  });
}
import 'package:dio/dio.dart';
import 'package:doctor/core/constants/api_constants.dart';
import 'package:doctor/core/constants/user_role.dart';
import 'package:doctor/core/network/api_client.dart';
import 'package:doctor/core/network/api_error_mapper.dart';
import 'package:doctor/core/network/api_exceptions.dart';
import 'package:doctor/core/services/storage_service.dart';
import 'package:doctor/doctor/features/auth/controllers/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Response;

class LoginResult {
  final bool success;
  final UserRole? role;
  final String? errorMessage;

  const LoginResult({required this.success, this.role, this.errorMessage});

  factory LoginResult.success(UserRole role) =>
      LoginResult(success: true, role: role);

  factory LoginResult.failure(String errorMessage) =>
      LoginResult(success: false, errorMessage: errorMessage);
}

class AuthRepository {
  static const _emailOperationTimeout = Duration(seconds: 180);

  final ApiClient _apiClient;
  final StorageService _storage;
  String? _resetToken;

  AuthRepository({ApiClient? apiClient, StorageService? storage})
    : _apiClient = apiClient ?? Get.find<ApiClient>(),
      _storage = storage ?? Get.find<StorageService>();

  // ==================== LOGIN ====================
  Future<LoginResult> login(
    String email,
    String password, {
    UserRole? preferredRole,
  }) async {
    try {
      debugPrint('[AUTH] Login attempt for email: $email');

      // Retry once on connection/timeout (Render free tier cold start: 20-50s)
      Response response;
      try {
        response = await _apiClient.post(
          ApiConstants.authLogin,
          data: {
            'email': email,
            'password': password,
            if (preferredRole != null) 'role': preferredRole.name,
          },
        );
      } on DioException catch (e) {
        if (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.receiveTimeout ||
            e.type == DioExceptionType.connectionError) {
          debugPrint(
            '[AUTH] First attempt timed out (Render cold start?), retrying once...',
          );
          response = await _apiClient.post(
            ApiConstants.authLogin,
            data: {
              'email': email,
              'password': password,
              if (preferredRole != null) 'role': preferredRole.name,
            },
          );
        } else {
          rethrow;
        }
      }

      debugPrint('[AUTH] Login response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final accessToken = data['access'] as String?;
        final refreshToken = data['refresh'] as String?;
        final roleString = data['role'] as String?;
        final userId = data['user_id']?.toString() ?? data['id']?.toString();

        if (accessToken != null && accessToken.isNotEmpty) {
          await _storage.setAccessToken(accessToken);
          if (refreshToken != null && refreshToken.isNotEmpty) {
            await _storage.setRefreshToken(refreshToken);
          }

          // Parse and store user role from backend
          UserRole? userRole;
          if (roleString != null) {
            final normalizedRole = roleString.toLowerCase();
            if (normalizedRole == 'doctor') {
              userRole = UserRole.doctor;
            } else if (normalizedRole == 'patient') {
              userRole = UserRole.patient;
            }
            // Unknown roles are intentionally left null so the fallback
            // below can try the user object, and if that also fails we
            // return an explicit error rather than silently defaulting
            // to patient.
            debugPrint(
              '[AUTH] Parsed role from top-level: $roleString -> $userRole',
            );
            if (userRole != null) {
              await _storage.setUserRole(normalizedRole);
            }
          }

          // Store user info if available
          if (userId != null) {
            await _storage.setUserId(userId);
          }
          final user = data['user'] as Map<String, dynamic>?;
          if (user != null) {
            final firstName = user['first_name'] as String?;
            if (firstName != null) {
              await _storage.setUserFirstName(firstName);
            }
            final lastName = user['last_name'] as String?;
            if (lastName != null) {
              await _storage.setUserLastName(lastName);
            }
            // Fallback to user object for role if not at top level
            if (userRole == null) {
              final userRoleString = user['role'] as String?;
              if (userRoleString != null) {
                final normalizedUserRole = userRoleString.toLowerCase();
                if (normalizedUserRole == 'doctor') {
                  userRole = UserRole.doctor;
                } else if (normalizedUserRole == 'patient') {
                  userRole = UserRole.patient;
                }
                debugPrint(
                  '[AUTH] Parsed role from user object: $userRoleString -> $userRole',
                );
                if (userRole != null) {
                  await _storage.setUserRole(normalizedUserRole);
                }
              }
            }
          }

          await _storage.setLoggedIn(true);
          Get.find<AuthController>().isLoggedIn.value = true;
          debugPrint(
            '[AUTH] Login successful - tokens stored, role: $userRole',
          );

          if (userRole == null) {
            debugPrint(
              '[AUTH] ERROR: Could not determine user role from login response',
            );
            return LoginResult.failure(
              'Unable to determine user role. Please contact support.',
            );
          }

          return LoginResult.success(userRole);
        } else {
          debugPrint('[AUTH] Login response missing tokens');
          return LoginResult.failure('Login response missing tokens');
        }
      }

      debugPrint('[AUTH] Login failed with status: ${response.statusCode}');
      // Try to extract error message from response
      String errorMessage = 'Login failed. Please try again.';
      if (response.data is Map<String, dynamic>) {
        final detail = response.data['detail'] as String?;
        if (detail != null && detail.isNotEmpty) {
          errorMessage = detail;
        }
      }
      return LoginResult.failure(errorMessage);
    } on DioException catch (e) {
      // Detailed error logging
      debugPrint('[AUTH] DioException type: ${e.type}');
      debugPrint('[AUTH] DioException status: ${e.response?.statusCode}');
      debugPrint('[AUTH] DioException message: ${e.message}');
      debugPrint('[AUTH] DioException response: ${e.response?.data}');

      // Check if it's a connection error
      if (e.response == null &&
          (e.type == DioExceptionType.connectionError ||
              e.type == DioExceptionType.connectionTimeout ||
              e.type == DioExceptionType.receiveTimeout ||
              e.type == DioExceptionType.sendTimeout)) {
        // Network error - show specific message
        return LoginResult.failure(
          'Unable to connect to the server. Please check your internet connection.',
        );
      } else {
        // Other Dio errors - extract server message
        if (e.response?.data != null) {
          final data = e.response?.data as Map<String, dynamic>?;
          final detail = data?['detail'] as String?;
          if (detail != null && detail.isNotEmpty) {
            return LoginResult.failure(detail);
          }
        }
        final apiException = ApiErrorMapper.mapDioException(
          e,
          defaultMessage: 'Login failed. Please try again.',
        );
        debugPrint('[AUTH] Login error: ${apiException.message}');
        return LoginResult.failure(apiException.message);
      }
    } catch (e) {
      debugPrint('[AUTH] Login unexpected error: $e');
      return LoginResult.failure(
        'An unexpected error occurred. Please try again.',
      );
    }
  }

  // ==================== TOKEN REFRESH ====================
  Future<bool> tokenRefresh() async {
    try {
      final response = await _apiClient.post(
        ApiConstants.authTokenRefresh,
        data: {},
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final accessToken = data['access'] as String?;
        final refreshToken = data['refresh'] as String?;

        if (accessToken != null) {
          await _storage.setAccessToken(accessToken!);
          if (refreshToken != null) {
            await _storage.setRefreshToken(refreshToken!);
          }
          Get.find<AuthController>().isLoggedIn.value = true;
          debugPrint('[AUTH] Token refreshed successfully');
          return true;
        }
      }

      debugPrint('[AUTH] Token refresh failed');
      return false;
    } on DioException catch (e) {
      final apiException = ApiErrorMapper.mapDioException(
        e,
        defaultMessage: 'Token refresh failed.',
      );
      debugPrint('[AUTH] Token refresh error: ${apiException.message}');
      return false;
    } catch (e) {
      debugPrint('[AUTH] Token refresh error: $e');
      return false;
    }
  }

  // ==================== LOGOUT ====================
  Future<void> logout() async {
    try {
      await _apiClient.post(ApiConstants.authLogout);
    } catch (_) {
      // Ignore errors during logout - still clear local state
    } finally {
      await _storage.clearAuth();
      Get.find<AuthController>().isLoggedIn.value = false;
      if (Get.currentRoute != '/login' && Get.currentRoute != '/splash') {
        Get.offAllNamed('/login');
      }
      debugPrint('[AUTH] Logout successful - session cleared');
    }
  }

  // ==================== USER PROFILE ====================

  /// Fetches /api/v1/auth/me/, persists user_id AND user_role from the
  /// response, then returns the authoritative role string (e.g. 'patient',
  /// 'doctor') so callers can route correctly without relying on stale
  /// SharedPreferences data from login time.
  ///
  /// Returns null when the network call fails so the caller can distinguish
  /// "verified role" from "could not verify" and act safely (e.g. keep last
  /// known role instead of falling back to a hard-coded default).
  Future<String?> getUserProfile() async {
    try {
      final response = await _apiClient.get(ApiConstants.authMe);

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;

        // Persist user id
        final userId = data['id'] as String?;
        if (userId != null) {
          await _storage.setUserId(userId);
        }

        // Persist the authoritative role from this response
        final roleRaw = data['role'] as String?;
        if (roleRaw != null && roleRaw.isNotEmpty) {
          final normalizedRole = roleRaw.toLowerCase();
          await _storage.setUserRole(normalizedRole);
          debugPrint('[AUTH] Role refreshed from /me: $normalizedRole');
          return normalizedRole;
        }

        // Role field absent — return the locally-stored value as fallback
        debugPrint('[AUTH] /me response had no role field; using stored role.');
        return _storage.userRole;
      }

      return null;
    } on DioException catch (e) {
      final apiException = ApiErrorMapper.mapDioException(
        e,
        defaultMessage: 'Failed to get user profile.',
      );
      debugPrint('[AUTH] Get user profile error: ${apiException.message}');
      return null;
    } catch (e) {
      debugPrint('[AUTH] Get user profile error: $e');
      return null;
    }
  }

  // ==================== FORGOT PASSWORD (Step 1) ====================
  /// Returns null on success, or an error message string to display.
  Future<String?> resetPassword(String email) async {
    try {
      final response = await _apiClient.postJson(
        ApiConstants.authPasswordForgot,
        data: {'email': email},
        connectTimeout: _emailOperationTimeout,
        receiveTimeout: _emailOperationTimeout,
      );
      if (response.statusCode == 200) return null;
      // Non-200 success or unexpected status.
      final serverMessage = _extractServerMessage(response.data);
      return serverMessage ?? 'Failed to send reset instructions.';
    } on DioException catch (e) {
      final apiException = ApiErrorMapper.mapDioException(
        e,
        defaultMessage: 'Failed to send reset instructions.',
      );
      debugPrint('[AUTH] Password reset error: ${apiException.message}');
      if (apiException is NetworkException) throw apiException;
      return apiException.message;
    } catch (e) {
      debugPrint('[AUTH] Password reset error: $e');
      return 'An unexpected error occurred. Please try again.';
    }
  }

  // ==================== OTP VERIFICATION FOR RESET (Step 2) ====================
  /// Returns null on success (reset token stored internally), or an error message.
  Future<String?> verifyOtpForReset(String email, String otp) async {
    try {
      final response = await _apiClient.postJson(
        ApiConstants.authPasswordVerifyOtp,
        data: {'email': email, 'otp_code': otp},
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final resetToken = data['reset_token'] as String?;
        if (resetToken != null) {
          _resetToken = resetToken;
          Get.find<AuthController>().resetToken.value = resetToken;
        }
        return null; // success
      }

      final serverMessage = _extractServerMessage(response.data);
      return serverMessage ?? 'OTP verification failed.';
    } on DioException catch (e) {
      final apiException = ApiErrorMapper.mapDioException(
        e,
        defaultMessage: 'OTP verification failed.',
      );
      debugPrint('[AUTH] OTP verification error: ${apiException.message}');
      return apiException.message;
    } catch (e) {
      debugPrint('[AUTH] OTP verification error: $e');
      return 'An unexpected error occurred. Please try again.';
    }
  }

  // Helper to expose reset token to controller
  String? get getResetToken => _resetToken;

  // ==================== RESEND RESET OTP ====================
  /// Returns null on success, or an error message string.
  Future<String?> resendResetOtp(String email) async {
    try {
      final response = await _apiClient.postJson(
        ApiConstants.authPasswordForgot,
        data: {'email': email},
      );
      if (response.statusCode == 200) return null;
      final serverMessage = _extractServerMessage(response.data);
      return serverMessage ?? 'Failed to resend OTP.';
    } on DioException catch (e) {
      final apiException = ApiErrorMapper.mapDioException(
        e,
        defaultMessage: 'Failed to resend OTP.',
      );
      debugPrint('[AUTH] Resend reset OTP error: ${apiException.message}');
      return apiException.message;
    } catch (e) {
      debugPrint('[AUTH] Resend reset OTP error: $e');
      return 'An unexpected error occurred. Please try again.';
    }
  }

  // ==================== RESET PASSWORD WITH TOKEN (Step 3) ====================
  /// Returns null on success, or an error message string.
  Future<String?> resetPasswordWithToken(
    String token,
    String newPassword,
  ) async {
    try {
      final response = await _apiClient.postJson(
        ApiConstants.authPasswordReset,
        data: {'token': token, 'new_password': newPassword},
      );

      if (response.statusCode == 200) {
        Get.find<AuthController>().resetToken.value = '';
        debugPrint('[AUTH] Password reset with token successful');
        return null; // success
      }

      final serverMessage = _extractServerMessage(response.data);
      return serverMessage ?? 'Failed to reset password.';
    } on DioException catch (e) {
      final apiException = ApiErrorMapper.mapDioException(
        e,
        defaultMessage: 'Failed to reset password.',
      );
      debugPrint(
        '[AUTH] Password reset with token error: ${apiException.message}',
      );
      return apiException.message;
    } catch (e) {
      debugPrint('[AUTH] Password reset with token error: $e');
      return 'An unexpected error occurred. Please try again.';
    }
  }

  // ==================== CHANGE PASSWORD (Authenticated) ====================
  /// Returns null on success, or an error message string.
  Future<String?> changePassword(String oldPassword, String newPassword) async {
    try {
      final response = await _apiClient.postJson(
        ApiConstants.authPasswordChange,
        data: {'old_password': oldPassword, 'new_password': newPassword},
      );

      if (response.statusCode == 200) return null;
      final serverMessage = _extractServerMessage(response.data);
      return serverMessage ?? 'Failed to change password.';
    } on DioException catch (e) {
      final apiException = ApiErrorMapper.mapDioException(
        e,
        defaultMessage: 'Failed to change password.',
      );
      debugPrint('[AUTH] Change password error: ${apiException.message}');
      return apiException.message;
    } catch (e) {
      debugPrint('[AUTH] Change password error: $e');
      return 'An unexpected error occurred. Please try again.';
    }
  }

  // ==================== FCM TOKEN ====================
  Future<bool> updateFcmToken(String token) async {
    try {
      final response = await _apiClient.patch(
        ApiConstants.authMe,
        data: {'fcm_device_token': token},
      );
      return response.statusCode == 200;
    } on DioException catch (e) {
      final apiException = ApiErrorMapper.mapDioException(
        e,
        defaultMessage: 'Failed to update FCM token.',
      );
      debugPrint('[AUTH] Update FCM token error: ${apiException.message}');
      return false;
    } catch (e) {
      debugPrint('[AUTH] Update FCM token error: $e');
      return false;
    }
  }

  // ==================== REGISTER ====================
  Future<bool> register({
    required String email,
    required String password,
    String firstName = '',
    String lastName = '',
    String phoneNumber = '',
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.authRegister,
        data: {
          'email': email,
          'password': password,
          'first_name': firstName,
          'last_name': lastName,
          'phone_number': phoneNumber,
        },
        connectTimeout: _emailOperationTimeout,
        receiveTimeout: _emailOperationTimeout,
      );

      return response.statusCode == 201;
    } on DioException catch (e) {
      final apiException = ApiErrorMapper.mapDioException(
        e,
        defaultMessage: 'Registration failed.',
      );
      debugPrint('[AUTH] Registration error: ${apiException.message}');
      throw apiException;
    } catch (e) {
      debugPrint('[AUTH] Registration error: $e');
      rethrow;
    }
  }

  // ==================== VERIFY EMAIL ====================
  /// Returns null on success, or an error message string.
  Future<String?> verifyEmail(String email, String otp) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.authVerifyEmail,
        data: {'email': email, 'otp_code': otp},
      );
      if (response.statusCode == 200) return null;
      final serverMessage = _extractServerMessage(response.data);
      return serverMessage ?? 'Email verification failed.';
    } on DioException catch (e) {
      final apiException = ApiErrorMapper.mapDioException(
        e,
        defaultMessage: 'Email verification failed.',
      );
      debugPrint('[AUTH] Verify email error: ${apiException.message}');
      return apiException.message;
    } catch (e) {
      debugPrint('[AUTH] Verify email error: $e');
      return 'An unexpected error occurred. Please try again.';
    }
  }

  // ==================== RESEND VERIFICATION ====================
  /// Returns null on success, or an error message string.
  Future<String?> resendVerification(String email) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.authResendVerification,
        data: {'email': email},
      );
      if (response.statusCode == 200) return null;
      final serverMessage = _extractServerMessage(response.data);
      return serverMessage ?? 'Failed to resend verification.';
    } on DioException catch (e) {
      final apiException = ApiErrorMapper.mapDioException(
        e,
        defaultMessage: 'Failed to resend verification.',
      );
      debugPrint('[AUTH] Resend verification error: ${apiException.message}');
      return apiException.message;
    } catch (e) {
      debugPrint('[AUTH] Resend verification error: $e');
      return 'An unexpected error occurred. Please try again.';
    }
  }

  // ==================== ERROR HANDLING ====================
  Future<String?> getErrorMessage() async {
    try {
      final response = await _apiClient.get(ApiConstants.authMe);

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        return data['detail'] as String? ?? data['message'] as String?;
      }
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  // ==================== PRIVATE HELPERS ====================
  /// Extracts the first usable human-readable message from a response body.
  /// Mirrors the logic in [ApiErrorMapper._extractServerMessage] for use on
  /// non-DioException paths (e.g. unexpected non-200 status codes).
  static String? _extractServerMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      final detail = data['detail'];
      if (detail is String && detail.isNotEmpty) return detail;
      final message = data['message'];
      if (message is String && message.isNotEmpty) return message;
      final errors = data['errors'];
      if (errors is Map && errors.isNotEmpty) {
        final firstVal = errors[errors.keys.first];
        if (firstVal is List && firstVal.isNotEmpty)
          return firstVal.first.toString();
        return firstVal?.toString();
      }
    }
    return null;
  }
}

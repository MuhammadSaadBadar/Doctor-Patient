import 'package:dio/dio.dart';
import 'package:doctor/core/constants/api_constants.dart';
import 'package:doctor/core/constants/user_role.dart';
import 'package:doctor/core/network/api_client.dart';
import 'package:doctor/core/network/api_error_mapper.dart';
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
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
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
  Future<bool> getUserProfile() async {
    try {
      final response = await _apiClient.get(ApiConstants.authMe);

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final userId = data['id'] as String?;
        if (userId != null) {
          await _storage.setUserId(userId);
        }
        return true;
      }

      return false;
    } on DioException catch (e) {
      final apiException = ApiErrorMapper.mapDioException(
        e,
        defaultMessage: 'Failed to get user profile.',
      );
      debugPrint('[AUTH] Get user profile error: ${apiException.message}');
      return false;
    } catch (e) {
      debugPrint('[AUTH] Get user profile error: $e');
      return false;
    }
  }

  // ==================== FORGOT PASSWORD (Step 1) ====================
  Future<bool> resetPassword(String email) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.authPasswordForgot,
        data: {'email': email},
      );
      return response.statusCode == 200;
    } on DioException catch (e) {
      final apiException = ApiErrorMapper.mapDioException(
        e,
        defaultMessage: 'Failed to send reset instructions.',
      );
      debugPrint('[AUTH] Password reset error: ${apiException.message}');
      return false;
    } catch (e) {
      debugPrint('[AUTH] Password reset error: $e');
      return false;
    }
  }

  // ==================== OTP VERIFICATION FOR RESET (Step 2) ====================
  Future<bool> verifyOtpForReset(String email, String otp) async {
    try {
      final response = await _apiClient.post(
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
        return true;
      }

      return false;
    } on DioException catch (e) {
      final apiException = ApiErrorMapper.mapDioException(
        e,
        defaultMessage: 'OTP verification failed.',
      );
      debugPrint('[AUTH] OTP verification error: ${apiException.message}');
      return false;
    } catch (e) {
      debugPrint('[AUTH] OTP verification error: $e');
      return false;
    }
  }

  // Helper to expose reset token to controller
  String? get getResetToken => _resetToken;

  // ==================== RESEND RESET OTP ====================
  Future<bool> resendResetOtp(String email) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.authPasswordForgot,
        data: {'email': email},
      );
      return response.statusCode == 200;
    } on DioException catch (e) {
      final apiException = ApiErrorMapper.mapDioException(
        e,
        defaultMessage: 'Failed to resend OTP.',
      );
      debugPrint('[AUTH] Resend reset OTP error: ${apiException.message}');
      return false;
    } catch (e) {
      debugPrint('[AUTH] Resend reset OTP error: $e');
      return false;
    }
  }

  // ==================== RESET PASSWORD WITH TOKEN (Step 3) ====================
  Future<bool> resetPasswordWithToken(String token, String newPassword) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.authPasswordReset,
        data: {'token': token, 'new_password': newPassword},
      );

      if (response.statusCode == 200) {
        Get.find<AuthController>().resetToken.value = '';
        debugPrint('[AUTH] Password reset with token successful');
        return true;
      }

      return false;
    } on DioException catch (e) {
      final apiException = ApiErrorMapper.mapDioException(
        e,
        defaultMessage: 'Failed to reset password.',
      );
      debugPrint(
        '[AUTH] Password reset with token error: ${apiException.message}',
      );
      return false;
    } catch (e) {
      debugPrint('[AUTH] Password reset with token error: $e');
      return false;
    }
  }

  // ==================== CHANGE PASSWORD (Authenticated) ====================
  Future<bool> changePassword(String oldPassword, String newPassword) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.authPasswordChange,
        data: {'old_password': oldPassword, 'new_password': newPassword},
      );

      return response.statusCode == 200;
    } on DioException catch (e) {
      final apiException = ApiErrorMapper.mapDioException(
        e,
        defaultMessage: 'Failed to change password.',
      );
      debugPrint('[AUTH] Change password error: ${apiException.message}');
      return false;
    } catch (e) {
      debugPrint('[AUTH] Change password error: $e');
      return false;
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
      );

      return response.statusCode == 201;
    } on DioException catch (e) {
      final apiException = ApiErrorMapper.mapDioException(
        e,
        defaultMessage: 'Registration failed.',
      );
      debugPrint('[AUTH] Registration error: ${apiException.message}');
      return false;
    } catch (e) {
      debugPrint('[AUTH] Registration error: $e');
      return false;
    }
  }

  // ==================== VERIFY EMAIL ====================
  Future<bool> verifyEmail(String email, String otp) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.authVerifyEmail,
        data: {'email': email, 'otp_code': otp},
      );
      return response.statusCode == 200;
    } on DioException catch (e) {
      final apiException = ApiErrorMapper.mapDioException(
        e,
        defaultMessage: 'Email verification failed.',
      );
      debugPrint('[AUTH] Verify email error: ${apiException.message}');
      return false;
    } catch (e) {
      debugPrint('[AUTH] Verify email error: $e');
      return false;
    }
  }

  // ==================== RESEND VERIFICATION ====================
  Future<bool> resendVerification(String email) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.authResendVerification,
        data: {'email': email},
      );
      return response.statusCode == 200;
    } on DioException catch (e) {
      final apiException = ApiErrorMapper.mapDioException(
        e,
        defaultMessage: 'Failed to resend verification.',
      );
      debugPrint('[AUTH] Resend verification error: ${apiException.message}');
      return false;
    } catch (e) {
      debugPrint('[AUTH] Resend verification error: $e');
      return false;
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
}

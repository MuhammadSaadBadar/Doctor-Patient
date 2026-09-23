import 'package:get/get.dart';
import 'package:doctor/core/network/api_client.dart';
import 'package:doctor/core/services/storage_service.dart';
import 'package:doctor/core/network/api_interceptors.dart';

import 'package:doctor/core/controllers/navigation_controller.dart';
import 'package:doctor/doctor/features/auth/controllers/auth_controller.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // Storage Service for persistent token storage
    Get.put<StorageService>(StorageService(), permanent: true);

    // Create AuthInterceptor with proper error handling
    final authInterceptor = AuthInterceptor();

    // ApiClient with interceptors
    final apiClient = ApiClient(
      baseUrl: 'https://mama-health-backend.onrender.com',
      interceptors: [
        LoggingInterceptor(), // For logging requests/responses
        authInterceptor, // For token management
      ],
    );

    // Set the Dio instance on the interceptor so it can replay requests
    authInterceptor.setDio(apiClient.dio);

    Get.put<ApiClient>(apiClient, permanent: true);

    // DoctorProfileRepository is removed from global bindings to prevent cross-role data contamination.
    // It should be injected in Doctor-specific bindings (e.g., DoctorProfileBinding).
    // Auth Controller
    Get.put<AuthController>(AuthController(), permanent: true);

    // Navigation Controller for bottom nav bar synchronization
    Get.put<NavigationController>(NavigationController(), permanent: true);
  }
}

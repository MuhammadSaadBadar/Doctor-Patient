import 'package:doctor/core/constants/color_constants.dart';
import 'package:doctor/core/themes/app_theme.dart';
import 'package:doctor/core/services/storage_service.dart';
import 'package:doctor/doctor/features/auth/controllers/auth_controller.dart';
import 'package:doctor/doctor/features/auth/repositories/auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:doctor/core/routes/app_routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotateAnimation;

  final AuthRepository _authRepository = AuthRepository();
  final StorageService _storage = StorageService.instance;

  @override
  void initState() {
    super.initState();

    // Set status bar color for splash screen
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    // Initialize animations
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOutBack),
      ),
    );

    _rotateAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
      ),
    );

    // Start animation
    _animationController.forward();

    // Perform auth gate check after a minimum splash duration
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    // Ensure minimum splash display time for better UX
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    final isLoggedIn = _storage.isLoggedIn;
    final accessToken = _storage.accessToken;
    final refreshToken = _storage.refreshToken;

    if (isLoggedIn && accessToken != null && accessToken.isNotEmpty) {
      // User has a stored session, validate it
      final bool sessionValid = await _validateSession(refreshToken);

      if (!mounted) return;

      if (sessionValid) {
        // Session is valid (or refreshed), go to appropriate dashboard based on role
        Get.find<AuthController>().isLoggedIn.value = true;
        final userRole = _storage.userRole;
        if (userRole == 'patient') {
          Get.offAllNamed(AppRoutes.patientDashboard);
        } else {
          Get.offAllNamed(AppRoutes.docdashboard);
        }
      } else {
        // Session invalid, clear and go to login
        await _storage.clearAuth();
        Get.find<AuthController>().isLoggedIn.value = false;
        Get.offAllNamed(AppRoutes.login);
      }
    } else {
      // No stored session, go to login
      Get.offAllNamed(AppRoutes.login);
    }
  }

  Future<bool> _validateSession(String? refreshToken) async {
    try {
      // First, try to get user profile to validate the access token
      final profileValid = await _authRepository.getUserProfile();

      // If the profile fetch succeeds, session is definitively valid.
      if (profileValid) {
        debugPrint('[AUTH GATE] Session validated via profile fetch');
        return true;
      }

      // If profileValid is false, it could be a network error (Render cold start)
      // OR a genuine session expiration.
      // If the session was genuinely expired and could not be refreshed, AuthInterceptor
      // would have called _forceLogout(), which sets _storage.isLoggedIn to false.
      if (!_storage.isLoggedIn) {
        debugPrint(
          '[AUTH GATE] Session definitively invalid (Interceptor logged out)',
        );
        return false;
      }

      // If we are still logged in according to storage, it means AuthInterceptor
      // did not force a logout, so the failure was likely a network error (e.g. timeout).
      // We should NOT clear the auth state on a network error. Let the user proceed
      // to the dashboard where the network error can be handled gracefully by the UI.
      debugPrint(
        '[AUTH GATE] Profile fetch failed, but session still marked active (Network error?)',
      );
      return true;
    } catch (e) {
      debugPrint('[AUTH GATE] Session validation error: $e');
      // On unexpected errors, don't blindly log the user out if storage says they are logged in.
      return _storage.isLoggedIn;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Doctor Illustration with animations
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: _buildDoctorIllustration(),
                  ),
                ),
                const SizedBox(height: 32),

                // App Identity with fade animation
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: _buildAppBranding(),
                ),
                const SizedBox(height: 48),

                // Loading Indicator with pulse animation
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: _buildLoadingIndicator(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDoctorIllustration() {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 280),
      child: AspectRatio(
        aspectRatio: 1,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Container(
            color: Colors.grey.shade50,
            child: Image.asset(
              'assets/images/doctor_img.png',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.medical_services,
                      size: 80,
                      color: AppColors.primary.withOpacity(0.5),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Doctor Image',
                      style: AppTheme.bodySmall.copyWith(
                        color: AppColors.primary.withOpacity(0.5),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBranding() {
    return Column(
      children: [
        Text(
          'Gynae Hub',
          style: AppTheme.headlineMedium.copyWith(
            fontSize: 36,
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primary.withOpacity(0.1),
                AppColors.primary.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            'Empowering Maternal Healthcare',
            style: AppTheme.bodyLarge.copyWith(
              color: AppColors.primary.withOpacity(0.7),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingIndicator() {
    return AnimatedBuilder(
      animation: _rotateAnimation,
      builder: (context, child) {
        return Transform.rotate(
          angle: _rotateAnimation.value * 6.2832, // Full rotation
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primary.withOpacity(0.1),
                width: 4,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(2.0),
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                strokeWidth: 4,
              ),
            ),
          ),
        );
      },
    );
  }
}

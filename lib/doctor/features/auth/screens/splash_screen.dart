import 'package:doctor/core/constants/color_constants.dart';
import 'package:doctor/core/routes/app_routes.dart';
import 'package:doctor/core/services/storage_service.dart';
import 'package:doctor/core/themes/app_theme.dart';
import 'package:doctor/doctor/features/auth/controllers/auth_controller.dart';
import 'package:doctor/doctor/features/auth/repositories/auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

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
      // User has a stored session — validate it and get a fresh authoritative role.
      final String? freshRole = await _validateSession(refreshToken);

      if (!mounted) return;

      if (freshRole != null) {
        // Session is valid (or refreshed). Route based on verified role.
        final authController = Get.find<AuthController>();
        authController.isLoggedIn.value = true;

        // Initialize the user profile in the correct role context.
        await authController.initializeCurrentUser(role: freshRole);

        if (!mounted) return;

        if (freshRole == 'patient') {
          debugPrint('[AUTH GATE] Routing Patient → /patient/dashboard');
          Get.offAllNamed(AppRoutes.patientDashboard);
        } else if (freshRole == 'doctor') {
          debugPrint('[AUTH GATE] Routing Doctor → /dashboard');
          Get.offAllNamed(AppRoutes.docdashboard);
        } else {
          // Unknown role — force re-login rather than guessing.
          debugPrint(
            '[AUTH GATE] Unknown role "$freshRole" — clearing auth, sending to /login.',
          );
          await _storage.clearAuth();
          Get.find<AuthController>().isLoggedIn.value = false;
          Get.offAllNamed(AppRoutes.login);
        }
      } else {
        // _validateSession returned null meaning:
        //   (a) the interceptor already force-logged out (token truly expired), or
        //   (b) pure network failure.
        // Check whether the interceptor already cleared the session.
        if (!_storage.isLoggedIn) {
          debugPrint('[AUTH GATE] Session cleared by interceptor — /login.');
          Get.find<AuthController>().isLoggedIn.value = false;
          Get.offAllNamed(AppRoutes.login);
        } else {
          // Network failure — fall back to the last-known stored role so the
          // user isn't unnecessarily logged out during a Render cold start or
          // brief connectivity loss.
          final storedRole = _storage.userRole;
          debugPrint(
            '[AUTH GATE] Network failure during validation. '
            'Using last-known role: $storedRole',
          );
          final authController = Get.find<AuthController>();
          authController.isLoggedIn.value = true;

          if (!mounted) return;

          if (storedRole == 'patient') {
            Get.offAllNamed(AppRoutes.patientDashboard);
          } else if (storedRole == 'doctor') {
            Get.offAllNamed(AppRoutes.docdashboard);
          } else {
            // Cannot determine role even from storage — safe fallback.
            debugPrint(
              '[AUTH GATE] No stored role available — clearing auth, /login.',
            );
            await _storage.clearAuth();
            authController.isLoggedIn.value = false;
            Get.offAllNamed(AppRoutes.login);
          }
        }
      }
    } else {
      // No stored session, go to login
      debugPrint('[AUTH GATE] No session found — /login.');
      Get.offAllNamed(AppRoutes.login);
    }
  }

  /// Validates the stored session by calling GET /api/v1/auth/me/.
  ///
  /// Returns the **authoritative role string** on success (e.g. `'patient'`,
  /// `'doctor'`), or `null` on network failure / genuine session expiry.
  ///
  /// Saving the role to storage is handled inside [AuthRepository.getUserProfile].
  Future<String?> _validateSession(String? refreshToken) async {
    try {
      // getUserProfile now returns the role directly from /me response
      // and also refreshes the stored role in SharedPreferences.
      final freshRole = await _authRepository.getUserProfile();

      if (freshRole != null) {
        debugPrint('[AUTH GATE] Session validated. Role: $freshRole');
        return freshRole;
      }

      // Profile call returned null — either network error or 401.
      // Check if the interceptor already force-logged out.
      if (!_storage.isLoggedIn) {
        debugPrint(
          '[AUTH GATE] Session definitively invalid (Interceptor logged out).',
        );
        return null;
      }

      // Still logged in in storage → likely a transient network error.
      // Return null so the caller can decide to use the cached role.
      debugPrint(
        '[AUTH GATE] Profile fetch failed but session still marked active '
        '(network error / Render cold start?).',
      );
      return null;
    } catch (e) {
      debugPrint('[AUTH GATE] Session validation error: $e');
      return null;
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

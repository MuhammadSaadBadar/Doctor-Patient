# Settings Module Consolidation - Implementation Tracker

## Phase 1: DI & Repository
- [ ] Register ProfileRepository as permanent in InitialBinding
- [ ] Update ProfileController to use Get.find<ProfileRepository>()

## Phase 2: Delete Duplicate Settings Controllers & Repositories
- [ ] Delete lib/features/settings/controllers/settings_controller.dart
- [ ] Delete lib/features/settings/controllers/doctor_profile_controller.dart
- [ ] Delete lib/features/settings/controllers/payment_controller.dart
- [ ] Delete lib/features/settings/repositories/doctor_profile_repository.dart
- [ ] Delete lib/features/settings/repositories/payment_repository.dart

## Phase 3: Update Settings Screens to Use ProfileController
- [ ] Update lib/features/settings/screens/settings_screen.dart (GetView<ProfileController>, remove dead routes)
- [ ] Update lib/features/settings/screens/payment_method_screen.dart (GetView<ProfileController>)
- [ ] Delete lib/features/settings/screens/doctor_profile_screen.dart

## Phase 4: Update Routes & Bindings
- [ ] Update lib/core/routes/app_routes.dart (add route constants)
- [ ] Update lib/core/routes/routes.dart (ProfileBinding for settings/payment, remove SettingsBinding imports)
- [ ] Update lib/features/profile/providers/profile_binding.dart (keep as-is)
- [ ] Delete lib/features/settings/providers/settings_binding.dart

## Phase 5: Fix Profile Screen Navigation
- [ ] Update lib/features/profile/screens/profile_screen.dart (wire Edit Profile, Change Password buttons)

## Phase 6: Verification
- [ ] Test build passes
- [ ] Verify all navigation works

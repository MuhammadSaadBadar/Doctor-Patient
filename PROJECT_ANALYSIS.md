# Flutter Project Analysis - doctor

## 1. Project Structure and Architecture

- **Core layer** (`lib/core/`): Services (StorageService), Network (ApiClient, AuthInterceptor, ApiErrorMapper, ApiExceptions), Routes (Routes, AppRoutes), DI (InitialBinding), Widgets (TopAppBar, SideNav, BottomNavBar, etc.)
- **Features layer** (`lib/features/`): Auth, Appointments, Dashboard, Patient - each with controllers, providers, repositories, screens, models, widgets
- **Dependency injection** via Get.put() with `permanent: true` in InitialBinding
- **Routing** using GetPages with named routes
- **Service locator** pattern using Get.find<T>() across all repositories

## 2. Key Changes Across 4 Milestones

- **Milestone 1**: Core foundation - StorageService, ApiClient, basic Routes, AppRoutes, initial_binding, app_theme
- **Milestone 2**: Auth scaffolding - AuthRepository, AuthController, auth screens (login, OTP, reset password), auth routes, LoggingInterceptor
- **Milestone 3**: Feature expansion - DashboardRepository, DashboardController, Dashboard screens/metrics, AppointmentRepository, Appointment screens/controllers, PatientRepository with symptom/logging features, Patient controllers and screens
- **Milestone 4**: Refinement - interceptor token refresh flow, onError handlers, widget polishing, remaining screen implementations; however, interceptor code introduced compiler errors that block further progress

## 3. Repository Pattern Implementation Status

| Repository | Status | Key Details |
|---|---|---|
| `AuthRepository` | ✅ Implemented | Uses ApiClient + StorageService via constructor injection; full login/refresh/logout/profile methods |
| `DashboardRepository` | ✅ Implemented | getDashboardData(), getDashboardAppointments(), getDashboardAlerts(), getDashboardMetrics() |
| `PatientRepository` | ✅ Implemented | CRUD for patient, symptoms, vitals, water intake, kick sessions |
| `AppointmentRepository` | ✅ Implemented | book/get/cancel/reschedule appointments, rate, doctor notes |

All repositories follow consistent pattern: `final ApiClient _apiClient; final StorageService _storage;` with constructor injection falling back to `Get.find<T>()`.

## 4. Authentication Interceptor Wiring

- **AuthInterceptor** (`core/network/api_interceptors.dart:18-252`) extends Dio `Interceptor`
- Handles 401 responses by queuing requests and refreshing token via `/api/v1/auth/token/refresh/`
- Queues pending requests via `_pendingRequests` list; replays after successful refresh
- `setDio(Dio dio)` method to wire interceptor to Dio instance (called from ApiClient)
- **Wiring gap**: `InitialBinding` does not pass interceptors to `ApiClient` constructor; `AuthInterceptor.setDio()` never invoked, so interceptor not attached to Dio
- Unused code warnings: `setDio`, `onRequest`, `onError` in interceptor not actively referenced in build flow

## 5. Local Storage Solution

- **StorageService** (`core/services/storage_service.dart`) uses `shared_preferences`
- Named constructor `StorageService._internal()` with singleton pattern via `instance`
- Stores: `access_token`, `refresh_token`, `user_id`, `is_logged_in`
- Initialized in `main.dart` (`await storageService.init()`) and registered in `InitialBinding` with `permanent: true`
- **Analyzer error**: `StorageService` lacks unnamed constructor - requires `StorageService()` or named constructor usage

## 6. Mock Data Replacement Status

- **Full API integration attempted**: All repositories make real Dio calls via `ApiClient`
- **GetX obs/ui binding**: Controllers use `obs` getters, `value` streams - inconsistent with actual model types
- **Hardcoded demo values**: `AuthController.verifyOtp()` generates `resetToken.value = 'demo_reset_token_...'` 
- **Missing packages**: `package:get/x.dart` references fail (package version `^4.7.3` may differ from implementation)
- **Mock data present** in controller logic but not replaceable until analyzer errors resolved

## 7. Remaining Issues / Warnings from Dart Analyzer

### Errors (37 total, blocking compilation):

1. `StorageService` no unnamed constructor (`core/services/storage_service.dart:10`, `lib/main.dart:13`)
2. `api_interceptors.dart`: 33 errors - invalid closure return types, undefined types (`ApiClient`, `_PendingRequest`), missing semicolons, referenced-before-declaration, class-in-class
3. `routes.dart`: 3 errors - invalid return types from closure (`DashboardScreen`, `DietPlansScreen`)
4. `storage_service.dart:1:8` - URI doesn't exist for `shared_preferences`
5. Controller files: `get/x.dart` URI doesn't exist, `extends` on non-class, undefined `obs`/`Rx`/`onInit`/`onClose`/`debugPrint`
6. Repository files: `String?'` assigned to `String`, undefined `replace` method, non-type as type argument

### Warnings (31 total):

- Unused imports across multiple files
- Unused fields (`_storage` in repositories)
- Override on non-overriding members
- Dead code and null-aware expression issues
- Unused `google_fonts` import, `color_constants` import
- Recursive getters, non-lowerCamelCase identifier names
import 'package:doctor/core/services/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:doctor/core/themes/app_theme.dart';
import 'package:doctor/core/routes/routes.dart';
import 'package:doctor/core/routes/app_routes.dart';
import 'package:doctor/core/di/initial_binding.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize storage service first
  final storageService = StorageService();
  await storageService.init();

  // Read saved theme preference BEFORE running the app
  final savedTheme = storageService.getTheme();
  final initialThemeMode = savedTheme == 'dark'
      ? ThemeMode.dark
      : ThemeMode.light;

  // Run the app with InitialBinding
  runApp(MyApp(initialThemeMode: initialThemeMode));
}

class MyApp extends StatelessWidget {
  final ThemeMode initialThemeMode;

  const MyApp({super.key, required this.initialThemeMode});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Gynae Hub',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: initialThemeMode,
      initialBinding: InitialBinding(),
      initialRoute: AppRoutes.splash,
      getPages: Routes.pages,
    );
  }
}

import 'dart:async';

import 'package:get/get.dart';
import 'package:doctor/core/routes/app_routes.dart';

class NavigationController extends GetxController {
  final currentIndex = 0.obs;
  final _currentRoute = RxString(Get.currentRoute);
  Timer? _routePollTimer;

  static const Map<String, int> _routeToIndex = {
    AppRoutes.dashboard: 0,
    AppRoutes.appointments: 1,
    AppRoutes.patients: 2,
    AppRoutes.sos: 3,
    AppRoutes.settings: 4,
  };

  @override
  void onInit() {
    super.onInit();
    _syncFromRoute(Get.currentRoute);

    // Observe route changes via reactive string
    ever(_currentRoute, (String route) => _syncFromRoute(route));

    // Poll for route changes (back navigation, deep links, etc.)
    _routePollTimer = Timer.periodic(const Duration(milliseconds: 200), (_) {
      final route = Get.currentRoute;
      if (_currentRoute.value != route) {
        _currentRoute.value = route;
      }
    });
  }

  @override
  void onClose() {
    _routePollTimer?.cancel();
    super.onClose();
  }

  void _syncFromRoute(String route) {
    final baseRoute = route
        .split('/')
        .firstWhere((s) => s.isNotEmpty, orElse: () => 'dashboard');
    final fullRoute = '/$baseRoute';
    if (_routeToIndex.containsKey(fullRoute)) {
      currentIndex.value = _routeToIndex[fullRoute]!;
    }
  }

  void onTabTap(int index) {
    if (currentIndex.value != index) {
      currentIndex.value = index;
      final routes = _routeToIndex.keys.toList();
      Get.offAllNamed(routes[index]);
    }
  }
}

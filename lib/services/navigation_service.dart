import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class NavigationService {
  late GlobalKey<NavigatorState> navigatorKey;
  static NavigationService instance = NavigationService();
  NavigationService() {
    navigatorKey = GlobalKey<NavigatorState>();
  }

  Future<dynamic> navigateToReplacement(String _routename) {
    return navigatorKey.currentState!.pushReplacementNamed(_routename);
  }

  Future<dynamic> navigateTo(String _routename) {
    return navigatorKey.currentState!.pushNamed(_routename);
  }

  Future<dynamic> navigateToRoute(MaterialPageRoute _route) {
    return navigatorKey.currentState!.push(_route);
  }

  bool goBack() {
    if (navigatorKey.currentState!.canPop()) {
      navigatorKey.currentState?.pop();
      return true;
    }
    return false;
  }
}

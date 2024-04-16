import 'package:flutter/material.dart';

class NavigationService with ChangeNotifier {
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static BuildContext? context = navigatorKey.currentContext;
}

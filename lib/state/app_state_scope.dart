import 'package:flutter/widgets.dart';

import 'app_state.dart';

class AppStateScope extends InheritedNotifier<AppState> {
  const AppStateScope({
    super.key,
    required super.notifier,
    required super.child,
  });

  static AppState of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppStateScope>();

    if (scope == null || scope.notifier == null) {
      throw Exception('AppStateScope no encontrado en el árbol de widgets.');
    }

    return scope.notifier!;
  }
}
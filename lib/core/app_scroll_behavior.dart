import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

/// Support mouse dragging as well as touch and trackpad scrolling.
class AppScrollBehavior extends MaterialScrollBehavior {
  const AppScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => {
    ...super.dragDevices,
    PointerDeviceKind.mouse,
  };
}

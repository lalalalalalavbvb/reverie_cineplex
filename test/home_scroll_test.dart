import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reverie_cineplex/main.dart';

void main() {
  for (final size in [const Size(430, 700), const Size(932, 430)]) {
    for (final kind in [PointerDeviceKind.touch, PointerDeviceKind.mouse]) {
      testWidgets('Home scrolls with $kind at $size', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await tester.pumpWidget(const MyApp());
        await tester.pumpAndSettle();
        final scroll = find.byKey(const PageStorageKey('home-movies'));
        final state = tester.state<ScrollableState>(
          find.descendant(of: scroll, matching: find.byType(Scrollable)).first,
        );
        expect(state.position.maxScrollExtent, greaterThan(0));
        final start = tester.getRect(scroll).center;
        final gesture = await tester.startGesture(start, kind: kind);
        await gesture.moveBy(const Offset(0, -150));
        await gesture.up();
        await tester.pumpAndSettle();
        expect(state.position.pixels, greaterThan(0));
        expect(tester.takeException(), isNull);
      });
    }
  }
}

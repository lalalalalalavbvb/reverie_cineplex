import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reverie_cineplex/main.dart';

void main() {
  testWidgets('Profile theme, about, and logout actions work', (tester) async {
    tester.view.physicalSize = const Size(430, 932);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('โปรไฟล์'));
    await tester.pumpAndSettle();

    expect(find.text('ธีมมืด'), findsOneWidget);
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();
    expect(find.text('ธีมสว่าง'), findsOneWidget);
    expect(
      Theme.of(tester.element(find.text('ธีมสว่าง'))).brightness,
      Brightness.light,
    );

    await tester.tap(find.text('เกี่ยวกับทีมผู้พัฒนา (About Us)'));
    await tester.pumpAndSettle();
    expect(find.text('Reverie Cineplex'), findsOneWidget);
    expect(find.textContaining('คนที่ 2'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(find.text('ออกจากระบบ'));
    await tester.pumpAndSettle();
    expect(find.text('ออกจากระบบ?'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'ออกจากระบบ'));
    await tester.pumpAndSettle();
    expect(find.text('ออกจากระบบตัวอย่างแล้ว'), findsOneWidget);
    expect(find.text('กำลังฉาย'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

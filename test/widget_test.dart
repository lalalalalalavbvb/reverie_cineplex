import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reverie_cineplex/screens/booking/booking_flow.dart';

void main() {
  testWidgets('Booking carries seats and food total through checkout', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(430, 932);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(theme: bookingTheme(), home: const BookingFlow()),
    );
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('14:00'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('14:00'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('seat-C7')),
      280,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.byKey(const ValueKey('seat-C7')));
    await tester.tap(find.byKey(const ValueKey('seat-C8')));
    await tester.pump();
    await tester.scrollUntilVisible(
      find.byType(TextFormField),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.enterText(find.byType(TextFormField), '0812345678');
    expect(find.text('360 บาท'), findsOneWidget);
    await tester.tap(find.text('ดำเนินการต่อ'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.add_circle).first);
    await tester.pump();
    expect(find.textContaining('820 บาท'), findsOneWidget);
    await tester.tap(find.textContaining('ดำเนินการต่อ'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'ชำระเงิน'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('ไทยคิวอาร์'));
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, 'ชำระเงิน'));
    await tester.pump();
    expect(find.text('ตัวอย่างหน้าชำระเงิน'), findsOneWidget);
    expect(find.text('รวม: 820 บาท'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('ดูตั๋วตัวอย่าง'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('ดูตั๋วตัวอย่าง'));
    await tester.pumpAndSettle();
    expect(find.text('ยอดรวม 820 บาท'), findsOneWidget);
    expect(find.text('C7, C8'), findsOneWidget);
    expect(find.textContaining('ใช้เข้าโรงภาพยนตร์ไม่ได้'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });
}

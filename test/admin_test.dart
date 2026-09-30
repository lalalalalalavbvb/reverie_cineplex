import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reverie_cineplex/screens/admin/admin_page.dart';
import 'package:reverie_cineplex/screens/booking/booking_flow.dart';
import 'package:reverie_cineplex/services/booking_service.dart';

void main() {
  testWidgets('Admin validates, creates, edits, and deletes demo food', (
    tester,
  ) async {
    final service = DemoBookingService();
    addTearDown(service.dispose);
    await tester.pumpWidget(
      MaterialApp(
        theme: bookingTheme(),
        home: AdminPage(service: service),
      ),
    );
    await tester.tap(find.text('อาหาร'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('เพิ่มอาหาร'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('บันทึก'));
    await tester.pump();
    expect(find.text('กรุณากรอกข้อมูล'), findsNWidgets(2));
    await tester.enterText(find.byType(TextFormField).at(0), 'น้ำดื่ม');
    await tester.enterText(find.byType(TextFormField).at(1), '600 มล.');
    await tester.enterText(find.byType(TextFormField).at(2), '30');
    await tester.tap(find.text('บันทึก'));
    await tester.pumpAndSettle();
    expect(service.items('อาหาร').last.price, 30);
    await tester.ensureVisible(find.byTooltip('แก้ไข').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('แก้ไข').last);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(2), '35');
    await tester.tap(find.text('บันทึก'));
    await tester.pumpAndSettle();
    expect(service.items('อาหาร').last.price, 35);
    await tester.ensureVisible(find.byTooltip('ลบ').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('ลบ').last);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'ยกเลิก'));
    await tester.pumpAndSettle();
    expect(service.items('อาหาร').length, 2);
    await tester.ensureVisible(find.byTooltip('ลบ').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('ลบ').last);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'ลบ'));
    await tester.pumpAndSettle();
    expect(service.items('อาหาร').length, 1);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('Admin booking opens a clearly labeled sample ticket', (
    tester,
  ) async {
    final service = DemoBookingService();
    addTearDown(service.dispose);
    await tester.pumpWidget(
      MaterialApp(
        theme: bookingTheme(),
        home: AdminPage(service: service),
      ),
    );
    await tester.tap(find.text('รายการจอง'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(ListTile));
    await tester.pumpAndSettle();
    expect(find.text('ตั๋วภาพยนตร์'), findsOneWidget);
    expect(find.text('C7, C8'), findsOneWidget);
    expect(find.textContaining('ใช้เข้าโรงภาพยนตร์ไม่ได้'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });
}

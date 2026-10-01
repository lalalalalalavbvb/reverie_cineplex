import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reverie_cineplex/models/booking_model.dart';
import 'package:reverie_cineplex/screens/admin/admin_page.dart';
import 'package:reverie_cineplex/screens/booking/booking_flow.dart';
import 'package:reverie_cineplex/services/booking_service.dart';

class FakeBookingService extends BookingService {
  final Map<String, List<AdminItem>> _items = {
    CinemaCatalog.foodCategory: [
      const AdminItem(
        id: 'food-1',
        name: 'ชุดซุปเปอร์ไซส์ เซต',
        detail: 'ป๊อปคอร์น 1 ถัง + เครื่องดื่ม 2 แก้ว',
        price: 460,
      ),
    ],
  };

  @override
  List<BookingModel> get bookings => const [
    BookingModel(
      id: 'DEMO-001',
      movie: 'จีบซ้ำซ้ำ เฮนรี่จำไม่ได้',
      cinema: 'เมเจอร์ โลตัส กำแพงแสน',
      date: '19 ก.ย. 2569',
      time: '14:00',
      seats: ['C7', 'C8'],
      total: 360,
    ),
  ];

  @override
  List<AdminItem> items(String category) =>
      List.unmodifiable(_items[category] ?? const <AdminItem>[]);

  @override
  Future<void> saveItem(String category, AdminItem item) async {
    final list = _items.putIfAbsent(category, () => []);
    final index = list.indexWhere((e) => e.id == item.id);
    if (index < 0) {
      list.add(item);
    } else {
      list[index] = item;
    }
    notifyListeners();
  }

  @override
  Future<void> deleteItem(String category, String id) async {
    _items[category]?.removeWhere((e) => e.id == id);
    notifyListeners();
  }
}

void main() {
  testWidgets('Admin validates, creates, edits, and deletes food', (
    tester,
  ) async {
    final service = FakeBookingService();
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
    expect(find.text('กรุณากรอกชื่ออาหาร'), findsOneWidget);
    expect(find.text('กรอกราคาเป็นจำนวนเต็มมากกว่า 0'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).at(0), 'น้ำดื่ม');
    await tester.enterText(find.byType(TextFormField).at(1), '600 มล.');
    await tester.enterText(find.byType(TextFormField).at(2), '30');
    await tester.tap(find.text('บันทึก'));
    await tester.pumpAndSettle();
    expect(service.items('อาหาร').length, 2);
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
    final service = FakeBookingService();
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
import 'package:flutter/foundation.dart';
import '../models/booking_model.dart';

/// Replace this implementation with the team's API adapter.
/// Authorization, payment verification and seat locks must be enforced by the server.
abstract class BookingService extends ChangeNotifier {
  List<BookingModel> get bookings;
  List<AdminItem> items(String category);
  Future<void> saveItem(String category, AdminItem item);
  Future<void> deleteItem(String category, String id);
}

class DemoBookingService extends BookingService {
  final Map<String, List<AdminItem>> _items = {
    'รอบฉาย': [
      const AdminItem(
        id: 'show-1',
        name: 'จีบซ้ำซ้ำ เฮนรี่จำไม่ได้',
        detail: 'Theatre 1 • 19 ก.ย. 2569 • 14:00',
        price: 160,
      ),
    ],
    'อาหาร': [
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
      List.unmodifiable(_items[category] ?? []);
  @override
  Future<void> saveItem(String category, AdminItem item) async {
    final items = _items.putIfAbsent(category, () => []);
    final index = items.indexWhere((e) => e.id == item.id);
    if (index < 0) {
      items.add(item);
    } else {
      items[index] = item;
    }
    notifyListeners();
  }

  @override
  Future<void> deleteItem(String category, String id) async {
    _items[category]?.removeWhere((e) => e.id == id);
    notifyListeners();
  }
}

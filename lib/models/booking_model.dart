/// Display contract for person 3's booking API. Never implies payment success.
class BookingModel {
  const BookingModel({
    required this.id,
    required this.movie,
    required this.cinema,
    required this.date,
    required this.time,
    required this.seats,
    required this.total,
    this.status = 'ตัวอย่าง',
    this.food = const [],
  });
  final String id, movie, cinema, date, time, status;
  final List<String> seats, food;
  final int total;
}

class AdminItem {
  const AdminItem({
    required this.id,
    required this.name,
    required this.detail,
    required this.price,
  });
  final String id, name, detail;
  final int price;
}

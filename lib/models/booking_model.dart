class BookingModel {
  const BookingModel({
    required this.id,
    required this.movie,
    required this.cinema,
    required this.date,
    required this.time,
    required this.seats,
    required this.total,
    this.status = 'preview',
    this.food = const [],
    this.referenceCode = '',
    this.qrPayload = '',
    this.isPaid = false,
    this.phone = '',
    this.email = '',
  });

  final String id;
  final String movie;
  final String cinema;
  final String date;
  final String time;
  final List<String> seats;
  final int total;
  final String status;
  final List<String> food;
  final String referenceCode;
  final String qrPayload;
  final bool isPaid;

  final String phone;

  final String email;

  factory BookingModel.fromMap(String id, Map<String, dynamic> data) {
    return BookingModel(
      id: id,
      movie: data['movie'] as String? ?? '',
      cinema: data['cinema'] as String? ?? '',
      date: data['date'] as String? ?? '',
      time: data['time'] as String? ?? '',
      seats: (data['seats'] as List<dynamic>? ?? const []).cast<String>(),
      total: (data['total'] as num?)?.toInt() ?? 0,
      status: data['status'] as String? ?? 'paid',
      food: (data['food'] as List<dynamic>? ?? const []).cast<String>(),
      referenceCode: data['referenceCode'] as String? ?? id,
      qrPayload: data['qrPayload'] as String? ?? '',
      isPaid: data['status'] == 'paid',
      phone: data['phone'] as String? ?? '',
      email: data['email'] as String? ?? '',
    );
  }
}

class AdminItem {
  const AdminItem({
    required this.id,
    required this.name,
    required this.detail,
    required this.price,
    this.image = '',
  });
  final String id, name, detail;
  final int price;

  final String image;
}
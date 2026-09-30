import 'package:flutter/material.dart';
import '../../models/booking_model.dart';

class TicketPage extends StatelessWidget {
  const TicketPage({super.key, required this.booking});
  final BookingModel booking;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('ตั๋วภาพยนตร์')),
    body: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Icon(
              Icons.confirmation_number_outlined,
              size: 52,
              color: Color(0xFFEFBA3C),
            ),
            const SizedBox(height: 16),
            const Text(
              'REVERIE CINEPLEX',
              textAlign: TextAlign.center,
              style: TextStyle(letterSpacing: 3, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Chip(label: Text(booking.status)),
                    Text(
                      booking.movie,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(booking.cinema),
                    const Divider(height: 32),
                    Text(
                      '${booking.date}    ${booking.time}',
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 12),
                    const Text('Theatre 1 • 2D • TH / EN'),
                    const SizedBox(height: 24),
                    const Text('ที่นั่ง'),
                    Text(
                      booking.seats.join(', '),
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFEFBA3C),
                      ),
                    ),
                    for (final food in booking.food)
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Text(food),
                      ),
                    const Divider(height: 32),
                    Text(
                      'ยอดรวม ${booking.total} บาท',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text('หมายเลขอ้างอิง: ${booking.id}'),
                    const SizedBox(height: 12),
                    const Text(
                      'ตั๋วตัวอย่าง • ใช้เข้าโรงภาพยนตร์ไม่ได้\nยังไม่มีการยืนยันการชำระเงินจากระบบ',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('กลับ'),
            ),
          ],
        ),
      ),
    ),
  );
}

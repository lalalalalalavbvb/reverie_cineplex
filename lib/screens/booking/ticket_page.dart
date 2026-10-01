import 'dart:math';

import 'package:flutter/material.dart';

import '../../models/booking_model.dart';

class TicketPage extends StatelessWidget {
  const TicketPage({super.key, required this.booking});

  final BookingModel booking;

  @override
  Widget build(BuildContext context) {
    final paid = booking.isPaid;
    return Scaffold(
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
                      Chip(label: Text(paid ? 'ชำระเงินเรียบร้อย' : 'ตัวอย่าง')),
                      Text(
                        booking.movie,
                        style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      Text(booking.cinema),
                      const Divider(height: 32),
                      Text('${booking.date}    ${booking.time}', style: const TextStyle(fontSize: 18)),
                      const SizedBox(height: 12),
                      const Text('Theatre 1 · 2D · TH / EN'),
                      const SizedBox(height: 24),
                      const Text('ที่นั่ง'),
                      Text(
                        booking.seats.join(', '),
                        style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFFEFBA3C)),
                      ),
                      for (final food in booking.food)
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Text(food),
                        ),
                      const Divider(height: 32),
                      Text(
                        'ยอดรวม ${booking.total} บาท',
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      if (paid) ...[
                        const SizedBox(height: 20),
                        Center(
                          child: Column(
                            children: [
                              _FakeQrCode(seed: booking.qrPayload.isEmpty ? booking.referenceCode : booking.qrPayload),
                              const SizedBox(height: 8),
                              const Text('QR จำลองสำหรับเครื่องพิมพ์ตั๋ว'),
                            ],
                          ),
                        ),
                        const Divider(height: 32),
                        Text('หมายเลขอ้างอิง: ${booking.referenceCode}'),
                      ] else ...[
                        const SizedBox(height: 20),
                        Text('หมายเลขอ้างอิง: ${booking.id}'),
                        const SizedBox(height: 12),
                        const Text(
                          'ตั๋วตัวอย่าง · ยังไม่มีการชำระเงินจริงและไม่มีการยืนยันการจอง',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: () {
                  if (paid) {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  } else {
                    Navigator.pop(context);
                  }
                },
                child: Text(paid ? 'ปิดหน้าตั๋ว' : 'กลับ'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FakeQrCode extends StatelessWidget {
  const _FakeQrCode({required this.seed});
  final String seed;

  @override
  Widget build(BuildContext context) => Container(
    width: 160,
    height: 160,
    padding: const EdgeInsets.all(8),
    color: Colors.white,
    child: CustomPaint(painter: _FakeQrPainter(seed)),
  );
}

class _FakeQrPainter extends CustomPainter {
  const _FakeQrPainter(this.seed);
  final String seed;

  @override
  void paint(Canvas canvas, Size size) {
    const cells = 29;
    final cell = size.width / cells;
    final paint = Paint()..color = Colors.black;
    final random = Random(seed.hashCode);
    final reserved = List.generate(cells, (_) => List.filled(cells, false));

    void finder(int left, int top) {
      for (var y = -1; y <= 7; y++) {
        for (var x = -1; x <= 7; x++) {
          final px = left + x;
          final py = top + y;
          if (px < 0 || py < 0 || px >= cells || py >= cells) continue;
          reserved[py][px] = true;
          final inFinder = x >= 0 && x <= 6 && y >= 0 && y <= 6;
          final edge = x == 0 || x == 6 || y == 0 || y == 6;
          final center = x >= 2 && x <= 4 && y >= 2 && y <= 4;
          if (inFinder && (edge || center)) {
            canvas.drawRect(Rect.fromLTWH(px * cell, py * cell, cell, cell), paint);
          }
        }
      }
    }

    finder(1, 1);
    finder(cells - 8, 1);
    finder(1, cells - 8);
    for (var y = 0; y < cells; y++) {
      for (var x = 0; x < cells; x++) {
        if (!reserved[y][x] && random.nextBool()) {
          canvas.drawRect(Rect.fromLTWH(x * cell, y * cell, cell, cell), paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _FakeQrPainter oldDelegate) => seed != oldDelegate.seed;
}

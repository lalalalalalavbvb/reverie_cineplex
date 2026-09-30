import 'dart:async';
import 'package:flutter/material.dart';
import '../../models/booking_model.dart';
import '../../models/movie_model.dart';
import 'ticket_page.dart';
part 'showtime_page.dart';
part 'seat_page.dart';
part 'food_page.dart';
part 'summary_page.dart';
part 'payment_page.dart';
part 'qr_payment_page.dart';

const bookingGold = Color(0xFFEFBA3C);
const _surface = Color(0xFF222222);
const _movie = 'จีบซ้ำซ้ำ เฮนรี่จำไม่ได้';
const _branches = [
  'เมเจอร์ โลตัส กำแพงแสน',
  'เมเจอร์ โลตัส นครปฐม',
  'เมเจอร์ เซ็นทรัล นครปฐม',
];

ThemeData bookingTheme() => ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: const Color(0xFF111111),
  colorScheme: const ColorScheme.dark(primary: bookingGold, surface: _surface),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF111111),
    centerTitle: true,
    elevation: 0,
  ),
  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(
      backgroundColor: bookingGold,
      foregroundColor: Colors.black,
      minimumSize: const Size.fromHeight(52),
      textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: _surface,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide.none,
    ),
  ),
);

class BookingFlow extends StatefulWidget {
  const BookingFlow({super.key, this.movie, this.onTicketPreview});
  final MovieModel? movie;
  final ValueChanged<BookingModel>? onTicketPreview;
  String get movieTitle => movie?.title ?? _movie;
  @override
  State<BookingFlow> createState() => _BookingFlowState();
}

class _BookingFlowState extends State<BookingFlow> {
  void update(VoidCallback action) => setState(action);
  int step = 0;
  int day = 0;
  int branch = 0;
  int expandedBranch = 0;
  String time = '14:00';
  String query = '';
  bool favoritesOnly = false;
  final favorites = <int>{0};
  final seats = <String>{};
  final quantities = <int, int>{};
  final phone = TextEditingController();
  final email = TextEditingController();
  final form = GlobalKey<FormState>();
  int? payment;
  Timer? timer;
  int seconds = 300;
  static const products = [
    'ชุดซุปเปอร์ไซส์ เซต',
    'ชุด คอมโบ คัพเพิล',
    'ชุดคอมโบ ปาร์ตี้',
    'ป๊อปคอร์น',
    'ป๊อปคอร์น กลับบ้าน',
  ];
  static const prices = [460, 350, 430, 120, 150];
  int get ticketTotal =>
      seats.fold(0, (sum, s) => sum + ('ABCD'.contains(s[0]) ? 180 : 160));
  int get foodTotal =>
      quantities.entries.fold(0, (sum, e) => sum + prices[e.key] * e.value);
  int get total => ticketTotal + foodTotal;
  String get seatNames => (seats.toList()..sort()).join(', ');
  String get date => '${18 + day} ก.ย. 2569';
  String get countdown =>
      '${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}';

  @override
  void dispose() {
    timer?.cancel();
    phone.dispose();
    email.dispose();
    super.dispose();
  }

  void go(int next) => setState(() => step = next);
  void message(String text) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  void previewTicket() {
    final booking = BookingModel(
      id: 'DEMO-PREVIEW-${widget.movie?.id ?? -1}',
      movie: widget.movieTitle,
      cinema: _branches[branch],
      date: date,
      time: time,
      seats: List.unmodifiable(seats.toList()..sort()),
      total: total,
      food: [
        for (final e in quantities.entries)
          if (e.value > 0) '${products[e.key]} × ${e.value}',
      ],
    );
    widget.onTicketPreview?.call(booking);
    Navigator.push(
      context,
      MaterialPageRoute<void>(builder: (_) => TicketPage(booking: booking)),
    );
  }

  void startQr() {
    seconds = 300;
    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (seconds <= 1) {
        t.cancel();
      }
      if (mounted) {
        setState(() => seconds = (seconds - 1).clamp(0, 300));
      }
    });
    go(5);
  }

  @override
  Widget build(BuildContext context) {
    const titles = [
      '',
      'เลือกที่นั่ง',
      'อาหารและเครื่องดื่ม',
      'สรุปตั๋วภาพยนตร์',
      'การชำระเงิน',
      'ไทยคิวอาร์',
    ];
    return Theme(
      data: bookingTheme(),
      child: PopScope(
        canPop: step == 0,
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop && step > 0) {
            go(step - 1);
          }
        },
        child: Scaffold(
          appBar: AppBar(
            leading: step > 0
                ? IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new),
                    onPressed: () => go(step - 1),
                  )
                : null,
            title: Text(
              titles[step],
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            actions: [
              if (step == 2)
                TextButton(onPressed: () => go(3), child: const Text('ข้าม')),
            ],
          ),
          body: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  if (step == 0) ...showtimes(),
                  if (step == 1) ...seatPage(),
                  if (step == 2) ...foodPage(),
                  if (step == 3) ...summary(),
                  if (step == 4) ...paymentPage(),
                  if (step == 5) ...qrPage(),
                  const SizedBox(height: 28),
                ],
              ),
            ),
          ),
          bottomNavigationBar: step == 0 || step == 4
              ? null
              : SafeArea(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      color: _surface,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                    ),
                    child: FilledButton(
                      onPressed: step == 1 && seats.isEmpty
                          ? null
                          : () {
                              if (step == 1) {
                                if (form.currentState!.validate()) go(2);
                              } else if (step == 2) {
                                go(3);
                              } else if (step == 3) {
                                final value = email.text.trim();
                                if (value.isNotEmpty &&
                                    !RegExp(
                                      r'^[^\s@]+@[^\s@]+\.[^\s@]+$',
                                    ).hasMatch(value)) {
                                  message('กรุณาตรวจสอบอีเมล');
                                  return;
                                }
                                go(4);
                              } else {
                                message(
                                  'ยังไม่มี QR สำหรับชำระเงินจริงให้บันทึก',
                                );
                              }
                            },
                      child: Text(
                        step == 5
                            ? 'บันทึก คิวอาร์โค้ด'
                            : step == 3
                            ? 'ชำระเงิน'
                            : step == 2
                            ? 'ดำเนินการต่อ                       $total บาท'
                            : 'ดำเนินการต่อ',
                      ),
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Widget pad(Widget child) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    child: child,
  );
  Widget heading(String value) => Text(
    value,
    style: const TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
  );
  Widget pair(String left, String right, {bool gold = false}) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: Row(
      children: [
        Expanded(child: Text(left, style: const TextStyle(fontSize: 17))),
        Text(
          right,
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.bold,
            color: gold ? bookingGold : null,
          ),
        ),
      ],
    ),
  );
  Widget totalBar() => Container(
    color: bookingGold,
    padding: const EdgeInsets.all(16),
    child: DefaultTextStyle(
      style: const TextStyle(color: Colors.black),
      child: pair('ยอดชำระรวม', '$total บาท'),
    ),
  );
  Widget banner({bool large = false}) => SizedBox(
    height: large ? 310 : 165,
    child: Stack(
      fit: StackFit.expand,
      children: [
        if (widget.movie == null || widget.movie!.id == -1)
          const ReferenceRegion(
            asset: 'movie_reference.png',
            region: Rect.fromLTWH(0, .105, 1, .165),
          )
        else if (widget.movie!.backdropPath != null)
          Image.network(
            widget.movie!.backdropUrl(),
            fit: BoxFit.cover,
            errorBuilder: (_, error, stack) =>
                const ColoredBox(color: _surface),
          )
        else
          const ColoredBox(color: _surface, child: Icon(Icons.movie, size: 64)),
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, Colors.black87],
            ),
          ),
        ),
        Positioned(
          left: 16,
          right: 16,
          bottom: 18,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (large)
                Text(
                  widget.movie?.releaseDate ?? '17 ก.ย. 2569',
                  style: TextStyle(
                    color: bookingGold,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              Text(
                widget.movieTitle,
                style: const TextStyle(
                  fontSize: 27,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                widget.movie == null || widget.movie!.id == -1
                    ? 'Comedy, Romance'
                    : 'ภาพยนตร์',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                '◷ ${widget.movie?.runtimeMinutes ?? 115} นาที',
                style: TextStyle(color: Colors.white70),
              ),
              if (large)
                Align(
                  alignment: Alignment.centerRight,
                  child: OutlinedButton(
                    onPressed: () => showDialog<void>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(widget.movieTitle),
                        content: Text(
                          widget.movie?.overview ??
                              'Comedy, Romance\nความยาว 115 นาที • เรต G\nเสียงไทย / คำบรรยายอังกฤษ',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('ปิด'),
                          ),
                        ],
                      ),
                    ),
                    child: const Text('รายละเอียด'),
                  ),
                ),
            ],
          ),
        ),
      ],
    ),
  );
}

/// Displays a reference photograph region; all controls remain native widgets.
class ReferenceRegion extends StatelessWidget {
  const ReferenceRegion({super.key, required this.asset, required this.region});
  final String asset;
  final Rect region;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (_, constraints) {
      final widthFromRegion = constraints.maxWidth / region.width;
      final widthFromHeight =
          constraints.maxHeight / region.height * 1320 / 2868;
      final width = widthFromRegion > widthFromHeight
          ? widthFromRegion
          : widthFromHeight;
      final height = width * 2868 / 1320;
      return ClipRect(
        child: Stack(
          children: [
            Positioned(
              left:
                  -region.left * width +
                  (constraints.maxWidth - region.width * width) / 2,
              top:
                  -region.top * height +
                  (constraints.maxHeight - region.height * height) / 2,
              width: width,
              height: height,
              child: Image.asset('assets/booking/$asset', fit: BoxFit.fill),
            ),
          ],
        ),
      );
    },
  );
}

class SeatPainter extends CustomPainter {
  SeatPainter(this.color);
  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    final fill = Paint()..color = color;
    final outline = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    void part(Rect rect, double radius) {
      final shape = RRect.fromRectAndRadius(rect, Radius.circular(radius));
      canvas.drawRRect(shape, fill);
      canvas.drawRRect(shape, outline);
    }

    part(
      Rect.fromLTWH(
        size.width * .16,
        size.height * .12,
        size.width * .68,
        size.height * .65,
      ),
      3,
    );
    part(
      Rect.fromLTWH(
        size.width * .1,
        size.height * .65,
        size.width * .8,
        size.height * .23,
      ),
      1,
    );
    part(
      Rect.fromLTWH(
        size.width * .05,
        size.height * .48,
        size.width * .13,
        size.height * .4,
      ),
      1,
    );
    part(
      Rect.fromLTWH(
        size.width * .82,
        size.height * .48,
        size.width * .13,
        size.height * .4,
      ),
      1,
    );
  }

  @override
  bool shouldRepaint(SeatPainter oldDelegate) => color != oldDelegate.color;
}

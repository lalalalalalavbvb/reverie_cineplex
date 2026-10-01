import 'dart:async';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../models/booking_model.dart';
import '../../models/movie_model.dart';
import '../../services/ticket_service.dart';
import '../../services/booking_service.dart';
import '../../widgets/food_image.dart';
import '../auth/login_page.dart';
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
const _thaiMonths = [
  'ม.ค.',
  'ก.พ.',
  'มี.ค.',
  'เม.ย.',
  'พ.ค.',
  'มิ.ย.',
  'ก.ค.',
  'ส.ค.',
  'ก.ย.',
  'ต.ค.',
  'พ.ย.',
  'ธ.ค.',
];
const _thaiWeekdays = [
  'จันทร์',
  'อังคาร',
  'พุธ',
  'พฤหัส',
  'ศุกร์',
  'เสาร์',
  'อาทิตย์',
];
const _dayCount = 6;
DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);
const _branches = [
  'เมเจอร์ โลตัส กำแพงแสน',
  'เมเจอร์ โลตัส นครปฐม',
  'เมเจอร์ เซ็นทรัล นครปฐม',
];

class _FoodItem {
  const _FoodItem({
    required this.id,
    required this.name,
    required this.price,
    this.detail = '',
    this.image = '',
    this.region,
  });
  final String id;
  final String name;
  final int price;
  final String detail;

  final String image;

  final Rect? region;
}

const _builtInFoods = [
  _FoodItem(
    id: 'builtin-0',
    name: 'ชุดซุปเปอร์ไซส์ เซต',
    price: 460,
    region: Rect.fromLTWH(.037, .202, .445, .203),
  ),
  _FoodItem(
    id: 'builtin-1',
    name: 'ชุด คอมโบ คัพเพิล',
    price: 350,
    region: Rect.fromLTWH(.52, .202, .443, .203),
  ),
  _FoodItem(
    id: 'builtin-2',
    name: 'ชุดคอมโบ ปาร์ตี้',
    price: 430,
    region: Rect.fromLTWH(.037, .480, .445, .203),
  ),
  _FoodItem(
    id: 'builtin-3',
    name: 'ป๊อปคอร์น',
    price: 120,
    region: Rect.fromLTWH(.037, .79, .445, .09),
  ),
  _FoodItem(
    id: 'builtin-4',
    name: 'ป๊อปคอร์น กลับบ้าน',
    price: 150,
    region: Rect.fromLTWH(.52, .79, .443, .09),
  ),
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
  const BookingFlow({
    super.key,
    this.movie,
    this.onTicketPreview,
    this.isLoggedIn,
  });
  final MovieModel? movie;
  final ValueChanged<BookingModel>? onTicketPreview;

  final bool Function()? isLoggedIn;
  String get movieTitle => movie?.title ?? _movie;
  @override
  State<BookingFlow> createState() => _BookingFlowState();
}

class _BookingFlowState extends State<BookingFlow> {
  void update(VoidCallback action) => setState(action);
  int step = 0;
  int day = 0;
  final DateTime today = _dateOnly(DateTime.now());
  int branch = 0;
  String selectedCinema = _branches.first;
  int showtimePrice = 160;
  bool selectedLegacyShowtime = true;
  int expandedBranch = 0;
  String time = '14:00';
  String query = '';
  bool favoritesOnly = false;
  bool savingPurchase = false;
  final ticketService = TicketService();
  final favorites = <int>{0};
  final seats = <String>{};

  final quantities = <String, int>{};
  final phone = TextEditingController();
  final email = TextEditingController();
  final form = GlobalKey<FormState>();
  int? payment;
  Timer? timer;
  int seconds = 300;

  List<_FoodItem> get foodMenu => [
    ..._builtInFoods,
    for (final item in CinemaCatalog.service.items(CinemaCatalog.foodCategory))
      _FoodItem(
        id: item.id,
        name: item.name,
        price: item.price,
        detail: item.detail,
        image: item.image,
      ),
  ];
  _FoodItem? foodById(String id) {
    for (final food in foodMenu) {
      if (food.id == id) return food;
    }
    return null;
  }

  int get ticketTotal => seats.fold(
    0,
    (sum, seat) =>
        sum +
        (selectedLegacyShowtime && 'ABCD'.contains(seat[0])
            ? 180
            : showtimePrice),
  );
  int get foodTotal => quantities.entries.fold(
    0,
    (sum, e) => sum + (foodById(e.key)?.price ?? 0) * e.value,
  );
  int get total => ticketTotal + foodTotal;
  String get seatNames => (seats.toList()..sort()).join(', ');
  DateTime dateAt(int offset) =>
      DateTime(today.year, today.month, today.day + offset);
  DateTime get selectedDate => dateAt(day);
  String get monthYear =>
      '${_thaiMonths[selectedDate.month - 1]} ${selectedDate.year + 543}';
  String get date =>
      '${selectedDate.day} ${_thaiMonths[selectedDate.month - 1]} ${selectedDate.year + 543}';
  List<AdminItem> get configuredShowtimes =>
      CinemaCatalog.service.items(CinemaCatalog.showtimeCategory).where((item) {
        final parts = item.detail.split('|');
        return item.name == widget.movieTitle &&
            parts.length == 3 &&
            parts[1] ==
                '${selectedDate.year.toString().padLeft(4, '0')}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}';
      }).toList();
  List<AdminItem> get availableShowtimes {
    final dateKey =
        '${selectedDate.year.toString().padLeft(4, '0')}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}';
    final custom = configuredShowtimes;
    final legacy = <AdminItem>[
      for (var branchIndex = 0; branchIndex < _branches.length; branchIndex++)
        for (final legacyTime in const ['11:00', '14:00', '17:20', '20:00'])
          if (!custom.any(
            (show) =>
                show.detail == '${_branches[branchIndex]}|$dateKey|$legacyTime',
          ))
            AdminItem(
              id: 'legacy:$branchIndex:$legacyTime',
              name: widget.movieTitle,
              detail: '${_branches[branchIndex]}|$dateKey|$legacyTime',
              price: 160,
            ),
    ];
    return [...legacy, ...custom];
  }

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

  bool get loggedIn =>
      widget.isLoggedIn?.call() ?? FirebaseAuth.instance.currentUser != null;

  Future<bool> ensureLoggedIn() async {
    if (loggedIn) return true;
    final goLogin = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('กรุณาเข้าสู่ระบบ'),
        content: const Text('คุณต้องเข้าสู่ระบบก่อนจึงจะจองตั๋วได้'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('ยกเลิก'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('เข้าสู่ระบบ'),
          ),
        ],
      ),
    );
    if (goLogin != true || !mounted) return false;
    await Navigator.push(
      context,
      MaterialPageRoute<void>(builder: (_) => const LoginPage()),
    );
    return mounted && loggedIn;
  }

  void message(String text) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  Future<void> completePurchase() async {
    if (savingPurchase || !await ensureLoggedIn()) return;
    if (seats.isEmpty) {
      message('Please select at least one seat.');
      return;
    }
    setState(() => savingPurchase = true);
    try {
      final now = DateTime.now();
      final random = Random.secure();
      final referenceCode =
          'RCX-${now.millisecondsSinceEpoch}-${random.nextInt(1 << 20).toRadixString(16).toUpperCase()}';
      final qrPayload =
          'REVERIE|$referenceCode|${random.nextInt(0xFFFFFFFF).toRadixString(16).toUpperCase()}';
      final booking = BookingModel(
        id: '',
        movie: widget.movieTitle,
        cinema: selectedCinema,
        date: date,
        time: time,
        seats: List.unmodifiable(seats.toList()..sort()),
        total: total,
        status: 'paid',
        food: [
          for (final entry in quantities.entries)
            if (entry.value > 0 && foodById(entry.key) != null)
              '${foodById(entry.key)!.name} x ${entry.value}',
        ],
        referenceCode: referenceCode,
        qrPayload: qrPayload,
        isPaid: true,
        phone: phone.text.trim(),
        email: email.text.trim(),
      );
      final purchased = await ticketService.savePurchase(booking);
      if (!mounted) return;
      timer?.cancel();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('ซื้อตั๋วเรียบร้อยแล้ว')));
      await Navigator.of(context).pushAndRemoveUntil<void>(
        MaterialPageRoute<void>(builder: (_) => TicketPage(booking: purchased)),
        (route) => route.isFirst,
      );
    } catch (error) {
      if (mounted) message('Could not save ticket: $error');
    } finally {
      if (mounted) setState(() => savingPurchase = false);
    }
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
                      onPressed: savingPurchase || (step == 1 && seats.isEmpty)
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
                              } else if (step == 5) {
                                completePurchase();
                              }
                            },
                      child: Text(
                        step == 5
                            ? 'ชำระเงินเรียบร้อย'
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

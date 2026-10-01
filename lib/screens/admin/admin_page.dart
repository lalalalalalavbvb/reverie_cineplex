import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/booking_model.dart';
import '../../widgets/food_image.dart';
import '../../services/booking_service.dart';
import '../../models/movie_model.dart';
import '../booking/ticket_page.dart';

const adminBranches = [
  'เมเจอร์ โลตัส กำแพงแสน',
  'เมเจอร์ โลตัส นครปฐม',
  'เมเจอร์ เซ็นทรัล นครปฐม',
];
const _adminThaiMonths = [
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
const _defaultShowtimePrice = 160;

String _two(int n) => n.toString().padLeft(2, '0');
String _dateKey(DateTime d) => '${d.year}-${_two(d.month)}-${_two(d.day)}';
String _thaiDate(DateTime d) =>
    '${d.day} ${_adminThaiMonths[d.month - 1]} ${d.year + 543}';

String _orDash(String value) => value.trim().isEmpty ? '-' : value.trim();

String formatShowtimeDetail(String detail) {
  final parts = detail.split('|');
  if (parts.length != 3) return detail;
  final date = DateTime.tryParse(parts[1]);
  return '${parts[0]} • ${date == null ? parts[1] : _thaiDate(date)} • ${parts[2]}';
}

class AdminPage extends StatefulWidget {
  const AdminPage({super.key, required this.service});
  final BookingService service;
  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  int tab = 0;
  String query = '';
  bool busy = false;
  late final Future<List<MovieModel>> moviesFuture = CinemaCatalog.loadMovies();
  static const categories = ['รอบฉาย', 'อาหาร', 'รายการจอง'];
  String get selectedCategory =>
      tab == 0 ? CinemaCatalog.showtimeCategory : categories[tab];
  Future<void> mutate(Future<void> Function() action) async {
    setState(() => busy = true);
    try {
      await action();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('บันทึกไม่สำเร็จ กรุณาลองอีกครั้ง')),
        );
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> edit([AdminItem? item]) async {
    if (tab == 0) return editShowtime(item);
    final result = await showDialog<AdminItem>(
      context: context,
      builder: (_) => _FoodDialog(item: item),
    );
    if (result != null && mounted) {
      await mutate(
        () => widget.service.saveItem(CinemaCatalog.foodCategory, result),
      );
    }
  }

  Future<void> editShowtime([AdminItem? item]) async {
    final movies = await moviesFuture;
    if (!mounted) return;
    final result = await showDialog<AdminItem>(
      context: context,
      builder: (_) => _ShowtimeDialog(movies: movies, item: item),
    );
    if (result != null && mounted) {
      await mutate(
        () => widget.service.saveItem(CinemaCatalog.showtimeCategory, result),
      );
    }
  }

  Future<void> remove(AdminItem item) async {
    final category = selectedCategory;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ลบรายการนี้?'),
        content: Text(item.name),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('ยกเลิก'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('ลบ'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await mutate(() => widget.service.deleteItem(category, item.id));
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('ผู้ดูแลระบบ')),
    body: ListenableBuilder(
      listenable: widget.service,
      builder: (context, _) {
        final items = widget.service
            .items(selectedCategory)
            .where((e) => '${e.name} ${e.detail}'.contains(query))
            .toList();
        final bookings = widget.service.bookings
            .where(
              (e) =>
                  '${e.referenceCode} ${e.movie} ${e.cinema} ${e.phone} ${e.email} '
                          '${widget.service.buyerOf(e.id)} ${widget.service.buyerEmailOf(e.id)}'
                      .toLowerCase()
                      .contains(query.toLowerCase()),
            )
            .toList();
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 960),
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const Text(
                  'จัดการโรงภาพยนตร์',
                  style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'ข้อมูลบันทึกใน Firebase และอัปเดตแบบเรียลไทม์',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 24),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    for (int i = 0; i < categories.length; i++)
                      ChoiceChip(
                        label: Text(categories[i]),
                        selected: tab == i,
                        onSelected: busy
                            ? null
                            : (_) => setState(() {
                                tab = i;
                                query = '';
                              }),
                      ),
                  ],
                ),
                const SizedBox(height: 20),
                TextField(
                  key: ValueKey(tab),
                  onChanged: (v) => setState(() => query = v),
                  decoration: const InputDecoration(
                    hintText: 'ค้นหา',
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
                const SizedBox(height: 16),
                if (busy) const LinearProgressIndicator(),
                if (tab < 2) ...[
                  Align(
                    alignment: Alignment.centerRight,
                    child: FilledButton.icon(
                      onPressed: busy ? null : () => edit(),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(140, 44),
                      ),
                      icon: const Icon(Icons.add),
                      label: Text('เพิ่ม${categories[tab]}'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (items.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(32),
                      child: Center(child: Text('ไม่พบรายการ')),
                    ),
                  for (final item in items)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (tab == 1) ...[
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: SizedBox(
                                  width: 80,
                                  height: 80,
                                  child: FoodImage(base64: item.image),
                                ),
                              ),
                              const SizedBox(width: 14),
                            ],
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.name,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    tab == 0
                                        ? formatShowtimeDetail(item.detail)
                                        : item.detail,
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          '${item.price} บาท',
                                          style: const TextStyle(
                                            color: Color(0xFFEFBA3C),
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        tooltip: 'แก้ไข',
                                        onPressed: busy
                                            ? null
                                            : () => edit(item),
                                        icon: const Icon(Icons.edit_outlined),
                                      ),
                                      IconButton(
                                        tooltip: 'ลบ',
                                        onPressed: busy
                                            ? null
                                            : () => remove(item),
                                        icon: const Icon(Icons.delete_outline),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ] else ...[
                  if (bookings.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(32),
                      child: Center(child: Text('ไม่พบรายการจอง')),
                    ),
                  if (bookings.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        'ทั้งหมด ${bookings.length} รายการ • '
                        'ยอดขายรวม ${bookings.fold<int>(0, (sum, b) => sum + b.total)} บาท',
                        style: const TextStyle(color: Color(0xFFEFBA3C)),
                      ),
                    ),
                  for (final booking in bookings)
                    Card(
                      child: ListTile(
                        isThreeLine: true,
                        title: Text(booking.movie),
                        subtitle: Text(
                          [
                            'ผู้ซื้อ: ${_orDash(widget.service.buyerOf(booking.id))}',
                            'อีเมล: ${_orDash(booking.email.isNotEmpty ? booking.email : widget.service.buyerEmailOf(booking.id))}',
                            'เบอร์โทร: ${_orDash(booking.phone)}',
                            '${booking.cinema} • ${booking.date} · ${booking.time}',
                            '${booking.seats.join(', ')} • ${booking.total} บาท',
                            if (booking.referenceCode.isNotEmpty)
                              'อ้างอิง: ${booking.referenceCode}',
                          ].join('\n'),
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute<void>(
                            builder: (_) => TicketPage(booking: booking),
                          ),
                        ),
                      ),
                    ),
                ],
              ],
            ),
          ),
        );
      },
    ),
  );
}

class _ShowtimeDialog extends StatefulWidget {
  const _ShowtimeDialog({required this.movies, this.item});
  final List<MovieModel> movies;
  final AdminItem? item;

  @override
  State<_ShowtimeDialog> createState() => _ShowtimeDialogState();
}

class _ShowtimeDialogState extends State<_ShowtimeDialog> {
  MovieModel? movie;
  late String branch;
  late DateTime date;
  late TimeOfDay time;

  @override
  void initState() {
    super.initState();
    final item = widget.item;
    final parts = item?.detail.split('|') ?? const <String>[];

    final id = item == null ? null : int.tryParse(item.id.split(':').first);
    for (final m in widget.movies) {
      if (m.id == id) movie = m;
    }
    movie ??= widget.movies.isEmpty ? null : widget.movies.first;

    branch = parts.isNotEmpty && adminBranches.contains(parts[0])
        ? parts[0]
        : adminBranches.first;

    final now = DateTime.now();
    final parsedDate = parts.length > 1 ? DateTime.tryParse(parts[1]) : null;
    date = parsedDate ?? DateTime(now.year, now.month, now.day);

    final timeParts = parts.length > 2 ? parts[2].split(':') : const <String>[];
    time = timeParts.length == 2
        ? TimeOfDay(
            hour: int.tryParse(timeParts[0]) ?? 14,
            minute: int.tryParse(timeParts[1]) ?? 0,
          )
        : const TimeOfDay(hour: 14, minute: 0);
  }

  String get timeText => '${_two(time.hour)}:${_two(time.minute)}';

  Future<void> pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null && mounted) setState(() => date = picked);
  }

  Future<void> pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: time,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    );
    if (picked != null && mounted) setState(() => time = picked);
  }

  void save() {
    final selected = movie;
    if (selected == null) return;
    Navigator.pop(
      context,
      AdminItem(
        id:
            widget.item?.id ??
            '${selected.id}:${DateTime.now().microsecondsSinceEpoch}',
        name: selected.title,
        detail: '$branch|${_dateKey(date)}|$timeText',
        price: widget.item?.price ?? _defaultShowtimePrice,
      ),
    );
  }

  Widget pickerField({
    required String label,
    required String value,
    required IconData icon,
    required VoidCallback onTap,
  }) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(10),
    child: InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: Icon(icon),
      ),
      child: Text(value),
    ),
  );

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(widget.item == null ? 'เพิ่มรอบฉาย' : 'แก้ไขรอบฉาย'),
    content: SizedBox(
      width: 420,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<MovieModel>(
              initialValue: movie,
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'ภาพยนตร์'),
              items: [
                for (final m in widget.movies)
                  DropdownMenuItem(
                    value: m,
                    child: Text(m.title, overflow: TextOverflow.ellipsis),
                  ),
              ],
              onChanged: (m) => setState(() => movie = m),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: branch,
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'สาขา'),
              items: [
                for (final b in adminBranches)
                  DropdownMenuItem(
                    value: b,
                    child: Text(b, overflow: TextOverflow.ellipsis),
                  ),
              ],
              onChanged: (b) {
                if (b != null) setState(() => branch = b);
              },
            ),
            const SizedBox(height: 12),
            pickerField(
              label: 'วันที่',
              value: _thaiDate(date),
              icon: Icons.calendar_today,
              onTap: pickDate,
            ),
            const SizedBox(height: 12),
            pickerField(
              label: 'เวลา',
              value: '$timeText น.',
              icon: Icons.access_time,
              onTap: pickTime,
            ),
          ],
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('ยกเลิก'),
      ),
      FilledButton(
        onPressed: movie == null ? null : save,
        style: FilledButton.styleFrom(minimumSize: const Size(88, 44)),
        child: const Text('บันทึก'),
      ),
    ],
  );
}

class _FoodDialog extends StatefulWidget {
  const _FoodDialog({this.item});
  final AdminItem? item;

  @override
  State<_FoodDialog> createState() => _FoodDialogState();
}

class _FoodDialogState extends State<_FoodDialog> {
  static const _maxImageLength = 900000;

  final form = GlobalKey<FormState>();
  late final TextEditingController name;
  late final TextEditingController detail;
  late final TextEditingController price;
  String image = '';
  String? imageError;
  bool picking = false;

  @override
  void initState() {
    super.initState();
    final item = widget.item;
    name = TextEditingController(text: item?.name ?? '');
    detail = TextEditingController(text: item?.detail ?? '');
    price = TextEditingController(text: item == null ? '' : '${item.price}');
    image = item?.image ?? '';
  }

  @override
  void dispose() {
    name.dispose();
    detail.dispose();
    price.dispose();
    super.dispose();
  }

  Future<void> pickImage() async {
    setState(() {
      picking = true;
      imageError = null;
    });
    try {
      final picked = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 600,
        maxHeight: 600,
        imageQuality: 75,
      );
      if (picked == null) return;
      final encoded = base64Encode(await picked.readAsBytes());
      if (!mounted) return;
      if (encoded.length > _maxImageLength) {
        setState(() => imageError = 'รูปใหญ่เกินไป กรุณาเลือกรูปที่เล็กกว่านี้');
        return;
      }
      setState(() => image = encoded);
    } catch (_) {
      if (mounted) setState(() => imageError = 'เลือกรูปไม่สำเร็จ');
    } finally {
      if (mounted) setState(() => picking = false);
    }
  }

  void save() {
    if (!form.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    Navigator.pop(
      context,
      AdminItem(
        id: widget.item?.id ?? 'food-${DateTime.now().microsecondsSinceEpoch}',
        name: name.text.trim(),
        detail: detail.text.trim(),
        price: int.parse(price.text.trim()),
        image: image,
      ),
    );
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(widget.item == null ? 'เพิ่มอาหาร' : 'แก้ไขอาหาร'),
    content: SizedBox(
      width: 420,
      child: Form(
        key: form,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: InkWell(
                  onTap: picking ? null : pickImage,
                  borderRadius: BorderRadius.circular(12),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      width: 160,
                      height: 160,
                      child: picking
                          ? const Center(child: CircularProgressIndicator())
                          : image.isEmpty
                          ? Container(
                              color: Colors.white10,
                              alignment: Alignment.center,
                              child: const Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.add_photo_alternate_outlined,
                                      size: 40),
                                  SizedBox(height: 6),
                                  Text('แตะเพื่อเลือกรูป'),
                                ],
                              ),
                            )
                          : FoodImage(base64: image),
                    ),
                  ),
                ),
              ),
              if (image.isNotEmpty)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton.icon(
                      onPressed: picking ? null : pickImage,
                      icon: const Icon(Icons.photo_library_outlined),
                      label: const Text('เปลี่ยนรูป'),
                    ),
                    TextButton.icon(
                      onPressed: picking
                          ? null
                          : () => setState(() => image = ''),
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('ลบรูป'),
                    ),
                  ],
                ),
              if (imageError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    imageError!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.redAccent),
                  ),
                ),
              const SizedBox(height: 12),
              TextFormField(
                controller: name,
                decoration: const InputDecoration(labelText: 'ชื่ออาหาร'),
                validator: (v) => (v ?? '').trim().isEmpty
                    ? 'กรุณากรอกชื่ออาหาร'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: detail,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'รายละเอียด (ไม่บังคับ)',
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: price,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'ราคา (บาท)'),
                validator: (v) => (int.tryParse(v?.trim() ?? '') ?? 0) > 0
                    ? null
                    : 'กรอกราคาเป็นจำนวนเต็มมากกว่า 0',
              ),
            ],
          ),
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('ยกเลิก'),
      ),
      FilledButton(
        onPressed: picking ? null : save,
        style: FilledButton.styleFrom(minimumSize: const Size(88, 44)),
        child: const Text('บันทึก'),
      ),
    ],
  );
}
import 'package:flutter/material.dart';
import '../../models/booking_model.dart';
import '../../services/booking_service.dart';
import '../booking/ticket_page.dart';

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
  static const categories = ['รอบฉาย', 'อาหาร', 'รายการจอง'];
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
    final category = categories[tab];
    final name = TextEditingController(text: item?.name);
    final detail = TextEditingController(text: item?.detail);
    final price = TextEditingController(text: item?.price.toString());
    final form = GlobalKey<FormState>();
    final result = await showDialog<AdminItem>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${item == null ? 'เพิ่ม' : 'แก้ไข'}$category'),
        content: SizedBox(
          width: 400,
          child: Form(
            key: form,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: name,
                    decoration: InputDecoration(
                      labelText: category == 'รอบฉาย'
                          ? 'ชื่อภาพยนตร์'
                          : 'ชื่ออาหาร',
                    ),
                    validator: requiredText,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: detail,
                    decoration: InputDecoration(
                      labelText: category == 'รอบฉาย'
                          ? 'โรง / วันที่ / เวลา'
                          : 'รายละเอียด',
                    ),
                    validator: requiredText,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: price,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'ราคา (บาท)'),
                    validator: (v) => (int.tryParse(v ?? '') ?? 0) > 0
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
            onPressed: () {
              if (form.currentState!.validate()) {
                Navigator.pop(
                  context,
                  AdminItem(
                    id:
                        item?.id ??
                        DateTime.now().microsecondsSinceEpoch.toString(),
                    name: name.text.trim(),
                    detail: detail.text.trim(),
                    price: int.parse(price.text),
                  ),
                );
              }
            },
            style: FilledButton.styleFrom(minimumSize: const Size(88, 44)),
            child: const Text('บันทึก'),
          ),
        ],
      ),
    );
    // Dispose after the closing dialog has left the widget tree.
    await Future<void>.delayed(const Duration(milliseconds: 300));
    name.dispose();
    detail.dispose();
    price.dispose();
    if (result != null && mounted) {
      await mutate(() => widget.service.saveItem(category, result));
    }
  }

  String? requiredText(String? value) =>
      value == null || value.trim().isEmpty ? 'กรุณากรอกข้อมูล' : null;
  Future<void> remove(AdminItem item) async {
    final category = categories[tab];
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
            .items(categories[tab])
            .where((e) => '${e.name} ${e.detail}'.contains(query))
            .toList();
        final bookings = widget.service.bookings
            .where((e) => '${e.id} ${e.movie}'.contains(query))
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
                  'โหมดตัวอย่าง • ข้อมูลในหน้านี้เก็บชั่วคราว และยังไม่เชื่อมหน้าจอง',
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
                            Text(item.detail),
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
                                  onPressed: busy ? null : () => edit(item),
                                  icon: const Icon(Icons.edit_outlined),
                                ),
                                IconButton(
                                  tooltip: 'ลบ',
                                  onPressed: busy ? null : () => remove(item),
                                  icon: const Icon(Icons.delete_outline),
                                ),
                              ],
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
                  for (final booking in bookings)
                    Card(
                      child: ListTile(
                        isThreeLine: true,
                        title: Text(booking.movie),
                        subtitle: Text(
                          '${booking.id} • ${booking.status}\n${booking.seats.join(', ')} • ${booking.total} บาท',
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

import 'package:flutter/material.dart';
import '../models/booking_model.dart';
import '../services/booking_service.dart';
import '../widgets/bottom_nav.dart';
import 'admin/admin_page.dart';
import 'booking/booking_flow.dart';
import 'booking/ticket_page.dart';
import 'home/home_page.dart';
import 'profile/profile_page.dart';
import 'profile/about_page.dart';

/// Shared navigation for person 1's browsing pages and person 2's booking UI.
class AppShell extends StatefulWidget {
  const AppShell({
    super.key,
    required this.isDarkMode,
    required this.onThemeChanged,
  });
  final bool isDarkMode;
  final ValueChanged<bool> onThemeChanged;
  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int index = 0;
  final service = DemoBookingService();
  final previews = <BookingModel>[];
  void savePreview(BookingModel booking) => setState(() {
    previews.removeWhere((e) => e.id == booking.id);
    previews.add(booking);
  });
  void openAdmin() => Navigator.push(
    context,
    MaterialPageRoute<void>(
      builder: (_) => Theme(
        data: bookingTheme(),
        child: AdminPage(service: service),
      ),
    ),
  );

  void openAbout() => Navigator.push(
    context,
    MaterialPageRoute<void>(builder: (_) => const AboutPage()),
  );

  Future<void> logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ออกจากระบบ?'),
        content: const Text(
          'ข้อมูลตั๋วตัวอย่างในเครื่องจะถูกล้าง ระบบ Login จริงจะเชื่อมโดยฝ่าย Backend ภายหลัง',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('ยกเลิก'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('ออกจากระบบ'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() {
      previews.clear();
      index = 0;
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('ออกจากระบบตัวอย่างแล้ว')));
  }

  @override
  void dispose() {
    service.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: IndexedStack(
      index: index,
      children: [
        HomePage(embedded: true, onTicketPreview: savePreview),
        Scaffold(
          appBar: AppBar(title: const Text('ตั๋วของฉัน')),
          body: previews.isEmpty
              ? const Center(
                  child: Text(
                    'ยังไม่มีตั๋ว\nเลือกภาพยนตร์จากหน้าหลักเพื่อเริ่มจอง',
                    textAlign: TextAlign.center,
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    const Text('ตั๋วตัวอย่าง • ยังไม่ได้ชำระเงินจริง'),
                    for (final booking in previews)
                      Card(
                        child: ListTile(
                          title: Text(booking.movie),
                          subtitle: Text(
                            '${booking.date} • ${booking.time}\n${booking.seats.join(', ')} • ${booking.total} บาท',
                          ),
                          isThreeLine: true,
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute<void>(
                              builder: (_) => Theme(
                                data: bookingTheme(),
                                child: TicketPage(booking: booking),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
        ),
        ProfilePage(
          embedded: true,
          onTickets: () => setState(() => index = 1),
          onAdmin: openAdmin,
          isDarkMode: widget.isDarkMode,
          onThemeChanged: widget.onThemeChanged,
          onAbout: openAbout,
          onLogout: logout,
        ),
      ],
    ),
    bottomNavigationBar: AppBottomNav(
      currentIndex: index,
      onTap: (value) => setState(() => index = value),
    ),
  );
}

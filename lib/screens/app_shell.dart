import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/booking_model.dart';
import '../services/booking_service.dart';
import '../services/auth_service.dart';
import '../services/ticket_service.dart';
import '../widgets/bottom_nav.dart';
import 'admin/admin_page.dart';
import 'auth/login_page.dart';
import 'auth/register_page.dart';
import 'booking/booking_flow.dart';
import 'booking/ticket_page.dart';
import 'home/home_page.dart';
import 'profile/profile_page.dart';
import 'profile/about_page.dart';

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
  bool isAdmin = false;
  final service = CinemaCatalog.service;
  final authService = AuthService();
  final ticketService = TicketService();

  StreamSubscription<User?>? _authSubscription;

  @override
  void initState() {
    super.initState();
    _authSubscription = authService.authStateChanges().listen(_onAuthChanged);
  }

  Future<void> _onAuthChanged(User? user) async {
    if (!mounted) return;
    setState(() {
      if (user == null) isAdmin = false;
    });
    if (user == null) return;
    await authService.syncDisplayNameFromFirestore();
    await _refreshAdminRole();
  }

  Future<void> _refreshAdminRole() async {
    final roleIsAdmin = await authService.isAdmin();
    if (!mounted) return;
    setState(() => isAdmin = roleIsAdmin);
  }

  Future<void> openAdmin() async {
    if (!await authService.isAdmin()) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Admin access required')),
      );
      await _refreshAdminRole();
      return;
    }
    if (!mounted) return;
    await Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (_) => Theme(
          data: bookingTheme(),
          child: AdminPage(service: service),
        ),
      ),
    );
  }

  void openAbout() => Navigator.push(
    context,
    MaterialPageRoute<void>(builder: (_) => const AboutPage()),
  );

  Future<void> logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign out?'),
        content: const Text('Do you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sign out'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    try {
      await authService.logout();
      if (!mounted) return;
      setState(() {
        index = 0;
        isAdmin = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Signed out')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not sign out: $error')),
      );
    }
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    service.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: IndexedStack(
      index: index,
      children: [
        HomePage(embedded: true),
        Scaffold(
          appBar: AppBar(title: const Text('ประวัติการซื้อตั๋ว')),
          body: StreamBuilder<List<BookingModel>>(
            stream: ticketService.watchMyTickets(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('โหลดประวัติตั๋วไม่สำเร็จ: ${snapshot.error}'));
              }
              final tickets = snapshot.data ?? const <BookingModel>[];
              if (tickets.isEmpty) {
                return const Center(
                  child: Text('ยังไม่มีประวัติการซื้อตั๋ว'),
                );
              }
              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  for (final booking in tickets)
                    Card(
                      child: ListTile(
                        title: Text(booking.movie),
                        subtitle: Text(
                          '${booking.date} · ${booking.time}\n${booking.seats.join(', ')} · ${booking.total} บาท',
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
              );
            },
          ),
        ),
        ProfilePage(
          embedded: true,
          onTickets: () => setState(() => index = 1),
          onAdmin: isAdmin ? openAdmin : null,
          isDarkMode: widget.isDarkMode,
          onThemeChanged: widget.onThemeChanged,
          onAbout: openAbout,
          onLogout: logout,
          onLogin: () async {
            await Navigator.push<void>(
              context,
              MaterialPageRoute<void>(builder: (_) => const LoginPage()),
            );
            await _refreshAdminRole();
          },
          onRegister: () async {
            await Navigator.push<void>(
              context,
              MaterialPageRoute<void>(builder: (_) => const RegisterPage()),
            );
            await _refreshAdminRole();
          },
        ),
      ],
    ),
    bottomNavigationBar: AppBottomNav(
      currentIndex: index,
      onTap: (value) => setState(() => index = value),
    ),
  );
}
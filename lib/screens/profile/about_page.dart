import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('เกี่ยวกับทีมผู้พัฒนา')),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Icon(Icons.movie_filter_rounded, size: 72),
        const SizedBox(height: 12),
        Text(
          'Reverie Cineplex',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        const Text(
          'แอปจองตั๋วภาพยนตร์ที่พัฒนาด้วย Flutter สำหรับโครงงานนักศึกษา',
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 28),
        const _MemberCard(
          icon: Icons.palette_outlined,
          title: 'คนที่ 1 • UX/UI และข้อมูลภาพยนตร์',
          detail: '671652021 จรรยวรรธน์ ตั้งเพิ่มพูน\nHome, รายการหนัง, รายละเอียดหนัง, โปรโมชัน และ Profile',
        ),
        const _MemberCard(
          icon: Icons.confirmation_number_outlined,
          title: 'คนที่ 2 • Booking และ Admin Frontend',
          detail: '6721652714 สมิตานันท์ ชัยธนากิจเจริญ\nเลือกรอบ ที่นั่ง อาหาร สรุปการจอง Payment UI ตั๋ว และ Admin',
        ),
        const _MemberCard(
          icon: Icons.storage_outlined,
          title: 'คนที่ 3 • Backend และ Database',
          detail: '6721652838 อภิสิทธิ์ ทัศนวงค์วรา\nAPI, Login/Auth, CRUD, ระบบ Booking และระบบ Backend',
        ),
        const SizedBox(height: 20),
        const Text(
          'ข้อมูลภาพยนตร์และรูปภาพมาจาก TMDB ผลิตภัณฑ์นี้ไม่ได้รับการรับรองหรือรับรองโดย TMDB',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey),
        ),
      ],
    ),
  );
}

class _MemberCard extends StatelessWidget {
  const _MemberCard({
    required this.icon,
    required this.title,
    required this.detail,
  });
  final IconData icon;
  final String title, detail;

  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      contentPadding: const EdgeInsets.all(16),
      leading: Icon(icon, size: 32),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Text(detail),
      ),
    ),
  );
}

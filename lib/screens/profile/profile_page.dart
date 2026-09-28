import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../widgets/bottom_nav.dart';

/// ⚠️ หน้านี้ยังไม่มีในโครงสร้างโฟลเดอร์เดิม (screens/ มีแค่ admin, booking, home, movie)
/// ให้เพิ่มโฟลเดอร์ screens/profile/ นี้เข้าไปในโปรเจกต์จริงด้วย
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Row(
              children: [
                const CircleAvatar(
                  radius: 28,
                  backgroundColor: AppColors.primary,
                  child: Text('ม', style: TextStyle(color: Colors.white, fontSize: 20)),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('เม่ย ใจดี',
                        style: TextStyle(
                            color: AppColors.textMain,
                            fontSize: 17,
                            fontWeight: FontWeight.w600)),
                    Text('mei@example.com',
                        style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            _menuTile(context, Icons.confirmation_number_outlined, 'ตั๋วของฉัน', () {}),
            _menuTile(context, Icons.history_rounded, 'ประวัติการจอง', () {}),
            _menuTile(context, Icons.dark_mode_outlined, 'ธีมสว่าง/มืด', () {}),
            _menuTile(context, Icons.groups_rounded, 'เกี่ยวกับทีมผู้พัฒนา (About Us)', () {
              // TODO: ไปหน้า About Us — แสดงข้อมูลสมาชิกกลุ่มตามที่โจทย์กำหนด
            }),
            const SizedBox(height: 12),
            _menuTile(context, Icons.logout_rounded, 'ออกจากระบบ', () {}, danger: true),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNav(currentIndex: 2, onTap: (_) {}),
    );
  }

  Widget _menuTile(BuildContext context, IconData icon, String label,
      VoidCallback onTap, {bool danger = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: AppColors.surface1,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Icon(icon, size: 20, color: danger ? AppColors.primary : AppColors.textMuted),
                const SizedBox(width: 14),
                Text(label,
                    style: TextStyle(
                        color: danger ? AppColors.primary : AppColors.textMain,
                        fontSize: 14)),
                const Spacer(),
                const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

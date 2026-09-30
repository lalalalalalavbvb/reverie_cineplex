import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../widgets/bottom_nav.dart';

/// ⚠️ หน้านี้ยังไม่มีในโครงสร้างโฟลเดอร์เดิม (screens/ มีแค่ admin, booking, home, movie)
/// ให้เพิ่มโฟลเดอร์ screens/profile/ นี้เข้าไปในโปรเจกต์จริงด้วย
class ProfilePage extends StatelessWidget {
  const ProfilePage({
    super.key,
    this.embedded = false,
    this.onTickets,
    this.onAdmin,
    required this.isDarkMode,
    required this.onThemeChanged,
    required this.onAbout,
    required this.onLogout,
  });
  final bool embedded;
  final VoidCallback? onTickets, onAdmin;
  final bool isDarkMode;
  final ValueChanged<bool> onThemeChanged;
  final VoidCallback onAbout, onLogout;

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
                  child: Text(
                    'ม',
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'เม่ย ใจดี',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'mei@example.com',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (onAdmin != null)
              _menuTile(
                context,
                Icons.admin_panel_settings_outlined,
                'แอดมิน (ตัวอย่าง)',
                onAdmin!,
              ),
            _menuTile(
              context,
              Icons.confirmation_number_outlined,
              'ตั๋วของฉัน',
              onTickets ?? () {},
            ),
            _menuTile(
              context,
              Icons.history_rounded,
              'ประวัติการจอง',
              onTickets ?? () {},
            ),
            _themeTile(context),
            _menuTile(
              context,
              Icons.groups_rounded,
              'เกี่ยวกับทีมผู้พัฒนา (About Us)',
              onAbout,
            ),
            const SizedBox(height: 12),
            _menuTile(
              context,
              Icons.logout_rounded,
              'ออกจากระบบ',
              onLogout,
              danger: true,
            ),
          ],
        ),
      ),
      bottomNavigationBar: embedded
          ? null
          : AppBottomNav(currentIndex: 2, onTap: (_) {}),
    );
  }

  Widget _themeTile(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: colors.surfaceContainer,
        borderRadius: BorderRadius.circular(14),
        child: SwitchListTile(
          value: isDarkMode,
          onChanged: onThemeChanged,
          secondary: Icon(
            isDarkMode ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
          ),
          title: Text(isDarkMode ? 'ธีมมืด' : 'ธีมสว่าง'),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }

  Widget _menuTile(
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback onTap, {
    bool danger = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: danger
                      ? AppColors.primary
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: danger
                          ? AppColors.primary
                          : Theme.of(context).colorScheme.onSurface,
                      fontSize: 14,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

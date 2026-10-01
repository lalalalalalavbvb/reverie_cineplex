import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../core/theme.dart';
import '../../widgets/bottom_nav.dart';

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
    required this.onLogin,
    required this.onRegister,
  });

  final bool embedded;

  final VoidCallback? onTickets;
  final VoidCallback? onAdmin;

  final bool isDarkMode;
  final ValueChanged<bool> onThemeChanged;

  final VoidCallback onAbout;
  final VoidCallback onLogout;

  final VoidCallback onLogin;
  final VoidCallback onRegister;

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    final bool isLoggedIn = user != null;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _buildProfileHeader(context, user),

            const SizedBox(height: 24),

            if (isLoggedIn) ...[
              if (onAdmin != null)
                _menuTile(
                  context,
                  Icons.admin_panel_settings_outlined,
                  'แอดมิน',
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
                Icons.delete_outline_rounded,
                'ลบบัญชี',
                () => _showDeleteAccountDialog(context),
                danger: true,
              ),

              _menuTile(
                context,
                Icons.logout_rounded,
                'ออกจากระบบ',
                onLogout,
                danger: true,
              ),
            ] else ...[
              _buildLoginMessage(context),

              const SizedBox(height: 16),

              _authButton(
                context,
                label: 'เข้าสู่ระบบ',
                icon: Icons.login_rounded,
                onTap: onLogin,
              ),

              const SizedBox(height: 10),

              _authButton(
                context,
                label: 'สมัครสมาชิก',
                icon: Icons.person_add_alt_1_rounded,
                onTap: onRegister,
                outlined: true,
              ),

              const SizedBox(height: 20),

              _themeTile(context),

              _menuTile(
                context,
                Icons.groups_rounded,
                'เกี่ยวกับทีมผู้พัฒนา (About Us)',
                onAbout,
              ),
            ],
          ],
        ),
      ),
      bottomNavigationBar: embedded
          ? null
          : AppBottomNav(currentIndex: 2, onTap: (_) {}),
    );
  }

  Future<void> _showDeleteAccountDialog(BuildContext context) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        final colors = Theme.of(dialogContext).colorScheme;

        return AlertDialog(
          title: const Text('ยืนยันการลบบัญชี'),
          content: const Text(
            'การลบบัญชีไม่สามารถย้อนกลับได้ '
            'ข้อมูลบัญชีของคุณจะถูกลบอย่างถาวร '
            'และคุณจะต้องสมัครสมาชิกใหม่หากต้องการใช้งานอีกครั้ง\n\n'
            'คุณต้องการลบบัญชีจริงหรือไม่?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: Text(
                'ยกเลิก',
                style: TextStyle(color: colors.onSurfaceVariant),
              ),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('ยืนยันการลบ'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    if (!context.mounted) {
      return;
    }

    await _deleteAccount(context);
  }

  Future<void> _deleteAccount(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return;
    }

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return const Center(child: CircularProgressIndicator());
      },
    );

    try {
      final String uid = user.uid;

      await FirebaseFirestore.instance.collection('users').doc(uid).delete();

      await user.delete();

      if (context.mounted) {
        Navigator.of(context).pop();
      }

      onLogout();
    } on FirebaseAuthException catch (e) {

      if (context.mounted) {
        Navigator.of(context).pop();
      }

      if (e.code == 'requires-recent-login') {
        if (!context.mounted) {
          return;
        }

        _showMessage(
          context,
          'เพื่อความปลอดภัย กรุณาออกจากระบบ '
          'แล้วเข้าสู่ระบบใหม่ก่อนลบบัญชี',
        );

        return;
      }

      if (!context.mounted) {
        return;
      }

      _showMessage(
        context,
        'ไม่สามารถลบบัญชีได้: '
        '${e.message ?? e.code}',
      );
    } on FirebaseException catch (e) {

      if (context.mounted) {
        Navigator.of(context).pop();
      }

      if (!context.mounted) {
        return;
      }

      _showMessage(
        context,
        'ไม่สามารถลบข้อมูลบัญชีได้: '
        '${e.message ?? e.code}',
      );
    } catch (e) {

      if (context.mounted) {
        Navigator.of(context).pop();
      }

      if (!context.mounted) {
        return;
      }

      _showMessage(context, 'เกิดข้อผิดพลาด: $e');
    }
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Widget _buildProfileHeader(BuildContext context, User? user) {
    final colors = Theme.of(context).colorScheme;

    if (user == null) {
      return Row(
        children: [
          const CircleAvatar(
            radius: 28,
            backgroundColor: AppColors.primary,
            child: Icon(
              Icons.person_outline_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ยังไม่ได้เข้าสู่ระบบ',
                  style: TextStyle(
                    color: colors.onSurface,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'เข้าสู่ระบบเพื่อใช้งานโปรไฟล์',
                  style: TextStyle(
                    color: colors.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    final String displayName = _getDisplayName(user);

    final String email = user.email ?? '';

    final String avatarText = displayName.isNotEmpty
        ? displayName.characters.first.toUpperCase()
        : 'U';

    return Row(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: AppColors.primary,
          child: Text(
            avatarText,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                displayName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: colors.onSurface,
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                email,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: colors.onSurfaceVariant, fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getDisplayName(User user) {
    final name = user.displayName?.trim();

    if (name != null && name.isNotEmpty) {
      return name;
    }

    final email = user.email?.trim();

    if (email != null && email.isNotEmpty) {
      final index = email.indexOf('@');

      if (index > 0) {
        return email.substring(0, index);
      }

      return email;
    }

    return 'ผู้ใช้งาน';
  }

  Widget _buildLoginMessage(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.surfaceContainer,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Icon(
            Icons.lock_outline_rounded,
            size: 34,
            color: colors.onSurfaceVariant,
          ),
          const SizedBox(height: 10),
          Text(
            'ยังไม่ได้เข้าสู่ระบบ',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: colors.onSurface,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'เข้าสู่ระบบหรือสมัครสมาชิกเพื่อใช้งานฟังก์ชันต่าง ๆ',
            textAlign: TextAlign.center,
            style: TextStyle(color: colors.onSurfaceVariant, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _authButton(
    BuildContext context, {
    required String label,
    required IconData icon,
    required VoidCallback onTap,
    bool outlined = false,
  }) {
    final colors = Theme.of(context).colorScheme;

    return SizedBox(
      width: double.infinity,
      height: 50,
      child: outlined
          ? OutlinedButton.icon(
              onPressed: onTap,
              icon: Icon(icon),
              label: Text(label),
              style: OutlinedButton.styleFrom(
                foregroundColor: colors.onSurface,
                side: BorderSide(color: colors.outline),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            )
          : FilledButton.icon(
              onPressed: onTap,
              icon: Icon(icon),
              label: Text(label),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
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
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: colors.surfaceContainer,
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
                  color: danger ? AppColors.primary : colors.onSurfaceVariant,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: danger ? AppColors.primary : colors.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: colors.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

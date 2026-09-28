import 'package:flutter/material.dart';
import '../core/theme.dart';

/// ปุ่มหลักที่ใช้ซ้ำทุกหน้า (จองตั๋ว, ต่อไป, ยืนยัน ฯลฯ)
class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final IconData? icon;

  const CustomButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: loading ? null : onPressed,
        child: loading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.4,
                  color: Colors.white,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 18),
                    const SizedBox(width: 8),
                  ],
                  Text(label),
                ],
              ),
      ),
    );
  }
}

/// ชิปกลมๆ ใช้กับ genre, สถานะ ฯลฯ
class AppChip extends StatelessWidget {
  final String label;
  final bool active;
  const AppChip({super.key, required this.label, this.active = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: active ? AppColors.primary : AppColors.surface2,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: active ? Colors.white : AppColors.textMuted,
          fontWeight: active ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
    );
  }
}

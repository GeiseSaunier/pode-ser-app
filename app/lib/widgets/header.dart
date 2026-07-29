import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme.dart';
import '../providers/auth_provider.dart';

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const AppHeader({super.key, required this.title});

  @override
  Size get preferredSize => const Size.fromHeight(84);

  @override
  Widget build(BuildContext context) {
    final credits = context.watch<AuthProvider>().user?.creditBalance ?? 0;

    return Container(
      color: AppColors.ink,
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
      child: SafeArea(
        bottom: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('PODE SER?', style: AppTheme.eyebrow()),
                const SizedBox(height: 2),
                Text(
                  title,
                  style: const TextStyle(color: AppColors.paper, fontSize: 22, fontWeight: FontWeight.w500),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: const Color(0xFF3A3729)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.swap_horiz, size: 15, color: AppColors.paper),
                  const SizedBox(width: 6),
                  Text('$credits créditos', style: const TextStyle(color: AppColors.paper, fontSize: 13)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

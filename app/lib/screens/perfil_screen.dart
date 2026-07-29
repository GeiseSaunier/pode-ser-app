import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../theme.dart';
import '../widgets/header.dart';

class PerfilScreen extends StatelessWidget {
  const PerfilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    if (user == null) return const SizedBox.shrink();

    final initials = user.name
        .trim()
        .split(RegExp(r'\s+'))
        .take(2)
        .map((p) => p.isNotEmpty ? p[0] : '')
        .join()
        .toUpperCase();

    return Scaffold(
      appBar: const AppHeader(title: 'Meu perfil'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AppCard(
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: AppColors.paper2,
                  child: Text(initials, style: const TextStyle(color: AppColors.ink, fontWeight: FontWeight.w600, fontSize: 18)),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user.name, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16)),
                    Row(
                      children: [
                        const Icon(Icons.star, size: 12, color: AppColors.gold),
                        const SizedBox(width: 4),
                        Text(user.ratingAvg.toStringAsFixed(1), style: const TextStyle(fontSize: 12, color: AppColors.gold)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (user.bio != null && user.bio!.isNotEmpty) ...[
            const SizedBox(height: 12),
            AppCard(child: Text(user.bio!, style: const TextStyle(fontSize: 13, color: AppColors.slate, height: 1.5))),
          ],
          const SizedBox(height: 12),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Ofereço', style: TextStyle(fontSize: 12, color: AppColors.slate)),
                const SizedBox(height: 6),
                _tagWrap(user.oferece.map((s) => s.title).toList(), AppColors.paper2),
                const SizedBox(height: 14),
                const Text('Quero trocar por', style: TextStyle(fontSize: 12, color: AppColors.slate)),
                const SizedBox(height: 6),
                _tagWrap(user.quer.map((s) => s.title).toList(), AppColors.mossBg),
              ],
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: () async {
              await context.read<AuthProvider>().logout();
              if (context.mounted) Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
            },
            child: const Text('Sair da conta'),
          ),
        ],
      ),
    );
  }

  Widget _tagWrap(List<String> tags, Color background) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: tags
          .map((t) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(6)),
                child: Text(t, style: const TextStyle(fontSize: 12, color: AppColors.ink)),
              ))
          .toList(),
    );
  }
}

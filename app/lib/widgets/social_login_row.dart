import 'package:flutter/material.dart';
import '../theme.dart';

class SocialLoginRow extends StatelessWidget {
  final void Function(String provider) onTap;

  const SocialLoginRow({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _SocialButton(label: 'Google', onTap: () => onTap('google'), leading: _googleG())),
        const SizedBox(width: 10),
        Expanded(
          child: _SocialButton(
            label: 'Facebook',
            onTap: () => onTap('facebook'),
            leading: const Icon(Icons.facebook, size: 16),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _SocialButton(
            label: 'Insta',
            onTap: () => onTap('instagram'),
            leading: const Icon(Icons.camera_alt_outlined, size: 15),
          ),
        ),
      ],
    );
  }

  Widget _googleG() {
    return Container(
      width: 15,
      height: 15,
      alignment: Alignment.center,
      decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AppColors.ink, width: 1.5)),
      child: const Text('G', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, height: 1)),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final String label;
  final Widget leading;
  final VoidCallback onTap;

  const _SocialButton({required this.label, required this.leading, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 10)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [leading, const SizedBox(width: 6), Text(label, style: const TextStyle(fontSize: 13))],
      ),
    );
  }
}

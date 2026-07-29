import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Paleta minimalista do "Pode ser?": neutros quentes + um único acento
/// (dourado antigo), igual ao protótipo web.
class AppColors {
  static const ink = Color(0xFF131211);
  static const paper = Color(0xFFF8F6F1);
  static const paper2 = Color(0xFFEEEBE2);
  static const card = Color(0xFFFFFFFF);
  static const moss = Color(0xFF46543C);
  static const mossBg = Color(0xFFE9EAE2);
  static const gold = Color(0xFF8B6F2E);
  static const goldBg = Color(0xFFF1EAD8);
  static const slate = Color(0xFF86816F);
  static const line = Color(0xFFE7E4DA);
  static const danger = Color(0xFF8B4A3A);
}

class AppTheme {
  static TextStyle get wordmark => GoogleFonts.instrumentSerif(
        fontStyle: FontStyle.italic,
        fontSize: 52,
        height: 1.0,
        color: AppColors.paper,
      );

  static TextStyle eyebrow({Color? color}) => GoogleFonts.inter(
        fontSize: 11,
        letterSpacing: 1.6,
        fontWeight: FontWeight.w500,
        color: color ?? const Color(0xFFA9A38C),
      );

  static ThemeData get theme {
    final base = ThemeData.light();
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.paper,
      textTheme: GoogleFonts.interTextTheme(base.textTheme).apply(
        bodyColor: AppColors.ink,
        displayColor: AppColors.ink,
      ),
      colorScheme: base.colorScheme.copyWith(
        primary: AppColors.ink,
        secondary: AppColors.gold,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.ink,
          foregroundColor: const Color(0xFFFAFAF6),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          textStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.ink,
          side: const BorderSide(color: AppColors.line),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          textStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.card,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.line),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.ink),
        ),
      ),
    );
  }
}

/// Card padrão usado em quase toda tela: fundo branco, borda fina, cantos de 12px.
class AppCard extends StatelessWidget {
  final Widget child;
  final Color? background;
  final EdgeInsetsGeometry padding;

  const AppCard({
    super.key,
    required this.child,
    this.background,
    this.padding = const EdgeInsets.all(18),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: background ?? AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.line),
      ),
      child: child,
    );
  }
}

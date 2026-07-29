import 'package:flutter/material.dart';
import '../theme.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ink,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.gold, width: 1.5),
                    ),
                    child: const Icon(Icons.repeat, color: AppColors.gold, size: 22),
                  ),
                  Text('SEM GRANA. SÓ TROCA.', style: AppTheme.eyebrow()),
                ],
              ),
              const Spacer(),
              Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      width: 280,
                      child: Text(
                        'Troque favores de consultoria por aulas de violão, edição de vídeo por pilates, tradução por design.',
                        style: TextStyle(fontSize: 14, color: Color(0xFFC7C4B6), height: 1.6),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text('Pode ser?', style: AppTheme.wordmark),
                  ],
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, '/signup'),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFAFAF6), foregroundColor: AppColors.ink),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [Text('Criar conta'), SizedBox(width: 8), Icon(Icons.arrow_forward, size: 16)],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pushNamed(context, '/login'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.paper,
                    side: const BorderSide(color: Color(0xFF3A3729)),
                  ),
                  child: const Text('Já tenho conta — entrar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

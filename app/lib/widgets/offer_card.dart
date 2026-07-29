import 'package:flutter/material.dart';
import '../models/skill.dart';
import '../theme.dart';

class OfferCard extends StatelessWidget {
  final Skill offer;
  final VoidCallback onPropose;

  const OfferCard({super.key, required this.offer, required this.onPropose});

  String get _initials {
    final parts = offer.userName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    return parts.take(2).map((p) => p[0]).join().toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: AppColors.paper2,
                    child: Text(_initials,
                        style: const TextStyle(color: AppColors.ink, fontWeight: FontWeight.w600, fontSize: 13)),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(offer.userName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                      Text(offer.title, style: const TextStyle(fontSize: 13, color: AppColors.slate)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.star, size: 12, color: AppColors.gold),
                          const SizedBox(width: 4),
                          Text(offer.userRating.toStringAsFixed(1),
                              style: const TextStyle(fontSize: 12, color: AppColors.gold)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              Row(
                children: [
                  Icon(offer.mode == 'PRESENCIAL' ? Icons.location_on_outlined : Icons.videocam_outlined,
                      size: 14, color: AppColors.slate),
                  const SizedBox(width: 4),
                  Text(offer.mode == 'PRESENCIAL' ? 'presencial' : 'remoto',
                      style: const TextStyle(fontSize: 12, color: AppColors.slate)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${offer.creditsPerHour} crédito / hora', style: const TextStyle(fontSize: 12, color: AppColors.slate)),
              ElevatedButton(
                onPressed: onPropose,
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10)),
                child: const Text('Propor troca'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

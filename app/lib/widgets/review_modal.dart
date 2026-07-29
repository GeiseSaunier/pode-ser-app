import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../theme.dart';

Future<void> showReviewModal(
  BuildContext context, {
  required AppTransaction transaction,
  required String currentUserId,
  required Future<void> Function(int rating, String? comment) onSubmit,
}) {
  final counterpart = transaction.requesterId == currentUserId
      ? transaction.providerName
      : transaction.requesterName;
  final commentController = TextEditingController();

  return showModalBottomSheet(
    context: context,
    backgroundColor: AppColors.paper,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (ctx) {
      int rating = 0;
      bool loading = false;
      return StatefulBuilder(
        builder: (ctx, setState) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: 20 + MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Avaliar troca', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                  IconButton(icon: const Icon(Icons.close, size: 18), onPressed: () => Navigator.pop(ctx)),
                ],
              ),
              const SizedBox(height: 4),
              Text('Como foi a troca de "${transaction.skillTitle}" com $counterpart?',
                  style: const TextStyle(fontSize: 13, color: AppColors.slate)),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (i) {
                  final star = i + 1;
                  return GestureDetector(
                    onTap: () => setState(() => rating = star),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Icon(
                        star <= rating ? Icons.star : Icons.star_border,
                        size: 36,
                        color: AppColors.gold,
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 16),
              const Text('Comentário (opcional)', style: TextStyle(fontSize: 12, color: AppColors.slate)),
              const SizedBox(height: 4),
              TextField(
                controller: commentController,
                maxLines: 3,
                decoration: const InputDecoration(hintText: 'Conte como foi a experiência...'),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: rating == 0 || loading
                      ? null
                      : () async {
                          setState(() => loading = true);
                          try {
                            final comment = commentController.text.trim().isEmpty
                                ? null
                                : commentController.text.trim();
                            await onSubmit(rating, comment);
                            if (ctx.mounted) Navigator.pop(ctx);
                          } catch (e) {
                            if (ctx.mounted) {
                              setState(() => loading = false);
                              ScaffoldMessenger.of(ctx)
                                  .showSnackBar(SnackBar(content: Text('$e')));
                            }
                          }
                        },
                  child: Text(loading ? 'Enviando...' : 'Enviar avaliação'),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

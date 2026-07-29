import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../theme.dart';

Future<void> showConfirmModal(
  BuildContext context, {
  required AppTransaction transaction,
  required String currentUserId,
  required Future<void> Function() onConfirm,
  required VoidCallback onDispute,
}) {
  final isRequester = transaction.requesterId == currentUserId;
  final youConfirmed = isRequester ? transaction.requesterConfirmedAt != null : transaction.providerConfirmedAt != null;
  final otherConfirmed = isRequester ? transaction.providerConfirmedAt != null : transaction.requesterConfirmedAt != null;
  final counterpart = isRequester ? transaction.providerName : transaction.requesterName;

  return showModalBottomSheet(
    context: context,
    backgroundColor: AppColors.paper,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (ctx) {
      bool loading = false;
      return StatefulBuilder(
        builder: (ctx, setState) => Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Confirmar troca', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                  IconButton(icon: const Icon(Icons.close, size: 18), onPressed: () => Navigator.pop(ctx)),
                ],
              ),
              const SizedBox(height: 8),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(transaction.skillTitle, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    Text('com $counterpart · ${transaction.creditsAgreed} crédito${transaction.creditsAgreed > 1 ? "s" : ""}',
                        style: const TextStyle(fontSize: 13, color: AppColors.slate)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _ConfirmRow(label: 'Você confirmou a entrega', done: youConfirmed),
              const SizedBox(height: 6),
              _ConfirmRow(label: '$counterpart confirmou a entrega', done: otherConfirmed),
              const SizedBox(height: 8),
              const Text('O crédito só é liberado quando as duas partes confirmarem.',
                  style: TextStyle(fontSize: 12, color: AppColors.slate)),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: youConfirmed || loading
                          ? null
                          : () async {
                              setState(() => loading = true);
                              try {
                                await onConfirm();
                                if (ctx.mounted) Navigator.pop(ctx);
                              } catch (e) {
                                if (ctx.mounted) {
                                  setState(() => loading = false);
                                  ScaffoldMessenger.of(ctx)
                                      .showSnackBar(SnackBar(content: Text('$e')));
                                }
                              }
                            },
                      child: Text(youConfirmed ? 'Você já confirmou' : (loading ? 'Confirmando...' : 'Confirmar conclusão')),
                    ),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      onDispute();
                    },
                    icon: const Icon(Icons.warning_amber_outlined, size: 16),
                    label: const Text('Disputa'),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}

class _ConfirmRow extends StatelessWidget {
  final String label;
  final bool done;

  const _ConfirmRow({required this.label, required this.done});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(done ? Icons.check_circle : Icons.circle_outlined, size: 18, color: done ? AppColors.moss : AppColors.slate),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 13)),
      ],
    );
  }
}

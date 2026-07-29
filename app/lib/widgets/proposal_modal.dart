import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../theme.dart';

Future<void> showProposalModal(
  BuildContext context, {
  required AppTransaction transaction,
  required Future<void> Function() onAccept,
  required Future<void> Function() onRefuse,
}) {
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
                  const Text('Proposta recebida', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                  IconButton(icon: const Icon(Icons.close, size: 18), onPressed: () => Navigator.pop(ctx)),
                ],
              ),
              const SizedBox(height: 12),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(transaction.skillTitle,
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    const SizedBox(height: 4),
                    Text(
                      '${transaction.requesterName} quer trocar com você · ${transaction.creditsAgreed} crédito${transaction.creditsAgreed > 1 ? "s" : ""}',
                      style: const TextStyle(fontSize: 13, color: AppColors.slate),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: loading
                          ? null
                          : () async {
                              setState(() => loading = true);
                              try {
                                await onAccept();
                                if (ctx.mounted) Navigator.pop(ctx);
                              } catch (e) {
                                if (ctx.mounted) {
                                  setState(() => loading = false);
                                  ScaffoldMessenger.of(ctx)
                                      .showSnackBar(SnackBar(content: Text('$e')));
                                }
                              }
                            },
                      child: Text(loading ? 'Aceitando...' : 'Aceitar'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: loading
                          ? null
                          : () async {
                              setState(() => loading = true);
                              try {
                                await onRefuse();
                                if (ctx.mounted) Navigator.pop(ctx);
                              } catch (e) {
                                if (ctx.mounted) {
                                  setState(() => loading = false);
                                  ScaffoldMessenger.of(ctx)
                                      .showSnackBar(SnackBar(content: Text('$e')));
                                }
                              }
                            },
                      child: const Text('Recusar'),
                    ),
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

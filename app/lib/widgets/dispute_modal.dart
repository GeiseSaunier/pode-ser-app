import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../theme.dart';

const disputeReasons = {
  'NAO_ENTREGUE': 'Favor não foi entregue',
  'QUALIDADE': 'Qualidade abaixo do combinado',
  'NO_SHOW': 'Falta sem aviso',
  'OUTRO': 'Outro motivo',
};

Future<void> showDisputeModal(
  BuildContext context, {
  required AppTransaction transaction,
  required Future<void> Function(String reason, String description) onSubmit,
}) {
  String reason = 'NAO_ENTREGUE';
  final descriptionController = TextEditingController();

  return showModalBottomSheet(
    context: context,
    backgroundColor: AppColors.paper,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (ctx) {
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
                  const Text('Abrir disputa', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                  IconButton(icon: const Icon(Icons.close, size: 18), onPressed: () => Navigator.pop(ctx)),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Sobre a troca de "${transaction.skillTitle}". Nossa equipe analisa em até 48h e o crédito fica retido até a resolução.',
                style: const TextStyle(fontSize: 12, color: AppColors.slate),
              ),
              const SizedBox(height: 14),
              const Text('Motivo', style: TextStyle(fontSize: 12, color: AppColors.slate)),
              const SizedBox(height: 4),
              DropdownButtonFormField<String>(
                value: reason,
                items: disputeReasons.entries
                    .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value, style: const TextStyle(fontSize: 13))))
                    .toList(),
                onChanged: (v) => setState(() => reason = v ?? reason),
              ),
              const SizedBox(height: 14),
              const Text('Descreva o ocorrido', style: TextStyle(fontSize: 12, color: AppColors.slate)),
              const SizedBox(height: 4),
              TextField(
                controller: descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(hintText: 'Conte o que aconteceu...'),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: loading
                      ? null
                      : () async {
                          setState(() => loading = true);
                          await onSubmit(reason, descriptionController.text);
                          if (ctx.mounted) Navigator.pop(ctx);
                        },
                  child: Text(loading ? 'Enviando...' : 'Enviar para análise'),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

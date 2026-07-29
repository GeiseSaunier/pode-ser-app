import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/transaction.dart';
import '../providers/auth_provider.dart';
import '../services/api_client.dart';
import '../theme.dart';
import '../widgets/header.dart';
import '../widgets/confirm_modal.dart';
import '../widgets/dispute_modal.dart';

const _statusMeta = {
  'PROPOSTA': ('Aguardando aceite', AppColors.gold),
  'ACEITA': ('Aceita', AppColors.slate),
  'EM_ANDAMENTO': ('Em andamento', AppColors.slate),
  'DISPUTA': ('Em disputa', AppColors.danger),
  'CONCLUIDA': ('Concluída', AppColors.moss),
  'CANCELADA': ('Cancelada', AppColors.slate),
  'RECUSADA': ('Recusada', AppColors.slate),
};

class TrocasScreen extends StatefulWidget {
  const TrocasScreen({super.key});

  @override
  State<TrocasScreen> createState() => _TrocasScreenState();
}

class _TrocasScreenState extends State<TrocasScreen> {
  List<AppTransaction> _trocas = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final data = await ApiClient.myTransactions();
      setState(() => _trocas = data.map((e) => AppTransaction.fromJson(e)).toList());
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _confirm(String id) async {
    await ApiClient.confirmTransaction(id);
    await _load();
    if (mounted) await context.read<AuthProvider>().refreshUser();
  }

  Future<void> _dispute(String transactionId, String reason, String description) async {
    await ApiClient.openDispute(transactionId: transactionId, reason: reason, description: description);
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final userId = context.watch<AuthProvider>().user?.id ?? '';

    return Scaffold(
      appBar: const AppHeader(title: 'Minhas trocas'),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.ink))
          : _trocas.isEmpty
              ? const Center(child: Text('Nenhuma troca ainda.', style: TextStyle(color: AppColors.slate)))
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _trocas.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (ctx, i) {
                      final t = _trocas[i];
                      final meta = _statusMeta[t.status] ?? ('Status', AppColors.slate);
                      final counterpart = t.requesterId == userId ? t.providerName : t.requesterName;

                      return GestureDetector(
                        onTap: () => showConfirmModal(
                          context,
                          transaction: t,
                          currentUserId: userId,
                          onConfirm: () => _confirm(t.id),
                          onDispute: () => showDisputeModal(
                            context,
                            transaction: t,
                            onSubmit: (reason, desc) => _dispute(t.id, reason, desc),
                          ),
                        ),
                        child: AppCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(counterpart, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                                      Text(t.skillTitle, style: const TextStyle(fontSize: 13, color: AppColors.slate)),
                                    ],
                                  ),
                                  const Icon(Icons.chevron_right, size: 18, color: AppColors.slate),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: BoxDecoration(color: meta.$2, shape: BoxShape.circle),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(meta.$1, style: TextStyle(fontSize: 12, color: meta.$2)),
                                    ],
                                  ),
                                  Text('${t.creditsAgreed} crédito${t.creditsAgreed > 1 ? "s" : ""}',
                                      style: const TextStyle(fontSize: 12, color: AppColors.slate)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}

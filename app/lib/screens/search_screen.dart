import 'package:flutter/material.dart';
import '../models/skill.dart';
import '../services/api_client.dart';
import '../theme.dart';
import '../widgets/header.dart';
import '../widgets/offer_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _queryController = TextEditingController();
  String _mode = 'todos';
  List<Skill> _offers = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final data = await ApiClient.searchSkills(
        q: _queryController.text.trim().isEmpty ? null : _queryController.text.trim(),
        mode: _mode == 'todos' ? null : _mode,
      );
      setState(() => _offers = data.map((e) => Skill.fromJson(e)).toList());
    } catch (_) {
      setState(() => _offers = []);
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _propose(Skill offer) async {
    try {
      await ApiClient.proposeTransaction(offer.id);
      if (!mounted) return;
      showModalBottomSheet(
        context: context,
        backgroundColor: AppColors.paper,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        builder: (ctx) => Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Proposta enviada', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
              const SizedBox(height: 10),
              Text(
                'Você propôs trocar por "${offer.title}" com ${offer.userName}. Assim que a pessoa aceitar, a troca aparece em "Minhas trocas".',
                style: const TextStyle(fontSize: 13, color: AppColors.slate),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(onPressed: () => Navigator.pop(ctx), child: const Text('Entendi')),
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeader(title: 'Buscar favores'),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.line),
              ),
              child: Row(
                children: [
                  const Icon(Icons.search, size: 18, color: AppColors.slate),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _queryController,
                      onSubmitted: (_) => _load(),
                      decoration: const InputDecoration(
                        hintText: 'Buscar por habilidade ou categoria',
                        border: InputBorder.none,
                        isDense: true,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: ['todos', 'PRESENCIAL', 'REMOTO'].map((f) {
                final selected = _mode == f;
                final label = f == 'todos' ? 'Todos' : (f == 'PRESENCIAL' ? 'Presencial' : 'Remoto');
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () {
                      setState(() => _mode = f);
                      _load();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: selected ? AppColors.ink : AppColors.card,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: selected ? AppColors.ink : AppColors.line),
                      ),
                      child: Text(label,
                          style: TextStyle(fontSize: 12, color: selected ? AppColors.paper : AppColors.slate)),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: AppColors.ink))
                : _offers.isEmpty
                    ? const Center(
                        child: Text('Nada por aqui ainda. Tente outra busca.',
                            style: TextStyle(color: AppColors.slate, fontSize: 13)),
                      )
                    : RefreshIndicator(
                        onRefresh: _load,
                        child: ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          itemCount: _offers.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (ctx, i) => OfferCard(offer: _offers[i], onPropose: () => _propose(_offers[i])),
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

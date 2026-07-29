import 'package:flutter/material.dart';
import '../theme.dart';
import 'search_screen.dart';
import 'trocas_screen.dart';
import 'perfil_screen.dart';
import 'como_funciona_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  static const _screens = [
    SearchScreen(),
    TrocasScreen(),
    PerfilScreen(),
    ComoFuncionaScreen(),
  ];

  static const _items = [
    (icon: Icons.search, label: 'Buscar'),
    (icon: Icons.repeat, label: 'Trocas'),
    (icon: Icons.person_outline, label: 'Perfil'),
    (icon: Icons.help_outline, label: 'Como funciona'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.card,
          border: Border(top: BorderSide(color: AppColors.line)),
        ),
        child: SafeArea(
          top: false,
          child: Row(
            children: List.generate(_items.length, (i) {
              final item = _items[i];
              final selected = _index == i;
              return Expanded(
                child: InkWell(
                  onTap: () => setState(() => _index = i),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10, bottom: 12),
                    child: Column(
                      children: [
                        Icon(item.icon, size: 18, color: selected ? AppColors.ink : AppColors.slate),
                        const SizedBox(height: 4),
                        Text(
                          item.label,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 11,
                            color: selected ? AppColors.ink : AppColors.slate,
                            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

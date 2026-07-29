import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/header.dart';

class ComoFuncionaScreen extends StatelessWidget {
  const ComoFuncionaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeader(title: 'Como funciona'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AppCard(
            background: AppColors.ink,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Sem dinheiro. Só tempo e talento.',
                    style: TextStyle(color: AppColors.paper, fontSize: 16, fontWeight: FontWeight.w500)),
                SizedBox(height: 6),
                Text(
                  'No Pode ser? você troca favores diretamente com outras pessoas usando créditos — não moeda. '
                  '1 hora do seu tempo vale sempre 1 crédito, não importa a habilidade.',
                  style: TextStyle(color: Color(0xFFC7C4B6), fontSize: 13, height: 1.5),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _Step(number: 1, title: 'Você presta um favor', text: 'Edita um vídeo, dá uma aula, traduz um texto — o que for. Cada hora prestada vira crédito.'),
          const SizedBox(height: 12),
          _Step(number: 2, title: 'Os créditos entram na rede', text: 'Você não precisa trocar direto com quem recebeu seu favor. Gasta os créditos com qualquer pessoa da rede.'),
          const SizedBox(height: 12),
          _Step(number: 3, title: 'Você resgata o que precisa', text: 'Use seus créditos acumulados pra pegar aquela aula, consultoria ou o que estiver buscando.'),
          const SizedBox(height: 12),
          _Accordion(
            icon: Icons.paid_outlined,
            iconColor: AppColors.gold,
            title: 'Como o crédito é calculado',
            initiallyOpen: true,
            text: '1 hora de qualquer favor equivale a 1 crédito, independente da habilidade. Isso evita disputa sobre '
                '"minha hora vale mais que a sua" — o valor é o tempo dedicado, não o preço de mercado do serviço.',
          ),
          const SizedBox(height: 12),
          _Accordion(
            icon: Icons.shield_outlined,
            iconColor: AppColors.moss,
            title: 'Quando o crédito é liberado',
            text: 'Só depois que as duas partes confirmam que a troca aconteceu, na tela de "Trocas". Enquanto uma '
                'confirmação estiver faltando, o crédito fica retido — ninguém recebe antes da hora.',
          ),
          const SizedBox(height: 12),
          _Accordion(
            icon: Icons.balance_outlined,
            iconColor: AppColors.danger,
            title: 'Se algo der errado',
            text: 'Qualquer uma das partes pode abrir uma disputa antes da confirmação final. Nossa equipe analisa em '
                'até 48h e decide se o crédito é liberado, estornado, ou se o caso fica sem acordo — tudo fica '
                'registrado no histórico de ambos.',
          ),
          const SizedBox(height: 12),
          _Accordion(
            icon: Icons.hourglass_bottom_outlined,
            iconColor: AppColors.slate,
            title: 'Créditos têm validade?',
            text: 'Créditos parados por muito tempo (acima de um teto) podem expirar depois de alguns meses. A ideia '
                'é manter a rede circulando — banco de favor não é poupança.',
          ),
          const SizedBox(height: 12),
          _Accordion(
            icon: Icons.help_outline,
            iconColor: AppColors.slate,
            title: 'E se eu não tiver créditos ainda?',
            text: 'Todo mundo começa com um pequeno saldo de boas-vindas e pode ficar levemente negativo (até um '
                'limite) pra "adiantar" um favor antes de prestar o primeiro. Isso ajuda a engatar a primeira troca.',
          ),
        ],
      ),
    );
  }
}

class _Step extends StatelessWidget {
  final int number;
  final String title;
  final String text;

  const _Step({required this.number, required this.title, required this.text});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 26,
            height: 26,
            alignment: Alignment.center,
            decoration: const BoxDecoration(color: AppColors.ink, shape: BoxShape.circle),
            child: Text('$number', style: const TextStyle(color: AppColors.paper, fontSize: 12, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                Text(text, style: const TextStyle(fontSize: 13, color: AppColors.slate)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Accordion extends StatefulWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String text;
  final bool initiallyOpen;

  const _Accordion({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.text,
    this.initiallyOpen = false,
  });

  @override
  State<_Accordion> createState() => _AccordionState();
}

class _AccordionState extends State<_Accordion> {
  late bool _open = widget.initiallyOpen;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => setState(() => _open = !_open),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(widget.icon, size: 16, color: widget.iconColor),
                    const SizedBox(width: 8),
                    Text(widget.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  ],
                ),
                Icon(_open ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, size: 18, color: AppColors.slate),
              ],
            ),
          ),
          if (_open) ...[
            const SizedBox(height: 10),
            Text(widget.text, style: const TextStyle(fontSize: 13, color: AppColors.slate, height: 1.5)),
          ],
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme.dart';
import '../providers/auth_provider.dart';
import '../services/api_client.dart';
import '../widgets/social_login_row.dart';

const _skillSuggestions = [
  'Edição de vídeo',
  'Design gráfico',
  'Aulas de idioma',
  'Consultoria',
  'Fotografia',
  'Nutrição',
  'Música',
  'Programação',
];

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  int _step = 1;
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final Set<String> _oferece = {};
  final Set<String> _quer = {};
  bool _loading = false;
  String? _error;

  Future<void> _create() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await context.read<AuthProvider>().register(
            name: _nameController.text.trim(),
            email: _emailController.text.trim(),
            password: _passwordController.text,
            oferece: _oferece.toList(),
            quer: _quer.toList(),
          );
      if (mounted) Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } catch (e) {
      setState(() => _error = 'Não foi possível criar a conta. Tente novamente.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.paper,
        elevation: 0,
        leading: BackButton(
          color: AppColors.ink,
          onPressed: () => _step == 1 ? Navigator.pop(context) : setState(() => _step = 1),
        ),
        title: Text('Passo $_step de 2', style: const TextStyle(fontSize: 12, color: AppColors.slate)),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: _step == 1 ? _buildStep1() : _buildStep2(),
      ),
    );
  }

  Widget _buildStep1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Criar sua conta', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
        const Text('Leva menos de um minuto.', style: TextStyle(fontSize: 13, color: AppColors.slate)),
        const SizedBox(height: 18),
        SocialLoginRow(onTap: (_) => setState(() => _step = 2)),
        const SizedBox(height: 16),
        const Row(children: [
          Expanded(child: Divider(color: AppColors.line)),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Text('ou com e-mail', style: TextStyle(fontSize: 12, color: AppColors.slate)),
          ),
          Expanded(child: Divider(color: AppColors.line)),
        ]),
        const SizedBox(height: 16),
        const Text('Nome', style: TextStyle(fontSize: 12, color: AppColors.slate)),
        const SizedBox(height: 4),
        TextField(controller: _nameController, decoration: const InputDecoration(hintText: 'Seu nome', prefixIcon: Icon(Icons.person_outline, size: 18))),
        const SizedBox(height: 14),
        const Text('E-mail', style: TextStyle(fontSize: 12, color: AppColors.slate)),
        const SizedBox(height: 4),
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(hintText: 'voce@email.com', prefixIcon: Icon(Icons.mail_outline, size: 18)),
        ),
        const SizedBox(height: 14),
        const Text('Senha', style: TextStyle(fontSize: 12, color: AppColors.slate)),
        const SizedBox(height: 4),
        TextField(
          controller: _passwordController,
          obscureText: true,
          decoration: const InputDecoration(hintText: '••••••••', prefixIcon: Icon(Icons.lock_outline, size: 18)),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(onPressed: () => setState(() => _step = 2), child: const Text('Continuar')),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildStep2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('O que você sabe fazer?', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
        const Text('Escolha ao menos uma habilidade que você pode oferecer.',
            style: TextStyle(fontSize: 13, color: AppColors.slate)),
        const SizedBox(height: 12),
        _buildChipWrap(_oferece),
        const SizedBox(height: 18),
        const Text('O que você está buscando?', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
        const Text('Isso ajuda a te mostrar trocas relevantes primeiro.',
            style: TextStyle(fontSize: 13, color: AppColors.slate)),
        const SizedBox(height: 12),
        _buildChipWrap(_quer),
        const SizedBox(height: 18),
        AppCard(
          background: AppColors.mossBg,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Icon(Icons.auto_awesome, size: 16, color: AppColors.moss),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Você ganha 2 créditos de boas-vindas assim que criar a conta, pra já poder resgatar seu primeiro favor.',
                  style: TextStyle(fontSize: 12, color: AppColors.ink),
                ),
              ),
            ],
          ),
        ),
        if (_error != null) ...[
          const SizedBox(height: 10),
          Text(_error!, style: const TextStyle(color: AppColors.danger, fontSize: 12)),
        ],
        const SizedBox(height: 18),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _oferece.isEmpty || _loading ? null : _create,
            child: Text(_loading ? 'Criando...' : 'Criar conta e começar'),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildChipWrap(Set<String> selected) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _skillSuggestions.map((s) {
        final isSelected = selected.contains(s);
        return GestureDetector(
          onTap: () => setState(() => isSelected ? selected.remove(s) : selected.add(s)),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.ink : AppColors.card,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: isSelected ? AppColors.ink : AppColors.line),
            ),
            child: Text(s,
                style: TextStyle(fontSize: 13, color: isSelected ? const Color(0xFFFAFAF6) : AppColors.ink)),
          ),
        );
      }).toList(),
    );
  }
}

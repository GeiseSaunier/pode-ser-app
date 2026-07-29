import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme.dart';
import '../providers/auth_provider.dart';
import '../services/api_client.dart';
import '../widgets/social_login_row.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await context.read<AuthProvider>().login(_emailController.text.trim(), _passwordController.text);
      if (mounted) Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } catch (e) {
      setState(() => _error = 'Não foi possível entrar. Tente novamente.');
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
        leading: BackButton(color: AppColors.ink, onPressed: () => Navigator.pop(context)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Bem-vinda de volta', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
            const SizedBox(height: 4),
            const Text('Entre pra continuar suas trocas.', style: TextStyle(fontSize: 13, color: AppColors.slate)),
            const SizedBox(height: 18),
            SocialLoginRow(onTap: (_) => Navigator.pushNamedAndRemoveUntil(context, '/home', (r) => false)),
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
            if (_error != null) ...[
              const SizedBox(height: 10),
              Text(_error!, style: const TextStyle(color: AppColors.danger, fontSize: 12)),
            ],
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _submit,
                child: Text(_loading ? 'Entrando...' : 'Entrar'),
              ),
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.only(top: 12),
              decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppColors.line))),
              child: Center(
                child: Wrap(
                  children: [
                    const Text('Ainda não tem conta? ', style: TextStyle(fontSize: 13, color: AppColors.slate)),
                    GestureDetector(
                      onTap: () => Navigator.pushReplacementNamed(context, '/signup'),
                      child: const Text('Criar conta',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.ink)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

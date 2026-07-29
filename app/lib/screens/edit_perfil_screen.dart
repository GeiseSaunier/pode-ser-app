import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/api_client.dart';
import '../theme.dart';
import '../widgets/header.dart';

class EditPerfilScreen extends StatefulWidget {
  const EditPerfilScreen({super.key});

  @override
  State<EditPerfilScreen> createState() => _EditPerfilScreenState();
}

class _EditPerfilScreenState extends State<EditPerfilScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _bioController;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    _nameController = TextEditingController(text: user?.name ?? '');
    _bioController = TextEditingController(text: user?.bio ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('O nome não pode ficar vazio')),
      );
      return;
    }
    setState(() => _loading = true);
    try {
      await ApiClient.updateProfile(
        name: _nameController.text.trim(),
        bio: _bioController.text.trim().isEmpty ? null : _bioController.text.trim(),
      );
      if (!mounted) return;
      await context.read<AuthProvider>().refreshUser();
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeader(title: 'Editar perfil'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Nome', style: TextStyle(fontSize: 12, color: AppColors.slate)),
          const SizedBox(height: 4),
          TextField(controller: _nameController, textCapitalization: TextCapitalization.words),
          const SizedBox(height: 16),
          const Text('Bio', style: TextStyle(fontSize: 12, color: AppColors.slate)),
          const SizedBox(height: 4),
          TextField(
            controller: _bioController,
            maxLines: 4,
            decoration: const InputDecoration(hintText: 'Conte um pouco sobre você...'),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loading ? null : _save,
            child: Text(_loading ? 'Salvando...' : 'Salvar'),
          ),
        ],
      ),
    );
  }
}

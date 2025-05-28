import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProfilePage extends StatefulWidget {
  final int userId;

  const ProfilePage({super.key, required this.userId});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final localhostIP = "18.117.165.83";
  bool isLoading = false;

  String name = "";
  String email = "";

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    setState(() => isLoading = true);
    try {
      final response = await http.get(
        Uri.parse('http://$localhostIP:3000/auth/user/${widget.userId}'),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          name = data['name'] ?? '';
          email = data['email'] ?? '';
        });
      } else {
        _showError('Erro ao carregar dados: ${response.statusCode}');
      }
    } catch (e) {
      _showError('Erro de conexão: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _updateField(String field, String value) async {
    if (value.isEmpty) {
      _showError('O campo $field não pode estar vazio.');
      return;
    }

    final url = 'http://$localhostIP:3000/auth/user/${widget.userId}/$field';

    try {
      final response = await http.put(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({field: value}),
      );

      if (response.statusCode == 200) {
        Navigator.of(context).pop(); // Fechar popup
        _fetchUserData(); // Atualiza os dados
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Atualizado com sucesso')),
        );
      } else {
        _showError('Erro ao atualizar: ${response.body}');
      }
    } catch (e) {
      _showError('Erro de conexão: $e');
    }
  }

  void _showEditDialog(String field, String currentValue) {
    final controller = TextEditingController(text: currentValue);
    final isPassword = field == 'password';

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Editar ${_fieldLabel(field)}'),
        content: TextField(
          controller: controller,
          obscureText: isPassword,
          decoration: InputDecoration(labelText: _fieldLabel(field)),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () => _updateField(field, controller.text.trim()),
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  String _fieldLabel(String field) {
    switch (field) {
      case 'name':
        return 'Nome';
      case 'email':
        return 'Email';
      case 'password':
        return 'Senha';
      default:
        return 'Campo';
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Widget _buildCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required String field,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, size: 28),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          final currentValue = field == 'name'
              ? name
              : field == 'email'
                  ? email
                  : '';
          _showEditDialog(field, currentValue);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Configurações")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                const SizedBox(height: 16),
                _buildCard(
                  icon: Icons.person,
                  title: "Nome",
                  subtitle: name,
                  field: "name",
                ),
                _buildCard(
                  icon: Icons.email,
                  title: "Email",
                  subtitle: email,
                  field: "email",
                ),
                _buildCard(
                  icon: Icons.lock,
                  title: "Senha",
                  subtitle: "••••••••",
                  field: "password",
                ),
              ],
            ),
    );
  }
}

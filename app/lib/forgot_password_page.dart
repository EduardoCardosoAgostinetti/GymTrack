import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final emailController = TextEditingController();
  bool isLoading = false;

  Future<void> sendRecoveryCode() async {
    final email = emailController.text.trim();
    final localhostIP = "18.188.208.241";

    if (email.isEmpty) {
      showErrorMessage("Por favor, digite seu email.");
      return;
    }

    setState(() => isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('http://$localhostIP:3000/auth/forgot'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      final data = jsonDecode(response.body);
      setState(() => isLoading = false);

      if (response.statusCode == 200) {
        showSuccessMessage(data['message'] ?? 'Código enviado!');
        Navigator.pushNamed(
          context,
          '/code',
          arguments: {'email': email},
        );
      } else {
        showErrorMessage(data['message'] ?? 'Erro ao enviar código');
      }
    } catch (e) {
      setState(() => isLoading = false);
      showErrorMessage('Erro de conexão');
    }
  }

  void showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  void showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.email_outlined,
                  size: 80, color: Color(0xFF00796B)),
              const SizedBox(height: 24),
              const Text(
                'Recuperar Senha',
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333)),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: emailController,
                decoration:
                    const InputDecoration(labelText: 'Digite seu email'),
              ),
              const SizedBox(height: 24),
              isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: sendRecoveryCode,
                      child: const Text('Enviar código'),
                    ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Lembrou a senha?",
                      style: TextStyle(color: Color(0xFF333333))),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/login'),
                    child: const Text("Entrar"),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

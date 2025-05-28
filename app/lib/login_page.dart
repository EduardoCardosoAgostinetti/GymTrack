import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isLoading = false;

  Future<void> loginUser() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final localhostIP = "18.117.165.83";

    if (email.isEmpty || password.isEmpty) {
      showErrorMessage('Preencha todos os campos');
      return;
    }

    setState(() => isLoading = true);

    final response = await http.post(
      Uri.parse('http://$localhostIP:3000/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    setState(() => isLoading = false);

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      final token = data['token'];
      print(data);
      showSuccessMessage('Login realizado com sucesso!');
      Navigator.pushNamed(
        context,
        '/home',
        arguments: {'userId': data['userId']},
      );
    } else {
      showErrorMessage(data['message'] ?? 'Erro ao fazer login');
    }
  }

  void showSuccessMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.green,
      ),
    );
  }

  void showErrorMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.red,
      ),
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
              const Icon(Icons.lock_outline,
                  size: 80, color: Color(0xFF00796B)),
              const SizedBox(height: 24),
              const Text(
                'Bem-vindo de volta!',
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333)),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Senha'),
              ),
              const SizedBox(height: 24),
              isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: loginUser,
                      child: const Text('Entrar'),
                    ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/forgot'),
                child: const Text('Esqueci minha senha'),
              ),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/register'),
                child: const Text('Criar uma conta'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

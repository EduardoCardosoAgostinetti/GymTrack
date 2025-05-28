import 'package:flutter/material.dart';
import 'login_page.dart';
import 'register_page.dart';
import 'forgot_password_page.dart';
import 'code_verification_page.dart';
import 'reset_password_page.dart';
import 'home_page.dart';
import 'history_page.dart';
import 'new_ficha_page.dart';
import 'profile_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Auth Flow',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: const Color(0xFFF0F4F8),
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: const Color(0xFF00796B),
          secondary: const Color(0xFF0288D1),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00796B),
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF0288D1)),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFF0288D1),
            textStyle: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ),
      initialRoute: '/login',
      routes: {
        '/login': (_) => const LoginPage(),
        '/register': (_) => const RegisterPage(),
        '/forgot': (_) => const ForgotPasswordPage(),
        '/code': (_) => const CodeVerificationPage(),
        '/reset': (_) => const ResetPasswordPage(),
        '/home': (_) => const HomePage(),
        // ❌ Remover essas rotas porque exigem argumentos obrigatórios
        // '/history': (_) => const HistoryPage(),
        // '/newficha': (_) => const NewFichaPage(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/history') {
          final args = settings.arguments as Map<String, dynamic>;
          final int userId = args['userId'];

          return MaterialPageRoute(
            builder: (_) => HistoryPage(userId: userId),
          );
        }

        if (settings.name == '/newficha') {
          final args = settings.arguments as Map<String, dynamic>;
          final int userId = args['userId'];

          return MaterialPageRoute(
            builder: (_) => NewFichaPage(userId: userId),
          );
        }

        return null; // rota não encontrada
      },
    );
  }
}

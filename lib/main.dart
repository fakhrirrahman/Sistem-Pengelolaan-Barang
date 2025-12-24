import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'UI/login.dart';
import 'UI/register.dart';
import 'UI/test_homepage.dart';
import 'seed/firebase_seeder.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // JALANKAN SEKALI — SETELAH ITU COMMENT / HAPUS
  await FirebaseSeeder.createAdmin();
  await FirebaseSeeder.createUser();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firebase Auth App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const LoginScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => TestHomePage(),
        '/register': (context) => const RegisterScreen(),
      },
    );
  }
}
import 'package:flutter/material.dart';
import '../Controllers/auth_service.dart';
import 'register.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double scale = screenSize.width / 375.0; // responsive scale vs iPhone 11 width
    const Color darkBlue = Color(0xFF0D47A1);
    final Color midBlue = const Color(0xFF1565C0);
    final Color accentBlue = const Color(0xFF1976D2);

    return Scaffold(
      backgroundColor: darkBlue,
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                darkBlue,
                darkBlue,
              ],
            ),
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0 * scale, vertical: 20.0 * scale),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
      
                  Container(
                    width: 96 * scale,
                    height: 96 * scale,
                    decoration: BoxDecoration(
                      color: accentBlue,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: accentBlue.withOpacity(0.35),
                          blurRadius: 18 * scale,
                          spreadRadius: 3 * scale,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.lock,
                      size: 44,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 28 * scale),
                  
                  Text(
                    'Selamat Datang Kembali!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 26 * scale,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8 * scale),
                  
                  Text(
                    'Silakan masuk ke akun Anda',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14 * scale,
                      color: Colors.white70,
                    ),
                  ),
                  SizedBox(height: 26 * scale),
                
                Container(
                  decoration: BoxDecoration(
                    color: midBlue.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(12 * scale),
                    border: Border.all(
                      color: accentBlue.withOpacity(0.5),
                      width: 1 * scale,
                    ),
                  ),
                  child: TextField(
                    controller: emailController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: 'Email',
                      hintStyle: TextStyle(color: Colors.white70),
                      prefixIcon: Icon(
                        Icons.email,
                        color: Colors.white,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                ),
                SizedBox(height: 14 * scale),
                
                Container(
                  decoration: BoxDecoration(
                    color: midBlue.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(12 * scale),
                    border: Border.all(
                      color: accentBlue.withOpacity(0.5),
                      width: 1 * scale,
                    ),
                  ),
                  child: TextField(
                    controller: passwordController,
                    obscureText: true,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: 'Password',
                      hintStyle: TextStyle(color: Colors.white70),
                      prefixIcon: Icon(
                        Icons.lock,
                        color: Colors.white,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                ),
                SizedBox(height: 22 * scale),
            
                Container(
                  height: 52 * scale,
                  decoration: BoxDecoration(
                    color: accentBlue,
                    borderRadius: BorderRadius.circular(12 * scale),
                    boxShadow: [
                      BoxShadow(
                        color: accentBlue.withOpacity(0.35),
                        blurRadius: 12 * scale,
                        offset: Offset(0, 4 * scale),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      AuthService.login(
                        emailController.text.trim(),
                        passwordController.text.trim(),
                        context,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12 * scale),
                      ),
                    ),
                    child: Text(
                      'MASUK',
                      style: TextStyle(
                        fontSize: 16 * scale,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 18 * scale),

                Container(
                  height: 50 * scale,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(12 * scale),
                    border: Border.all(
                      color: accentBlue.withOpacity(0.45),
                      width: 1 * scale,
                    ),
                  ),
                  child: TextButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const RegisterScreen()),
                    ),
                    style: TextButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12 * scale),
                      ),
                    ),
                    child: Text(
                      'Belum punya akun? Daftar di sini',
                      style: TextStyle(
                        fontSize: 14 * scale,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

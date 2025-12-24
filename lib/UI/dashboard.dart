import 'package:flutter/material.dart';
import '../Controllers/auth_service.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              AuthService.logout(context);
            },
          ),
        ],
      ),
      body: const Center(
        child: Text(
          'Welcome to Admin Dashboard!',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
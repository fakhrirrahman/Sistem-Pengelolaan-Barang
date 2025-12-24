import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../Controllers/auth_service.dart';
import 'dashboard/dashboard_overview_tab.dart';
import 'dashboard/stock_management_tab.dart';
import 'dashboard/order_history_tab.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  static const List<String> _titles = [
    'Dashboard',
    'Stok Barang',
    'Riwayat Pemesanan',
  ];

  static const List<Widget> _tabs = [
    DashboardOverviewTab(),
    StockManagementTab(),
    OrderHistoryTab(),
  ];

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: Text("Silakan login terlebih dahulu")),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(_titles[_selectedIndex]),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () => AuthService.logout(context),
              ),
            ],
          ),
          drawer: Drawer(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                const DrawerHeader(
                  decoration: BoxDecoration(color: Colors.blue),
                  child: Text(
                    'Menu',
                    style: TextStyle(color: Colors.white, fontSize: 24),
                  ),
                ),
                _drawerItem(Icons.dashboard, 'Dashboard', 0),
                _drawerItem(Icons.inventory, 'Stok Barang', 1),
                _drawerItem(Icons.history, 'Riwayat Pemesanan', 2),
              ],
            ),
          ),
          body: _tabs[_selectedIndex],
        );
      },
    );
  }

  Widget _drawerItem(IconData icon, String title, int index) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      selected: _selectedIndex == index,
      onTap: () {
        _onItemTapped(index);
        Navigator.pop(context);
      },
    );
  }
}

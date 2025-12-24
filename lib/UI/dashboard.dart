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

  // Professional Color Scheme
  static const Color _primaryColor = Color(0xFF1B5E20); // Rich Deep Green
  static const Color _accentColor = Color(0xFF0D47A1); // Premium Blue
  static const Color _surfaceColor = Color(0xFFF5F7FA); // Modern Light Gray
  static const Color _cardColor = Color(0xFFFFFFFF); // White
  static const Color _textPrimaryColor = Color(0xFF1A1A1A); // Deep Dark Gray
  static const Color _textSecondaryColor = Color(0xFF616161); // Medium Gray
  static const Color _successColor = Color(0xFF00897B); // Teal
  static const Color _warningColor = Color(0xFFF57C00); // Orange
  static const Color _infoColor = Color(0xFF1976D2); // Blue

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
          return Scaffold(
            backgroundColor: _surfaceColor,
            body: const Center(
              child: CircularProgressIndicator(
                color: _primaryColor,
              ),
            ),
          );
        }

        if (!snapshot.hasData) {
          return Scaffold(
            backgroundColor: _surfaceColor,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.lock_outline,
                    size: 64,
                    color: _textSecondaryColor,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Silakan login terlebih dahulu",
                    style: TextStyle(
                      color: _textPrimaryColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return Scaffold(
          backgroundColor: _surfaceColor,
          appBar: AppBar(
            elevation: 0,
            backgroundColor: _primaryColor,
            title: Text(
              _titles[_selectedIndex],
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout, color: Colors.white),
                tooltip: 'Logout',
                onPressed: () => AuthService.logout(context),
              ),
              const SizedBox(width: 8),
            ],
          ),
          drawer: _buildDrawer(),
          body: Container(
            color: _surfaceColor,
            child: _tabs[_selectedIndex],
          ),
        );
      },
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: Container(
        color: _cardColor,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [_primaryColor, _accentColor],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.2),
                      ),
                      child: const Icon(
                        Icons.store,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Toko Management',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Kelola bisnis Anda',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                children: [
                  _drawerItem(Icons.dashboard_outlined, 'Dashboard', 0),
                  const SizedBox(height: 8),
                  _drawerItem(Icons.inventory_2_outlined, 'Stok Barang', 1),
                  const SizedBox(height: 8),
                  _drawerItem(Icons.receipt_long_outlined, 'Riwayat Pemesanan', 2),
                ],
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _surfaceColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: _textSecondaryColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Versi 1.0.0',
                        style: TextStyle(
                          color: _textSecondaryColor,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _drawerItem(IconData icon, String title, int index) {
    final isSelected = _selectedIndex == index;

    return Container(
      decoration: BoxDecoration(
        color: isSelected ? _primaryColor.withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        leading: Icon(
          icon,
          color: isSelected ? _primaryColor : _textSecondaryColor,
          size: 24,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? _primaryColor : _textPrimaryColor,
            fontSize: 15,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            letterSpacing: 0.2,
          ),
        ),
        selected: isSelected,
        selectedTileColor: Colors.transparent,
        onTap: () {
          _onItemTapped(index);
          Navigator.pop(context);
        },
      ),
    );
  }
}

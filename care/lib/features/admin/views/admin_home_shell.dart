import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'admin_dashboard_screen.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/views/login_screen.dart'; // Import login screen for logout

class AdminHomeShell extends ConsumerStatefulWidget {
  const AdminHomeShell({super.key});

  @override
  ConsumerState<AdminHomeShell> createState() => _AdminHomeShellState();
}

class _AdminHomeShellState extends ConsumerState<AdminHomeShell> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    AdminDashboardScreen(),
    Center(child: Text('Settings', style: TextStyle(fontSize: 24, color: Colors.grey))), // Placeholder
  ];

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF006859);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          if (index == 1) {
            // Handle Logout
            ref.invalidate(authProvider);
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
              (route) => false,
            );
          } else {
            setState(() => _selectedIndex = index);
          }
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey.shade600,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.logout), label: 'Logout'),
        ],
      ),
    );
  }
}
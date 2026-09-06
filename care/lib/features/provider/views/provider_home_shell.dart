import 'package:flutter/material.dart';
import 'provider_home_screen.dart';
import 'provider_profile_screen.dart';
import 'provider_services_screen.dart';

class ProviderHomeShell extends StatefulWidget {
  const ProviderHomeShell({super.key});

  @override
  State<ProviderHomeShell> createState() => _ProviderHomeShellState();
}

class _ProviderHomeShellState extends State<ProviderHomeShell> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    ProviderHomeScreen(),
    ProviderServicesScreen(),
    ProviderProfileScreen(),
    Center(child: Text('Requests (Coming in Increment 6)')),
  ];

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF006859);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey.shade600,
        showUnselectedLabels: true,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
        unselectedLabelStyle: const TextStyle(fontSize: 12),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.business), label: 'Services'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          BottomNavigationBarItem(icon: Icon(Icons.assignment), label: 'Requests'),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/auth/views/login_screen.dart';

void main() {
  runApp(const ProviderScope(child: CareApp()));
}

class CareApp extends StatelessWidget {
  const CareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Care Providing Platform',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}
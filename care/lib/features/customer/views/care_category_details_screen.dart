import 'package:flutter/material.dart';
import '../models/care_category.dart';
import 'senior_care_form_screen.dart';

class CareCategoryDetailsScreen extends StatelessWidget {
  final CareCategory category;

  const CareCategoryDetailsScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF006859);
    final bool isSeniorCare = category.name == 'Senior Care';

    return Scaffold(
      appBar: AppBar(title: Text(category.name)),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: const BoxDecoration(
                    color: Color(0xFFE6F2F0),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(category.icon, color: primaryColor, size: 32),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    category.description,
                    style: const TextStyle(fontSize: 15, color: Colors.black87),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            const Text(
              'What this care includes',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...category.details.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: primaryColor, size: 18),
                    const SizedBox(width: 10),
                    Text(item, style: const TextStyle(fontSize: 14)),
                  ],
                ),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isSeniorCare
                    ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SeniorCareFormScreen(),
                          ),
                        );
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  isSeniorCare ? 'Post a Care Request' : 'Coming soon',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
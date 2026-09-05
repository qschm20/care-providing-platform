import 'package:flutter/material.dart';

class CareCategory {
  final String name;
  final IconData icon;
  final String description;
  final List<String> details;

  const CareCategory({
    required this.name,
    required this.icon,
    required this.description,
    required this.details,
  });
}

const List<CareCategory> careCategories = [
  CareCategory(
    name: 'Senior Care',
    icon: Icons.accessible_forward_rounded,
    description: 'Care and assistance for elderly family members',
    details: [
      'Personal assistance',
      'Daily activity assistance',
      'Mobility assistance',
      'Companionship',
    ],
  ),
  CareCategory(
    name: 'Child Care',
    icon: Icons.child_care_rounded,
    description: 'Supervision and care for children',
    details: [
      'Child supervision',
      'Age-appropriate activities',
      'Feeding and routine care',
      'Homework assistance',
    ],
  ),
  CareCategory(
    name: 'Pet Care',
    icon: Icons.pets_rounded,
    description: 'Care and attention for your pets',
    details: [
      'Feeding',
      'Walking',
      'General pet assistance',
      'Basic grooming',
    ],
  ),
  CareCategory(
    name: 'Special Needs',
    icon: Icons.accessibility_new_rounded,
    description: 'Specialized assistance and support',
    details: [
      'Type of assistance required',
      'Mobility support',
      'Specific care requirements',
      'Companionship',
    ],
  ),
];
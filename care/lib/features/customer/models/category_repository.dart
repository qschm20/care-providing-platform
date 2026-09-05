import 'package:flutter/material.dart';
import '../models/care_category.dart';

class CategoryRepository {
  List<CareCategory> getCategories() {
    return const [
      CareCategory(
        id: 'senior_care',
        name: 'Senior Care',
        description: 'Care and assistance for elderly family members',
        icon: Icons.accessible_forward_rounded,
        details: [
          'Personal assistance',
          'Daily activity assistance',
          'Mobility assistance',
          'Companionship',
        ],
      ),
      CareCategory(
        id: 'child_care',
        name: 'Child Care',
        description: 'Supervision and care for children',
        icon: Icons.child_care_rounded,
        details: [
          'Child supervision',
          'Age-appropriate activities',
          'Feeding and routine care',
          'Homework assistance',
        ],
      ),
      CareCategory(
        id: 'pet_care',
        name: 'Pet Care',
        description: 'Care and attention for your pets',
        icon: Icons.pets_rounded,
        details: [
          'Feeding',
          'Walking',
          'General pet assistance',
          'Basic grooming',
        ],
      ),
      CareCategory(
        id: 'special_needs',
        name: 'Special Needs',
        description: 'Specialized assistance and support',
        icon: Icons.accessibility_new_rounded,
        details: [
          'Type of assistance required',
          'Mobility support',
          'Specific care requirements',
          'Companionship',
        ],
      ),
    ];
  }
}
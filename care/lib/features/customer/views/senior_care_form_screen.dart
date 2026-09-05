import 'package:flutter/material.dart';
import '../widgets/selection_chip.dart';
import '../widgets/schedule_widget.dart';
import 'review_request_screen.dart';

class SeniorCareFormScreen extends StatefulWidget {
  const SeniorCareFormScreen({super.key});

  @override
  State<SeniorCareFormScreen> createState() => _SeniorCareFormScreenState();
}

class _SeniorCareFormScreenState extends State<SeniorCareFormScreen> {
  static const List<String> _careTypes = [
    'Nursing & Health',
    'Mobility Support',
    'Personal Care',
    'Companionship',
  ];

  static const List<String> _ageRanges = ['60-70', '71-80', '80+'];
  static const List<String> _genderPreferences = ['Male', 'Female', 'No Preference'];

  String? _selectedCareType;
  String? _selectedAgeRange;
  String? _selectedGenderPreference;
  final _additionalRequirementsController = TextEditingController();
  ScheduleData _schedule = const ScheduleData();

  @override
  void dispose() {
    _additionalRequirementsController.dispose();
    super.dispose();
  }

  bool get _isFormValid =>
      _selectedCareType != null &&
      _selectedAgeRange != null &&
      _selectedGenderPreference != null &&
      _schedule.date != null &&
      _schedule.startTime != null &&
      _schedule.endTime != null;

  void _handleReview() {
    if (!_isFormValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields')),
      );
      return;
    }

    if (_timeToMinutes(_schedule.endTime!) <= _timeToMinutes(_schedule.startTime!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('End time must be after start time')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReviewRequestScreen(
          category: 'senior_care',
          categoryDisplayName: 'Senior Care',
          requirements: {
            'care_type': _selectedCareType,
            'age_range': _selectedAgeRange,
            'gender_preference': _selectedGenderPreference,
            if (_additionalRequirementsController.text.isNotEmpty)
              'additional_requirements': _additionalRequirementsController.text,
          },
          schedule: _schedule,
        ),
      ),
    );
  }

  int _timeToMinutes(TimeOfDay time) => time.hour * 60 + time.minute;

  Widget _sectionTitle(String title) => Padding(
        padding: const EdgeInsets.only(bottom: 10, top: 20),
        child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      );

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF006859);

    return Scaffold(
      appBar: AppBar(title: const Text('Senior Care')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Find the Right Care',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const Text(
                'Tell us what kind of support you need',
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
              _sectionTitle('Care Support Type'),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _careTypes
                    .map((type) => SelectionChip(
                          label: type,
                          isSelected: _selectedCareType == type,
                          onTap: () => setState(() => _selectedCareType = type),
                        ))
                    .toList(),
              ),
              _sectionTitle('Age Range'),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _ageRanges
                    .map((range) => SelectionChip(
                          label: range,
                          isSelected: _selectedAgeRange == range,
                          onTap: () => setState(() => _selectedAgeRange = range),
                        ))
                    .toList(),
              ),
              _sectionTitle('Gender Preference'),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _genderPreferences
                    .map((pref) => SelectionChip(
                          label: pref,
                          isSelected: _selectedGenderPreference == pref,
                          onTap: () => setState(() => _selectedGenderPreference = pref),
                        ))
                    .toList(),
              ),
              _sectionTitle('Additional Requirements (Optional)'),
              TextField(
                controller: _additionalRequirementsController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Describe any additional care needs...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              _sectionTitle('Schedule'),
              ScheduleWidget(
                schedule: _schedule,
                onChanged: (updated) => setState(() => _schedule = updated),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _handleReview,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Review Request',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
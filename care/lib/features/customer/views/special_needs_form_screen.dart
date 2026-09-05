import 'package:flutter/material.dart';
import '../widgets/selection_chip.dart';
import '../widgets/schedule_widget.dart';
import 'review_request_screen.dart';

class SpecialNeedsFormScreen extends StatefulWidget {
  const SpecialNeedsFormScreen({super.key});

  @override
  State<SpecialNeedsFormScreen> createState() => _SpecialNeedsFormScreenState();
}

class _SpecialNeedsFormScreenState extends State<SpecialNeedsFormScreen> {
  // State variables
  String? _ageGroup;
  final Set<String> _assistanceRequired = {};
  final TextEditingController _additionalReqController = TextEditingController();
  
  // Initialize with empty ScheduleData
  ScheduleData _scheduleData = const ScheduleData();

  final List<String> _ageGroups = ['Child', 'Teen', 'Adult', 'Senior'];
  final List<String> _assistanceOptions = [
    'Personal Assistance',
    'Mobility Assistance',
    'Daily Activity Support',
    'Supervision',
    'Other Assistance',
  ];

  bool get _isFormValid {
    return _ageGroup != null &&
        _scheduleData.date != null &&
        _scheduleData.startTime != null &&
        _scheduleData.endTime != null &&
        _assistanceRequired.isNotEmpty;
  }

  void _toggleSetItem(Set<String> set, String item) {
    setState(() {
      if (set.contains(item)) {
        set.remove(item);
      } else {
        set.add(item);
      }
    });
  }

  void _proceedToReview() {
    if (!_isFormValid) return;

    // Build the requirements map for the backend (JSONB)
    final requirements = {
      'age_group': _ageGroup,
      'assistance_required': _assistanceRequired.toList(),
      if (_additionalReqController.text.trim().isNotEmpty)
        'additional_requirements': _additionalReqController.text.trim(),
    };

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReviewRequestScreen(
          category: 'special_needs',
          categoryDisplayName: 'Special Needs Care',
          requirements: requirements,
          schedule: _scheduleData,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _additionalReqController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF006859);

    return Scaffold(
      appBar: AppBar(title: const Text('Special Needs Care Request')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Age Group
              const Text('Age Group', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _ageGroups.map((age) {
                  return SelectionChip(
                    label: age,
                    isSelected: _ageGroup == age,
                    onTap: () => setState(() => _ageGroup = age),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // 2. Assistance Required (Multi-select)
              const Text('Assistance Required (Select all that apply)', 
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _assistanceOptions.map((assistance) {
                  return SelectionChip(
                    label: assistance,
                    isSelected: _assistanceRequired.contains(assistance),
                    onTap: () => _toggleSetItem(_assistanceRequired, assistance),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // 3. Additional Requirements
              const Text('Additional Requirements (Optional)', 
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextField(
                controller: _additionalReqController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'e.g., Specific needs, routines, preferences, etc.',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: primaryColor, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // 4. Schedule
              const Text('Schedule', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ScheduleWidget(
                schedule: _scheduleData,
                onChanged: (data) => setState(() => _scheduleData = data),
              ),
              const SizedBox(height: 32),

              // 5. Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isFormValid ? _proceedToReview : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text(
                    'Review Request',
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
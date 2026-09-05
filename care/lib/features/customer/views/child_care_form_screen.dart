import 'package:flutter/material.dart';
import '../widgets/selection_chip.dart';
import '../widgets/number_stepper.dart';
import '../widgets/schedule_widget.dart';
import 'review_request_screen.dart';

class ChildCareFormScreen extends StatefulWidget {
  const ChildCareFormScreen({super.key});

  @override
  State<ChildCareFormScreen> createState() => _ChildCareFormScreenState();
}

class _ChildCareFormScreenState extends State<ChildCareFormScreen> {
  // State variables
  String? _careType;
  int _numberOfChildren = 1;
  final Set<String> _ageGroups = {};
  final Set<String> _additionalHelp = {};
  final TextEditingController _additionalReqController = TextEditingController();
  
  // Initialize with empty ScheduleData
  ScheduleData _scheduleData = const ScheduleData();

  final List<String> _careTypes = ['Babysitting', 'Nannies', 'Childminders'];
  final List<String> _ageGroupOptions = ['Infant', 'Toddler', 'School Age', 'Teen'];
  final List<String> _additionalHelpOptions = [
    'Cooking & Meals',
    'Pickup & Drop-off',
    'Homework Help',
    'Activities & Games',
  ];

  bool get _isFormValid {
    return _careType != null &&
        _scheduleData.date != null &&
        _scheduleData.startTime != null &&
        _scheduleData.endTime != null &&
        _ageGroups.isNotEmpty;
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
      'care_type': _careType,
      'number_of_children': _numberOfChildren,
      'age_groups': _ageGroups.toList(),
      'additional_help': _additionalHelp.toList(),
      if (_additionalReqController.text.trim().isNotEmpty)
        'additional_requirements': _additionalReqController.text.trim(),
    };

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReviewRequestScreen(
          category: 'child_care',
          categoryDisplayName: 'Child Care',
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
      appBar: AppBar(title: const Text('Child Care Request')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Care Type
              const Text('Care Type', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _careTypes.map((type) {
                  return SelectionChip(
                    label: type,
                    isSelected: _careType == type,
                    onTap: () => setState(() => _careType = type),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // 2. Number of Children
              const Text('Number of Children', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              NumberStepper(
                value: _numberOfChildren,
                minValue: 1,
                onChanged: (val) => setState(() => _numberOfChildren = val),
              ),
              const SizedBox(height: 24),

              // 3. Age Groups (Multi-select)
              const Text('Age Groups (Select all that apply)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _ageGroupOptions.map((age) {
                  return SelectionChip(
                    label: age,
                    isSelected: _ageGroups.contains(age),
                    onTap: () => _toggleSetItem(_ageGroups, age),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // 4. Additional Help (Multi-select)
              const Text('Additional Help (Optional)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _additionalHelpOptions.map((help) {
                  return SelectionChip(
                    label: help,
                    isSelected: _additionalHelp.contains(help),
                    onTap: () => _toggleSetItem(_additionalHelp, help),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // 5. Additional Requirements
              const Text('Additional Requirements (Optional)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextField(
                controller: _additionalReqController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'e.g., Allergies, specific routines, etc.',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: primaryColor, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // 6. Schedule (FIXED PARAMETERS)
              const Text('Schedule', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ScheduleWidget(
                schedule: _scheduleData,
                onChanged: (data) => setState(() => _scheduleData = data),
              ),
              const SizedBox(height: 32),

              // 7. Submit Button
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
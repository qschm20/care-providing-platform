import 'package:flutter/material.dart';
import '../widgets/selection_chip.dart';
import '../widgets/number_stepper.dart';
import '../widgets/schedule_widget.dart';
import 'review_request_screen.dart';

class PetCareFormScreen extends StatefulWidget {
  const PetCareFormScreen({super.key});

  @override
  State<PetCareFormScreen> createState() => _PetCareFormScreenState();
}

class _PetCareFormScreenState extends State<PetCareFormScreen> {
  // State variables
  String? _petType;
  int _numberOfPets = 1;
  final Set<String> _careRequired = {};
  final TextEditingController _additionalReqController = TextEditingController();
  
  // Initialize with empty ScheduleData
  ScheduleData _scheduleData = const ScheduleData();

  final List<String> _petTypes = ['Dog', 'Cat', 'Bird', 'Other'];
  final List<String> _careOptions = [
    'Feeding',
    'Walking',
    'Grooming Assistance',
    'Medication Assistance',
    'General Pet Care',
  ];

  bool get _isFormValid {
    return _petType != null &&
        _scheduleData.date != null &&
        _scheduleData.startTime != null &&
        _scheduleData.endTime != null &&
        _careRequired.isNotEmpty;
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
      'pet_type': _petType,
      'number_of_pets': _numberOfPets,
      'care_required': _careRequired.toList(),
      if (_additionalReqController.text.trim().isNotEmpty)
        'additional_requirements': _additionalReqController.text.trim(),
    };

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReviewRequestScreen(
          category: 'pet_care',
          categoryDisplayName: 'Pet Care',
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
      appBar: AppBar(title: const Text('Pet Care Request')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Pet Type
              const Text('Pet Type', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _petTypes.map((type) {
                  return SelectionChip(
                    label: type,
                    isSelected: _petType == type,
                    onTap: () => setState(() => _petType = type),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // 2. Number of Pets
              const Text('Number of Pets', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              NumberStepper(
                value: _numberOfPets,
                minValue: 1,
                onChanged: (val) => setState(() => _numberOfPets = val),
              ),
              const SizedBox(height: 24),

              // 3. Care Required (Multi-select)
              const Text('Care Required (Select all that apply)', 
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _careOptions.map((care) {
                  return SelectionChip(
                    label: care,
                    isSelected: _careRequired.contains(care),
                    onTap: () => _toggleSetItem(_careRequired, care),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // 4. Additional Requirements
              const Text('Additional Requirements (Optional)', 
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextField(
                controller: _additionalReqController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'e.g., Special diet, behavioral notes, etc.',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: primaryColor, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // 5. Schedule
              const Text('Schedule', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ScheduleWidget(
                schedule: _scheduleData,
                onChanged: (data) => setState(() => _scheduleData = data),
              ),
              const SizedBox(height: 32),

              // 6. Submit Button
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
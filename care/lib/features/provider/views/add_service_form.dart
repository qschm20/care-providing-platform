import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/provider_services_provider.dart';

class AddServiceForm extends ConsumerStatefulWidget {
  final VoidCallback onSuccess;

  const AddServiceForm({super.key, required this.onSuccess});

  @override
  ConsumerState<AddServiceForm> createState() => _AddServiceFormState();
}

class _AddServiceFormState extends ConsumerState<AddServiceForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _hoursController = TextEditingController(text: '1.0');

  String? _selectedCategory;
  final List<String> _selectedSpecializedTypes = [];
  String? _selectedPricingUnit;
  final List<String> _selectedAdditionalRequests = [];
  bool _isLoading = false;

  final List<String> _categories = ['senior_care', 'child_care', 'pet_care', 'special_needs'];
  final List<String> _pricingUnits = ['hourly', 'daily', 'per_session'];

  // Multi-select specialized care types based on category
  final Map<String, List<String>> _specializedCareOptions = {
    'senior_care': [
      'Nursing & Health Monitoring',
      'Mobility Support',
      'Personal Care (Bathing, Dressing)',
      'Medication Management',
      'Companionship',
      'Meal Preparation',
    ],
    'child_care': [
      'Babysitting',
      'Nannies (Full-time)',
      'Childminders',
      'After-School Care',
      'Infant Care',
      'Tutoring',
    ],
    'pet_care': [
      'Dog Walking',
      'Pet Feeding',
      'Grooming Assistance',
      'Medication Administration',
      'Pet Sitting (Overnight)',
      'Exercise & Play',
      'Training Support',
    ],
    'special_needs': [
      'Personal Assistance',
      'Mobility Assistance',
      'Daily Activity Support',
      'Supervision',
      'Therapy Support',
      'Behavioral Management',
      'Communication Assistance',
    ],
  };

  // Additional Requests based on category
  final Map<String, List<String>> _additionalRequestsOptions = {
    'senior_care': [
      'Cooking Meals',
      'Activities & Games',
      'Transportation/Errands',
      'Doctor Visit Accompaniment',
      'Reading Assistance',
      'Exercise Companionship',
      'Light Housekeeping',
    ],
    'child_care': [
      'Homework Help',
      'Educational Activities',
      'Arts & Crafts',
      'Outdoor Play',
      'Meal Preparation',
      'Bedtime Routines',
      'School Pickup/Dropoff',
    ],
    'pet_care': [
      'Basic Training',
    ],
    'special_needs': [
      'Sensory Activities',
      'Routine Management',
      'Crisis Intervention',
      'Family Communication',
      'Community Integration',
      'Life Skills Training',
    ],
  };

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _hoursController.dispose();
    super.dispose();
  }

  void _onCategoryChanged(String? newCategory) {
    setState(() {
      _selectedCategory = newCategory;
      _selectedSpecializedTypes.clear();
      _selectedAdditionalRequests.clear();
    });
  }

  void _toggleSpecializedType(String type) {
    setState(() {
      if (_selectedSpecializedTypes.contains(type)) {
        _selectedSpecializedTypes.remove(type);
      } else {
        _selectedSpecializedTypes.add(type);
      }
    });
  }

  void _toggleAdditionalRequest(String request) {
    setState(() {
      if (_selectedAdditionalRequests.contains(request)) {
        _selectedAdditionalRequests.remove(request);
      } else {
        _selectedAdditionalRequests.add(request);
      }
    });
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory == null || _selectedPricingUnit == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select category and pricing unit'), backgroundColor: Colors.red),
      );
      return;
    }
    if (_selectedSpecializedTypes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one specialized care type'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true);

    // ✅ COMBINE BOTH LISTS SO EVERYTHING SAVES TO THE DATABASE
    final allSkills = [
      ..._selectedSpecializedTypes,
      ..._selectedAdditionalRequests,
    ];

    final serviceData = {
      'title': _titleController.text.trim(),
      'category': _selectedCategory,
      'description': _descriptionController.text.trim(),
      'price': double.parse(_priceController.text.trim()),
      'pricing_unit': _selectedPricingUnit,
      'hours': double.parse(_hoursController.text.trim()),
      'skills': allSkills, // ✅ Now sends BOTH specialized types and additional requests
    };

    final success = await ref.read(providerServicesProvider.notifier).addService(serviceData);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      widget.onSuccess();
    } else {
      final error = ref.read(providerServicesProvider).error ?? 'Failed to save service';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF006859);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Category
            const Text('1. Primary Care Category', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'Select primary category'),
              items: _categories.map((cat) {
                return DropdownMenuItem(value: cat, child: Text(cat.replaceAll('_', ' ').toUpperCase()));
              }).toList(),
              onChanged: _onCategoryChanged,
              validator: (val) => val == null ? 'Required' : null,
            ),
            const SizedBox(height: 24),

            // 2. Title & Description (Only show if category selected)
            if (_selectedCategory != null) ...[
              const Text('2. Service Title & Description', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Service Title',
                  hintText: 'e.g., Comprehensive Senior Care',
                  border: OutlineInputBorder(),
                ),
                validator: (val) => (val == null || val.trim().length < 3) ? 'Min 3 characters' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Describe what this service includes...',
                  border: OutlineInputBorder(),
                ),
                validator: (val) => (val == null || val.trim().length < 10) ? 'Min 10 characters' : null,
              ),
              const SizedBox(height: 24),

              // 3. Specialized Care Types (MULTI-SELECT)
              const Text('3. Specialized Care Types (Select all that apply)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: (_specializedCareOptions[_selectedCategory] ?? []).map((type) {
                  final isSelected = _selectedSpecializedTypes.contains(type);
                  return FilterChip(
                    label: Text(type),
                    selected: isSelected,
                    onSelected: (bool selected) => _toggleSpecializedType(type),
                    selectedColor: primaryColor.withOpacity(0.2),
                    checkmarkColor: primaryColor,
                    labelStyle: TextStyle(
                      color: isSelected ? primaryColor : Colors.black87,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    side: BorderSide(color: isSelected ? primaryColor : Colors.grey.shade300),
                  );
                }).toList(),
              ),
              if (_selectedSpecializedTypes.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text('Please select at least one type', style: TextStyle(color: Colors.red.shade700, fontSize: 12)),
                ),
              const SizedBox(height: 24),

              // 4. Additional Requests (Optional)
              const Text('4. Additional Requests (Optional)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(
                'Select any extra services you can provide:',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: (_additionalRequestsOptions[_selectedCategory] ?? []).map((request) {
                  final isSelected = _selectedAdditionalRequests.contains(request);
                  return FilterChip(
                    label: Text(request),
                    selected: isSelected,
                    onSelected: (bool selected) => _toggleAdditionalRequest(request),
                    selectedColor: Colors.blue.shade50,
                    checkmarkColor: Colors.blue.shade700,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.blue.shade700 : Colors.black87,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    side: BorderSide(color: isSelected ? Colors.blue.shade300 : Colors.grey.shade300),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // 5. Pricing (Rs.)
              const Text('5. Pricing & Minimum Booking', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _priceController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Your Hourly Rate',
                        prefixText: 'Rs. ',
                        border: OutlineInputBorder(),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) return 'Required';
                        if (double.tryParse(val.trim()) == null) return 'Invalid number';
                        if (double.parse(val.trim()) <= 0) return 'Must be > 0';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: DropdownButtonFormField<String>(
                      value: _selectedPricingUnit,
                      decoration: const InputDecoration(labelText: 'Unit', border: OutlineInputBorder()),
                      items: _pricingUnits.map((unit) {
                        return DropdownMenuItem(value: unit, child: Text(unit.replaceAll('_', ' ').toUpperCase()));
                      }).toList(),
                      onChanged: (val) => setState(() => _selectedPricingUnit = val),
                      validator: (val) => val == null ? 'Required' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _hoursController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Minimum Hours',
                  hintText: 'e.g., 1.0',
                  border: OutlineInputBorder(),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Required';
                  if (double.tryParse(val.trim()) == null) return 'Invalid number';
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: _isLoading
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Publish Service', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ] else ...[
              // Placeholder when no category is selected yet
              const SizedBox(height: 40),
              Center(
                child: Column(
                  children: [
                    Icon(Icons.touch_app, size: 48, color: Colors.grey.shade400),
                    const SizedBox(height: 16),
                    Text('Select a Care Category above to begin', style: TextStyle(color: Colors.grey.shade600, fontSize: 16)),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/provider_services_provider.dart';

class AddEditServiceScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic>? existingService;

  const AddEditServiceScreen({super.key, this.existingService});

  @override
  ConsumerState<AddEditServiceScreen> createState() => _AddEditServiceScreenState();
}

class _AddEditServiceScreenState extends ConsumerState<AddEditServiceScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  
  String? _selectedCategory;
  String? _selectedPricingUnit;
  bool _isLoading = false;

  final List<String> _categories = ['senior_care', 'child_care', 'pet_care', 'special_needs'];
  final List<String> _pricingUnits = ['hourly', 'daily', 'per_session'];

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController(text: widget.existingService?['description'] ?? '');
    _priceController = TextEditingController(text: widget.existingService?['price']?.toString() ?? '');
    _selectedCategory = widget.existingService?['category'];
    _selectedPricingUnit = widget.existingService?['pricing_unit'];
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _saveService() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory == null || _selectedPricingUnit == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select category and pricing unit'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true);

    final serviceData = {
      'category': _selectedCategory,
      'description': _descriptionController.text.trim(),
      'price': double.parse(_priceController.text.trim()),
      'pricing_unit': _selectedPricingUnit,
    };

    bool success;
    if (widget.existingService != null) {
      success = await ref.read(providerServicesProvider.notifier).updateService(
        widget.existingService!['id'],
        serviceData,
      );
    } else {
      success = await ref.read(providerServicesProvider.notifier).addService(serviceData);
    }

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      Navigator.pop(context, true); // Return true to indicate success
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
    final isEditing = widget.existingService != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(isEditing ? 'Edit Service' : 'Add New Service', 
            style: const TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Care Category', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'Select category'),
                  items: _categories.map((cat) {
                    return DropdownMenuItem(value: cat, child: Text(cat.replaceAll('_', ' ').toUpperCase()));
                  }).toList(),
                  onChanged: (val) => setState(() => _selectedCategory = val),
                  validator: (val) => val == null ? 'Please select a category' : null,
                ),
                const SizedBox(height: 24),

                const Text('Description', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    hintText: 'Describe what this service includes...',
                    border: OutlineInputBorder(),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) return 'Description is required';
                    if (val.trim().length < 10) return 'Description must be at least 10 characters';
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Price (Rs.)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _priceController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: const InputDecoration(
                              hintText: 'e.g., 500',
                              border: OutlineInputBorder(),
                            ),
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) return 'Required';
                              if (double.tryParse(val.trim()) == null) return 'Invalid number';
                              if (double.parse(val.trim()) <= 0) return 'Must be > 0';
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Pricing Unit', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            value: _selectedPricingUnit,
                            decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'Select unit'),
                            items: _pricingUnits.map((unit) {
                              return DropdownMenuItem(value: unit, child: Text(unit.replaceAll('_', ' ').toUpperCase()));
                            }).toList(),
                            onChanged: (val) => setState(() => _selectedPricingUnit = val),
                            validator: (val) => val == null ? 'Required' : null,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveService,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: _isLoading
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : Text(isEditing ? 'Update Service' : 'Add Service', 
                            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
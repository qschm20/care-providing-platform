import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/provider_services_provider.dart';
import 'add_service_form.dart';

class ProviderServicesScreen extends ConsumerStatefulWidget {
  const ProviderServicesScreen({super.key});

  @override
  ConsumerState<ProviderServicesScreen> createState() => _ProviderServicesScreenState();
}

class _ProviderServicesScreenState extends ConsumerState<ProviderServicesScreen> {
  bool _isAddingService = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(providerServicesProvider.notifier).fetchServices();
    });
  }

  Future<void> _confirmDelete(String serviceId, String categoryName) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Service?'),
        content: Text('Are you sure you want to delete this $categoryName service? This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final success = await ref.read(providerServicesProvider.notifier).deleteService(serviceId);
      if (mounted && success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Service deleted'), backgroundColor: Colors.teal),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF006859);
    final servicesState = ref.watch(providerServicesProvider);
    final services = servicesState.services;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('My Services', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // --- TOGGLE BUTTON ---
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _isAddingService = false),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: !_isAddingService ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: !_isAddingService ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)] : null,
                      ),
                      child: Center(
                        child: Text(
                          'My Services (${services.length})',
                          style: TextStyle(fontWeight: FontWeight.w600, color: !_isAddingService ? primaryColor : Colors.grey.shade600),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _isAddingService = true),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _isAddingService ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: _isAddingService ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)] : null,
                      ),
                      child: const Center(
                        child: Text('+ Create Service', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF006859))),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // --- CONTENT AREA ---
          Expanded(
            child: _isAddingService
                ? AddServiceForm(
                    onSuccess: () {
                      setState(() => _isAddingService = false);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Service published successfully!'), backgroundColor: Colors.teal),
                      );
                    },
                  )
                : servicesState.isLoading && services.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : services.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.business, size: 64, color: Colors.grey.shade400),
                                const SizedBox(height: 16),
                                Text('No services added yet', style: TextStyle(fontSize: 16, color: Colors.grey.shade600)),
                                const SizedBox(height: 8),
                                ElevatedButton(
                                  onPressed: () => setState(() => _isAddingService = true),
                                  style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
                                  child: const Text('Add Your First Service', style: TextStyle(color: Colors.white)),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: () => ref.read(providerServicesProvider.notifier).fetchServices(),
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: services.length,
                              itemBuilder: (context, index) {
                                final service = services[index];
                                final category = (service['category'] as String).replaceAll('_', ' ').toUpperCase();
                                final price = service['price'];
                                final unit = (service['pricing_unit'] as String).replaceAll('_', ' ');
                                final title = service['title'] ?? category;

                                return Card(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: primaryColor.withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: Text(category, style: const TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 12)),
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.delete_outline, size: 20, color: Colors.red),
                                              onPressed: () => _confirmDelete(service['id'], category),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                        const SizedBox(height: 8),
                                        Text(service['description'], style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.4)),
                                        const SizedBox(height: 12),
                                        if (service['skills'] != null && (service['skills'] as List).isNotEmpty) ...[
                                          Wrap(
                                            spacing: 6,
                                            runSpacing: 6,
                                            children: (service['skills'] as List).map<Widget>((skill) {
                                              return Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: Colors.blue.shade50,
                                                  borderRadius: BorderRadius.circular(4),
                                                  border: Border.all(color: Colors.blue.shade200),
                                                ),
                                                child: Text(skill, style: const TextStyle(fontSize: 11, color: Colors.blue)),
                                              );
                                            }).toList(),
                                          ),
                                          const SizedBox(height: 12),
                                        ],
                                        Row(
                                          children: [
                                            const Icon(Icons.attach_money, size: 16, color: Colors.grey),
                                            const SizedBox(width: 4),
                                            Text(
                                              'Rs. $price / $unit',
                                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: primaryColor),
                                            ),
                                            const SizedBox(width: 12),
                                            const Icon(Icons.access_time, size: 16, color: Colors.grey),
                                            const SizedBox(width: 4),
                                            Text(
                                              '${service['hours']} hrs',
                                              style: const TextStyle(fontSize: 14, color: Colors.black87),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}
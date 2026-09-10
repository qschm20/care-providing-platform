import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/provider_search_provider.dart';
import 'provider_detail_screen.dart';

class ProviderSearchScreen extends ConsumerStatefulWidget {
  const ProviderSearchScreen({super.key});

  @override
  ConsumerState<ProviderSearchScreen> createState() => _ProviderSearchScreenState();
}

class _ProviderSearchScreenState extends ConsumerState<ProviderSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedCategory;
  final List<String> _categories = ['senior_care', 'child_care', 'pet_care', 'special_needs'];

  @override
  void initState() {
    super.initState();
    // Load all approved providers on initial load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(providerSearchProvider.notifier).search();
    });
  }

  void _performSearch() {
    ref.read(providerSearchProvider.notifier).search(
          category: _selectedCategory,
          search: _searchController.text.trim().isEmpty ? null : _searchController.text.trim(),
        );
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF006859);
    final state = ref.watch(providerSearchProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Find Care Providers', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 1. Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by name or bio...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear, color: Colors.grey),
                  onPressed: () {
                    _searchController.clear();
                    _performSearch();
                  },
                ),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onSubmitted: (_) => _performSearch(),
            ),
          ),

          // 2. Category Tabs (Chips)
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _categories.length + 1, // +1 for "All"
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: FilterChip(
                      label: const Text('All'),
                      selected: _selectedCategory == null,
                      onSelected: (selected) {
                        setState(() => _selectedCategory = null);
                        _performSearch();
                      },
                      selectedColor: primaryColor.withOpacity(0.2),
                      checkmarkColor: primaryColor,
                      labelStyle: TextStyle(
                        color: _selectedCategory == null ? primaryColor : Colors.black87,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                }
                final category = _categories[index - 1];
                final displayName = category.replaceAll('_', ' ').toUpperCase();
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FilterChip(
                    label: Text(displayName),
                    selected: _selectedCategory == category,
                    onSelected: (selected) {
                      setState(() => _selectedCategory = selected ? category : null);
                      _performSearch();
                    },
                    selectedColor: primaryColor.withOpacity(0.2),
                    checkmarkColor: primaryColor,
                    labelStyle: TextStyle(
                      color: _selectedCategory == category ? primaryColor : Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 8),

          // 3. Provider List
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator(color: primaryColor))
                : state.error != null
                    ? Center(child: Text('Error: ${state.error}', style: const TextStyle(color: Colors.red)))
                    : state.providers.isEmpty
                        ? const Center(
                            child: Text(
                              'No matching providers found.\nTry adjusting your search or category.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey, fontSize: 16),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: state.providers.length,
                            itemBuilder: (context, index) {
                              final provider = state.providers[index];
                              final primaryService = provider.services.isNotEmpty ? provider.services.first : null;

                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                elevation: 2,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(12),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ProviderDetailScreen(provider: provider),
                                      ),
                                    );
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            const CircleAvatar(
                                              radius: 24,
                                              backgroundColor: Color(0xFFE0F2F1),
                                              child: Icon(Icons.person, color: primaryColor, size: 28),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Expanded(
                                                        child: Text(
                                                          provider.name,
                                                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                                          maxLines: 1,
                                                          overflow: TextOverflow.ellipsis,
                                                        ),
                                                      ),
                                                      if (provider.verificationStatus == 'approved')
                                                        Container(
                                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                          decoration: BoxDecoration(
                                                            color: Colors.green.shade100,
                                                            borderRadius: BorderRadius.circular(4),
                                                          ),
                                                          child: const Row(
                                                            mainAxisSize: MainAxisSize.min,
                                                            children: [
                                                              Icon(Icons.verified, size: 14, color: Colors.green),
                                                              SizedBox(width: 4),
                                                              Text('Verified', style: TextStyle(fontSize: 10, color: Colors.green, fontWeight: FontWeight.bold)),
                                                            ],
                                                          ),
                                                        ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 4),
                                                  if (provider.serviceArea != null)
                                                    Row(
                                                      children: [
                                                        const Icon(Icons.location_on, size: 14, color: Colors.grey),
                                                        const SizedBox(width: 4),
                                                        Text(provider.serviceArea!, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                                      ],
                                                    ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        if (provider.bio != null) ...[
                                          const SizedBox(height: 12),
                                          Text(
                                            provider.bio!,
                                            style: const TextStyle(fontSize: 13, color: Colors.black87, height: 1.4),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                        if (primaryService != null) ...[
                                          const SizedBox(height: 12),
                                          Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: primaryColor.withOpacity(0.05),
                                              borderRadius: BorderRadius.circular(8),
                                              border: Border.all(color: primaryColor.withOpacity(0.2)),
                                            ),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        primaryService.category.replaceAll('_', ' ').toUpperCase(),
                                                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: primaryColor),
                                                      ),
                                                      const SizedBox(height: 2),
                                                      Text(
                                                        primaryService.title,
                                                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                                                        maxLines: 1,
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Text(
                                                  'Rs. ${primaryService.price.toStringAsFixed(0)} / ${primaryService.pricingUnit.replaceAll('_', ' ')}',
                                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: primaryColor),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
}
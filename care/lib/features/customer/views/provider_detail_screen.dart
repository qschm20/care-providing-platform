import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/provider_search_model.dart';
import '../../review/providers/review_provider.dart';

class ProviderDetailScreen extends ConsumerWidget {
  final ProviderSearchModel provider;

  const ProviderDetailScreen({super.key, required this.provider});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const primaryColor = Color(0xFF006859);

    // ✅ FIXED: Use provider.providerId to match your ProviderSearchModel
    final reviewsAsync = ref.watch(providerReviewsProvider(provider.providerId));

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Provider Details', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                const CircleAvatar(
                  radius: 32,
                  backgroundColor: Color(0xFFE0F2F1),
                  child: Icon(Icons.person, color: primaryColor, size: 40),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        provider.name,
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      if (provider.verificationStatus == 'approved')
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green.shade100,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.verified, size: 16, color: Colors.green),
                              SizedBox(width: 6),
                              Text('Verified Provider', style: TextStyle(fontSize: 12, color: Colors.green, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Bio
            if (provider.bio != null) ...[
              const Text('About', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(provider.bio!, style: const TextStyle(fontSize: 15, color: Colors.black87, height: 1.5)),
              const SizedBox(height: 24),
            ],

            // Service Area
            if (provider.serviceArea != null) ...[
              const Text('Service Area', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.location_on, color: primaryColor),
                  const SizedBox(width: 8),
                  Text(provider.serviceArea!, style: const TextStyle(fontSize: 15)),
                ],
              ),
              const SizedBox(height: 24),
            ],

            // Services Offered
            const Text('Services Offered', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ...provider.services.map((service) {
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 1,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            service.category.replaceAll('_', ' ').toUpperCase(),
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: primaryColor),
                          ),
                          Text(
                            'Rs. ${service.price.toStringAsFixed(0)} / ${service.pricingUnit.replaceAll('_', ' ')}',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: primaryColor),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(service.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      Text(service.description, style: const TextStyle(fontSize: 14, color: Colors.black87)),
                      if (service.skills.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: service.skills.map((skill) {
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
                      ],
                    ],
                  ),
                ),
              );
            }).toList(),

            const SizedBox(height: 30),

            // ✅ NEW: Ratings & Reviews Section
            const Text(
              'Ratings & Reviews',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 12),

            // ✅ Now we can safely call .when() because reviewsAsync is declared above
            reviewsAsync.when(
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (err, stack) => Text(
                'Error loading reviews: $err',
                style: const TextStyle(color: Colors.red, fontSize: 14),
              ),
              data: (reviewsData) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Rating Summary Card
                    Card(
                      elevation: 1,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Column(
                              children: [
                                Text(
                                  reviewsData.averageRating != null ? reviewsData.averageRating!.toStringAsFixed(1) : '—',
                                  style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: primaryColor),
                                ),
                                const Text('Average Rating', style: TextStyle(fontSize: 12, color: Colors.grey)),
                              ],
                            ),
                            Container(height: 40, width: 1, color: Colors.grey.shade300),
                            Column(
                              children: [
                                Text(
                                  '${reviewsData.totalReviews}',
                                  style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: primaryColor),
                                ),
                                const Text('Total Reviews', style: TextStyle(fontSize: 12, color: Colors.grey)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 2. List of Reviews
                    if (reviewsData.totalReviews == 0)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Text('No reviews yet. Be the first to review!', style: TextStyle(color: Colors.grey)),
                        ),
                      )
                    else
                      ...reviewsData.reviews.map((review) => Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(review.customerName, style: const TextStyle(fontWeight: FontWeight.bold)),
                                  Row(
                                    children: List.generate(5, (i) => Icon(
                                      i < review.rating ? Icons.star : Icons.star_border,
                                      color: Colors.amber,
                                      size: 16,
                                    )),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(review.comment, style: const TextStyle(fontSize: 14)),
                              const SizedBox(height: 4),
                              Text(
                                '${review.createdAt.day}/${review.createdAt.month}/${review.createdAt.year}',
                                style: const TextStyle(fontSize: 10, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      )),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
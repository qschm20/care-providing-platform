import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/admin_provider.dart';
import '../../auth/providers/auth_provider.dart';

class AdminProviderDetailScreen extends ConsumerWidget {
  final String providerId;
  final String providerName;

  const AdminProviderDetailScreen({super.key, required this.providerId, required this.providerName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const primaryColor = Color(0xFF006859);
    final state = ref.watch(adminNotifierProvider);
    final provider = state.providers.firstWhere((p) => p['provider_id'] == providerId, orElse: () => null);

    if (provider == null) {
      return Scaffold(appBar: AppBar(title: const Text('Provider Details')), body: const Center(child: Text('Provider not found')));
    }

    final status = provider['verification_status'];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(title: Text(providerName), backgroundColor: Colors.transparent, elevation: 0, foregroundColor: primaryColor),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      const Text('Verification Status', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: status == 'approved' ? Colors.green.shade100 : (status == 'rejected' ? Colors.red.shade100 : Colors.orange.shade100),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(status.toUpperCase(), style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: status == 'approved' ? Colors.green : (status == 'rejected' ? Colors.red : Colors.orange))),
                      ),
                    ]),
                    const Divider(height: 24),
                    _buildInfoRow('Email', provider['email'] ?? 'N/A'),
                    _buildInfoRow('Phone', provider['phone'] ?? 'N/A'),
                    _buildInfoRow('Service Area', provider['service_area'] ?? 'N/A'),
                    _buildInfoRow('Bio', provider['bio'] ?? 'No bio provided'),
                    _buildInfoRow('Rating', '${provider['average_rating'] ?? '—'} (${provider['total_reviews']} reviews)'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (status == 'pending') ...[
              const Text('Actions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: state.isActionLoading ? null : () => _showRejectDialog(context, ref),
                      icon: const Icon(Icons.close),
                      label: const Text('Reject'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: state.isActionLoading ? null : () => _showApproveDialog(context, ref),
                      icon: const Icon(Icons.check),
                      label: const Text('Approve'),
                      style: ElevatedButton.styleFrom(backgroundColor: primaryColor, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14)),
                    ),
                  ),
                ],
              ),
            ] else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(12)),
                child: Text('This provider is already $status.', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 15)),
      ]),
    );
  }

  void _showApproveDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Approve Provider?'),
        content: Text('Are you sure you want to approve $providerName? They will be eligible to receive customer requests.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(adminNotifierProvider.notifier).approveProvider(providerId);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Provider approved successfully!'), backgroundColor: Color(0xFF006859)));
                Navigator.pop(context); // Go back to dashboard
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF006859)),
            child: const Text('Confirm Approve'),
          ),
        ],
      ),
    );
  }

  void _showRejectDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reject Provider?'),
        content: Text('Are you sure you want to reject $providerName? They will not be able to receive requests.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(adminNotifierProvider.notifier).rejectProvider(providerId);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Provider rejected.'), backgroundColor: Colors.red));
                Navigator.pop(context); // Go back to dashboard
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Confirm Reject'),
          ),
        ],
      ),
    );
  }
}
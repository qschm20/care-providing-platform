import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/provider_request_model.dart';
import '../providers/provider_requests_provider.dart';

class ProviderRequestDetailScreen extends ConsumerWidget {
  final ProviderRequestModel request;

  const ProviderRequestDetailScreen({super.key, required this.request});

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'in_progress':
        return Colors.purple;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const primaryColor = Color(0xFF006859);
    final state = ref.watch(providerRequestsProvider);
    final statusColor = _getStatusColor(request.status);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Request Details', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          request.category.replaceAll('_', ' ').toUpperCase(),
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: primaryColor),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            request.status.toUpperCase(),
                            style: TextStyle(fontSize: 12, color: statusColor, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    _buildInfoRow(Icons.calendar_today, 'Date', request.serviceDate.toLocal().toString().split(' ')[0]),
                    const SizedBox(height: 12),
                    _buildInfoRow(Icons.access_time, 'Time', '${request.startTime.substring(0, 5)} - ${request.endTime.substring(0, 5)}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            const Text('Customer Requirements', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
            const SizedBox(height: 12),
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: request.requirements.entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            entry.key.replaceAll('_', ' ').toUpperCase(),
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            entry.value.toString(),
                            style: const TextStyle(fontSize: 15, color: Colors.black87),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 30),

            if (state.isActionLoading)
              const Center(child: CircularProgressIndicator(color: primaryColor))
            else if (request.status == 'pending')
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _showDeclineDialog(context, ref),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: Colors.red, width: 1.5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Decline', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _showAcceptDialog(context, ref),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Accept', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),
                ],
              )
            else if (request.status == 'confirmed')
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _showStartDialog(context, ref),
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Start Service', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              )
            else if (request.status == 'in_progress')
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _showCompleteDialog(context, ref),
                  icon: const Icon(Icons.check_circle),
                  label: const Text('Mark as Completed', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              )
            else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: request.status == 'completed' ? Colors.green.shade100 : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Request ${request.status.toUpperCase()}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: request.status == 'completed' ? Colors.green.shade800 : Colors.grey.shade800,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade600),
        const SizedBox(width: 12),
        Text('$label: ', style: const TextStyle(fontSize: 15, color: Colors.grey, fontWeight: FontWeight.w500)),
        Text(value, style: const TextStyle(fontSize: 15, color: Colors.black87, fontWeight: FontWeight.bold)),
      ],
    );
  }

  void _showAcceptDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Accept Request?'),
        content: const Text('By accepting, you confirm you are available to provide this care service.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(providerRequestsProvider.notifier).acceptRequest(request.id).then((_) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Request accepted successfully!'), backgroundColor: Color(0xFF006859)),
                  );
                  Navigator.pop(context); 
                }
              });
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF006859)),
            child: const Text('Confirm Accept'),
          ),
        ],
      ),
    );
  }

  void _showDeclineDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Decline Request?'),
        content: const Text('This request will remain available for other providers.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(providerRequestsProvider.notifier).declineRequest(request.id).then((_) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Request declined.'), backgroundColor: Colors.red),
                  );
                  Navigator.pop(context); 
                }
              });
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Confirm Decline'),
          ),
        ],
      ),
    );
  }

  // ✅ FIX: Removed 'final success =' since startRequest returns void
  void _showStartDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Start Service?'),
        content: const Text('This will notify the customer that you have arrived and begun the care service.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(providerRequestsProvider.notifier).startRequest(request.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Service started!'), backgroundColor: Color(0xFF006859)),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF006859)),
            child: const Text('Confirm Start'),
          ),
        ],
      ),
    );
  }

  // ✅ FIX: Removed 'final success =' since completeRequest returns void
  void _showCompleteDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Complete Service?'),
        content: const Text('Mark this care request as fully completed?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(providerRequestsProvider.notifier).completeRequest(request.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Service completed successfully!'), backgroundColor: Colors.blue),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            child: const Text('Confirm Complete'),
          ),
        ],
      ),
    );
  }
}
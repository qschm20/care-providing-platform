import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/provider_requests_provider.dart';
import 'provider_request_detail_screen.dart';

class ProviderRequestsScreen extends ConsumerStatefulWidget {
  const ProviderRequestsScreen({super.key});

  @override
  ConsumerState<ProviderRequestsScreen> createState() => _ProviderRequestsScreenState();
}

class _ProviderRequestsScreenState extends ConsumerState<ProviderRequestsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(providerRequestsProvider.notifier).fetchRequests();
    });
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF006859);
    final state = ref.watch(providerRequestsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Matching Requests', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: primaryColor),
            onPressed: () => ref.read(providerRequestsProvider.notifier).fetchRequests(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(providerRequestsProvider.notifier).fetchRequests(),
        child: state.isLoading
            ? const Center(child: CircularProgressIndicator(color: primaryColor))
            : state.error != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline, color: Colors.red, size: 48),
                          const SizedBox(height: 16),
                          Text('Error: ${state.error}', textAlign: TextAlign.center, style: const TextStyle(color: Colors.red)),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => ref.read(providerRequestsProvider.notifier).fetchRequests(),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  )
                : state.requests.isEmpty
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Text(
                            'No matching care requests available right now.\nCheck back later!',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey, fontSize: 16),
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: state.requests.length,
                        itemBuilder: (context, index) {
                          final request = state.requests[index];
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
                                    builder: (context) => ProviderRequestDetailScreen(request: request),
                                  ),
                                ).then((_) => ref.read(providerRequestsProvider.notifier).fetchRequests());
                              },
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
                                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: primaryColor),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: Colors.orange.shade100,
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            request.status.toUpperCase(),
                                            style: TextStyle(fontSize: 10, color: Colors.orange.shade800, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                                        const SizedBox(width: 8),
                                        Text(
                                          request.serviceDate.toLocal().toString().split(' ')[0],
                                          style: const TextStyle(fontSize: 14, color: Colors.black87),
                                        ),
                                        const SizedBox(width: 16),
                                        const Icon(Icons.access_time, size: 14, color: Colors.grey),
                                        const SizedBox(width: 8),
                                        Text(
                                          '${request.startTime.substring(0, 5)} - ${request.endTime.substring(0, 5)}',
                                          style: const TextStyle(fontSize: 14, color: Colors.black87),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    const Text(
                                      'Requirements:',
                                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _formatRequirements(request.requirements),
                                      style: const TextStyle(fontSize: 13, color: Colors.black87, height: 1.4),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
      ),
    );
  }

  // Helper to format the JSON requirements map into a readable string
  String _formatRequirements(Map<String, dynamic> reqs) {
    if (reqs.isEmpty) return 'No specific requirements listed.';
    return reqs.entries.map((e) => '${e.key}: ${e.value}').join('\n');
  }
}
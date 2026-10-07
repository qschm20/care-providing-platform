import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/admin_provider.dart';
import '../../auth/providers/auth_provider.dart';
import 'admin_provider_detail_screen.dart';

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    // ✅ Force a fresh fetch of ONLY pending providers when the screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(adminNotifierProvider.notifier).fetchProviders(status: 'pending');
    });
  }

  // ✅ Manual refresh function for Pull-to-Refresh
  Future<void> _refreshData() async {
    await ref.read(adminNotifierProvider.notifier).fetchProviders(status: 'pending');
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF006859);
    final state = ref.watch(adminNotifierProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Admin Dashboard', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: primaryColor,
        actions: [
          // ✅ Add a manual refresh button in the app bar
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
            tooltip: 'Refresh List',
          ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator(color: primaryColor))
          : state.error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(state.error!, style: const TextStyle(color: Colors.red), textAlign: TextAlign.center),
                  ),
                )
              : RefreshIndicator(
                  // ✅ Pull down to refresh
                  onRefresh: _refreshData,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      // Summary Card
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildStatColumn('Pending', '${state.providers.length}', Colors.orange),
                              Container(height: 40, width: 1, color: Colors.grey.shade300),
                              _buildStatColumn(
                                'Action Required', 
                                state.providers.isNotEmpty ? 'Yes' : 'No', 
                                primaryColor,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text('Pending Verification', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      
                      if (state.providers.isEmpty)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(32),
                            child: Text('No pending providers.', style: TextStyle(color: Colors.grey, fontSize: 16)),
                          ),
                        )
                      else
                        // ✅ Map through the providers. The backend ALREADY filtered this to ONLY 'pending'.
                        ...state.providers.map((provider) => Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(16),
                                leading: CircleAvatar(
                                  backgroundColor: primaryColor.withOpacity(0.1), 
                                  child: const Icon(Icons.person, color: primaryColor),
                                ),
                                title: Text(provider['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 4),
                                    Text(provider['bio'] ?? 'No bio provided', maxLines: 2, overflow: TextOverflow.ellipsis),
                                    const SizedBox(height: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.orange.shade100, 
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: const Text(
                                        'PENDING', 
                                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.orange),
                                      ),
                                    ),
                                  ],
                                ),
                                trailing: const Icon(Icons.chevron_right),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AdminProviderDetailScreen(
                                        providerId: provider['provider_id'], 
                                        providerName: provider['name'],
                                      ),
                                    ),
                                  ).then((_) {
                                    // ✅ Automatically refresh the list when returning from the detail screen!
                                    _refreshData();
                                  });
                                },
                              ),
                            )),
                    ],
                  ),
                ),
    );
  }

  Widget _buildStatColumn(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}
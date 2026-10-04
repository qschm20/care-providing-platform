import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/care_request_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../review/providers/review_provider.dart'; // ✅ Added
import '../../review/repositories/review_repository.dart'; // ✅ Added
import 'submit_review_screen.dart'; // ✅ Added

class MyCareRequestsScreen extends ConsumerStatefulWidget {
  const MyCareRequestsScreen({super.key});

  @override
  ConsumerState<MyCareRequestsScreen> createState() => _MyCareRequestsScreenState();
}

class _MyCareRequestsScreenState extends ConsumerState<MyCareRequestsScreen> {
  List<dynamic> _requests = [];
  bool _isLoading = true;
  String? _errorMessage;
  
  // ✅ NEW: Track which requests have been reviewed
  Set<String> _reviewedRequestIds = {};
  bool _isLoadingReviews = false;

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final token = ref.read(authProvider).token;
    if (token == null) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'You must be logged in';
        _isLoading = false;
      });
      return;
    }

    final repository = ref.read(careRequestRepositoryProvider);
    final result = await repository.getMyRequests(token);

    if (!mounted) return;

    if (result.success) {
      setState(() {
        _requests = result.data?['requests'] ?? [];
        _isLoading = false;
      });
      // ✅ NEW: After loading requests, check which completed ones have reviews
      _checkReviewStatuses(token);
    } else {
      setState(() {
        _errorMessage = result.errorMessage;
        _isLoading = false;
      });
    }
  }

  // ✅ NEW: Helper to check review status for completed requests
  Future<void> _checkReviewStatuses(String token) async {
    setState(() => _isLoadingReviews = true);
    final reviewRepo = ref.read(reviewRepositoryProvider);
    Set<String> reviewedIds = {};

    for (var request in _requests) {
      if (request['status'] == 'completed') {
        try {
          bool hasReview = await reviewRepo.hasReview(token: token, careRequestId: request['id']);
          if (hasReview) {
            reviewedIds.add(request['id']);
          }
        } catch (e) {
          // Ignore errors for individual checks
        }
      }
    }

    if (mounted) {
      setState(() {
        _reviewedRequestIds = reviewedIds;
        _isLoadingReviews = false;
      });
    }
  }

  String _formatCategoryName(String category) {
    return category
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'pending': return Colors.orange;
      case 'confirmed': return Colors.blue;
      case 'in_progress': return Colors.purple;
      case 'completed': return Colors.green;
      case 'cancelled': return Colors.red;
      default: return Colors.grey;
    }
  }

  void _showCancelDialog(BuildContext context, String requestId) {
    final token = ref.read(authProvider).token;
    if (token == null) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel Request?'),
        content: const Text('Are you sure you want to cancel this care request? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('No, Keep It')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx); 
              final success = await ref.read(careRequestNotifierProvider.notifier).cancelRequest(requestId, token);
              if (!mounted) return;
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Request cancelled successfully.'), backgroundColor: Colors.green),
                );
                _loadRequests(); 
              } else {
                final errorMsg = ref.read(careRequestNotifierProvider).errorMessage ?? 'Failed to cancel request';
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(errorMsg), backgroundColor: Colors.red),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF006859);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('My Care Requests'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: primaryColor,
      ),
      body: RefreshIndicator(
        onRefresh: _loadRequests,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: primaryColor))
            : _errorMessage != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text(_errorMessage!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.red)),
                    ),
                  )
                : _requests.isEmpty
                    ? ListView(
                        children: const [
                          SizedBox(height: 100),
                          Center(child: Text('No care requests yet', style: TextStyle(color: Colors.grey, fontSize: 16))),
                        ],
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _requests.length,
                        itemBuilder: (context, index) {
                          final request = _requests[index];
                          final status = request['status'] ?? 'pending';
                          final requestId = request['id'];
                          final isReviewed = _reviewedRequestIds.contains(requestId);

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2))],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(_formatCategoryName(request['category']), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(color: _statusColor(status).withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
                                      child: Text(status.toUpperCase(), style: TextStyle(color: _statusColor(status), fontWeight: FontWeight.bold, fontSize: 11)),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text('Date: ${request['service_date']}', style: const TextStyle(fontSize: 13, color: Colors.grey)),
                                Text('Time: ${request['start_time']} - ${request['end_time']}', style: const TextStyle(fontSize: 13, color: Colors.grey)),
                                
                                const SizedBox(height: 16),
                                
                                // ✅ Action Buttons Logic
                                if (status == 'pending' || status == 'confirmed')
                                  SizedBox(
                                    width: double.infinity,
                                    child: OutlinedButton.icon(
                                      onPressed: () => _showCancelDialog(context, requestId),
                                      icon: const Icon(Icons.cancel, size: 18),
                                      label: const Text('Cancel Request'),
                                      style: OutlinedButton.styleFrom(foregroundColor: Colors.red, side: const BorderSide(color: Colors.red)),
                                    ),
                                  )
                                else if (status == 'completed')
                                  if (isReviewed)
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.green.shade200)),
                                      child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                                        Icon(Icons.check_circle, color: Colors.green, size: 20),
                                        SizedBox(width: 8),
                                        Text('Reviewed', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                                      ]),
                                    )
                                  else
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton.icon(
                                        onPressed: () async {
                                          // Navigate to review screen
                                          final result = await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => SubmitReviewScreen(
                                                careRequestId: requestId,
                                                providerName: 'Provider', // You can fetch provider name if needed
                                              ),
                                            ),
                                          );
                                          // If review was submitted successfully, refresh the list
                                          if (result == true && mounted) {
                                            _loadRequests();
                                          }
                                        },
                                        icon: const Icon(Icons.rate_review, size: 18),
                                        label: const Text('Leave a Review'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.amber.shade700,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(vertical: 12),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                        ),
                                      ),
                                    ),
                              ],
                            ),
                          );
                        },
                      ),
      ),
    );
  }
}
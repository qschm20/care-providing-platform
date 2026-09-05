import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/schedule_widget.dart';
import '../models/care_request_model.dart';
import '../providers/care_request_provider.dart';
import '../../auth/providers/auth_provider.dart';
import 'my_care_requests_screen.dart';

class ReviewRequestScreen extends ConsumerStatefulWidget {
  final String category;
  final String categoryDisplayName;
  final Map<String, dynamic> requirements;
  final ScheduleData schedule;

  const ReviewRequestScreen({
    super.key,
    required this.category,
    required this.categoryDisplayName,
    required this.requirements,
    required this.schedule,
  });

  @override
  ConsumerState<ReviewRequestScreen> createState() => _ReviewRequestScreenState();
}

class _ReviewRequestScreenState extends ConsumerState<ReviewRequestScreen> {
  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  String _to24HourString(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:'
        '${time.minute.toString().padLeft(2, '0')}:00';
  }

  String _formatFieldName(String key) {
    return key
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  Future<void> _handlePostRequest() async {
    final authState = ref.read(authProvider);
    final token = authState.token;

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be logged in')),
      );
      return;
    }

    final requestModel = CareRequestModel(
      category: widget.category,
      requirements: widget.requirements,
      serviceDate: widget.schedule.date!,
      startTime: _to24HourString(widget.schedule.startTime!),
      endTime: _to24HourString(widget.schedule.endTime!),
    );

    final success = await ref
        .read(careRequestNotifierProvider.notifier)
        .submitRequest(requestModel, token);

    if (!mounted) return;

    if (success) {
      ref.read(careRequestNotifierProvider.notifier).reset();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Care request posted successfully!')),
      );
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const MyCareRequestsScreen()),
        (route) => route.isFirst,
      );
    } else {
      final errorMessage = ref.read(careRequestNotifierProvider).errorMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage ?? 'Failed to post request')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF006859);
    final submissionState = ref.watch(careRequestNotifierProvider);
    final isLoading = submissionState.status == SubmissionStatus.loading;

    return Scaffold(
      appBar: AppBar(title: const Text('Review Request')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.teal.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.category, color: primaryColor),
                    const SizedBox(width: 10),
                    Text(
                      widget.categoryDisplayName,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Text('Requirements', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ...widget.requirements.entries.map(
                (entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 140,
                        child: Text(
                          _formatFieldName(entry.key),
                          style: const TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          entry.value.toString(),
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Text('Schedule', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(
                '${widget.schedule.date!.day}/${widget.schedule.date!.month}/${widget.schedule.date!.year}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              Text(
                '${_formatTime(widget.schedule.startTime!)} - ${_formatTime(widget.schedule.endTime!)}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: isLoading ? null : () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('Back / Edit'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _handlePostRequest,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Text('Post Request', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
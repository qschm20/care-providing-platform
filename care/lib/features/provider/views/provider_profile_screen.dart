import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/provider_profile_provider.dart';

class ProviderProfileScreen extends ConsumerStatefulWidget {
  const ProviderProfileScreen({super.key});

  @override
  ConsumerState<ProviderProfileScreen> createState() => _ProviderProfileScreenState();
}

class _ProviderProfileScreenState extends ConsumerState<ProviderProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _bioController;
  late TextEditingController _serviceAreaController;

  @override
  void initState() {
    super.initState();
    _bioController = TextEditingController();
    _serviceAreaController = TextEditingController();
    
    // Fetch profile on load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(providerProfileProvider.notifier).fetchProfile();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Update controllers when profile data changes
    final profile = ref.read(providerProfileProvider).profile;
    if (profile != null) {
      _bioController.text = profile['bio'] ?? '';
      _serviceAreaController.text = profile['service_area'] ?? '';
    }
  }

  @override
  void dispose() {
    _bioController.dispose();
    _serviceAreaController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref.read(providerProfileProvider.notifier).updateProfile(
          _bioController.text.trim(),
          _serviceAreaController.text.trim(),
        );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!'), backgroundColor: Colors.teal),
      );
    } else {
      final error = ref.read(providerProfileProvider).error ?? 'Failed to update profile';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _submitVerification() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Submit for Verification?'),
        content: const Text('Are you sure you want to submit your profile for admin review? You will not be able to edit it while it is pending.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Submit')),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final success = await ref.read(providerProfileProvider.notifier).submitVerification();
      
      if (!mounted) return;
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Submitted for verification!'), backgroundColor: Colors.teal),
        );
      } else {
        final error = ref.read(providerProfileProvider).error ?? 'Failed to submit';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF006859);
    final profileState = ref.watch(providerProfileProvider);
    final profile = profileState.profile;
    final status = profile?['verification_status'] ?? 'pending';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('My Profile', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: profileState.isLoading && profile == null
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Verification Status Banner
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: status == 'approved' ? Colors.green.shade50 : (status == 'rejected' ? Colors.red.shade50 : Colors.orange.shade50),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: status == 'approved' ? Colors.green : (status == 'rejected' ? Colors.red : Colors.orange),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              status == 'approved' ? Icons.verified_user : (status == 'rejected' ? Icons.cancel : Icons.pending),
                              color: status == 'approved' ? Colors.green : (status == 'rejected' ? Colors.red : Colors.orange),
                              size: 32,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    status == 'approved' ? 'Verified Provider' : (status == 'rejected' ? 'Verification Rejected' : 'Pending Verification'),
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: status == 'approved' ? Colors.green : (status == 'rejected' ? Colors.red : Colors.orange),
                                    ),
                                  ),
                                  const Text('Admin review required', style: TextStyle(fontSize: 12, color: Colors.grey)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Bio Field
                      const Text('Professional Bio', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _bioController,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          hintText: 'Describe your experience, qualifications, and care philosophy...',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) return 'Please enter your bio';
                          if (value.trim().length < 20) return 'Bio must be at least 20 characters';
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      // Service Area Field
                      const Text('Service Area', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _serviceAreaController,
                        decoration: const InputDecoration(
                          hintText: 'e.g., Kathmandu, Lalitpur, Bhaktapur',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) return 'Please enter your service area';
                          return null;
                        },
                      ),
                      const SizedBox(height: 32),

                      // Action Buttons
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: profileState.isLoading ? null : _saveProfile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: profileState.isLoading
                              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : const Text('Save Profile', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: status == 'pending' || status == 'approved' ? null : _submitVerification,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: primaryColor,
                            side: const BorderSide(color: primaryColor),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text('Submit for Verification', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
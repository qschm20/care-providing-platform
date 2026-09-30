class ProviderRequestModel {
  final String id;
  final String customerId;
  final String? providerId;
  final String category;
  final Map<String, dynamic> requirements;
  final DateTime serviceDate;
  final String startTime;
  final String endTime;
  final String status;
  final DateTime createdAt;

  ProviderRequestModel({
    required this.id,
    required this.customerId,
    this.providerId,
    required this.category,
    required this.requirements,
    required this.serviceDate,
    required this.startTime,
    required this.endTime,
    required this.status,
    required this.createdAt,
  });

  factory ProviderRequestModel.fromJson(Map<String, dynamic> json) {
    return ProviderRequestModel(
      id: json['id'],
      customerId: json['customer_id'],
      providerId: json['provider_id'],
      category: json['category'],
      requirements: json['requirements'] as Map<String, dynamic>,
      serviceDate: DateTime.parse(json['service_date']),
      startTime: json['start_time'],
      endTime: json['end_time'],
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
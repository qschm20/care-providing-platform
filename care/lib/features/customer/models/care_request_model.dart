class CareRequestModel {
  final String category;
  final Map<String, dynamic> requirements;
  final DateTime serviceDate;
  final String startTime;
  final String endTime;

  CareRequestModel({
    required this.category,
    required this.requirements,
    required this.serviceDate,
    required this.startTime,
    required this.endTime,
  });

  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'requirements': requirements,
      'service_date': '${serviceDate.year.toString().padLeft(4, '0')}-'
          '${serviceDate.month.toString().padLeft(2, '0')}-'
          '${serviceDate.day.toString().padLeft(2, '0')}',
      'start_time': startTime,
      'end_time': endTime,
    };
  }
}
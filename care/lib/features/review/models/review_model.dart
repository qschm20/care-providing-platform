class ReviewModel {
  final String id;
  final String careRequestId;
  final String customerName;
  final int rating;
  final String comment;
  final DateTime createdAt;

  ReviewModel({
    required this.id,
    required this.careRequestId,
    required this.customerName,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'],
      careRequestId: json['care_request_id'],
      customerName: json['customer_name'] ?? 'Anonymous',
      rating: json['rating'],
      comment: json['comment'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

// Helper model for the Provider Reviews response (includes average rating)
class ProviderReviewsModel {
  final String providerId;
  final double? averageRating;
  final int totalReviews;
  final List<ReviewModel> reviews;

  ProviderReviewsModel({
    required this.providerId,
    required this.averageRating,
    required this.totalReviews,
    required this.reviews,
  });

  factory ProviderReviewsModel.fromJson(Map<String, dynamic> json) {
    List<ReviewModel> reviewsList = [];
    if (json['reviews'] != null) {
      reviewsList = (json['reviews'] as List).map((e) => ReviewModel.fromJson(e)).toList();
    }

    return ProviderReviewsModel(
      providerId: json['provider_id'],
      averageRating: json['average_rating']?.toDouble(),
      totalReviews: json['total_reviews'] ?? 0,
      reviews: reviewsList,
    );
  }
}
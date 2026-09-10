class ProviderSearchModel {
  final String providerId;
  final String name;
  final String? bio;
  final String? serviceArea;
  final String verificationStatus;
  final List<ProviderSearchServiceItem> services;

  ProviderSearchModel({
    required this.providerId,
    required this.name,
    this.bio,
    this.serviceArea,
    required this.verificationStatus,
    required this.services,
  });

  factory ProviderSearchModel.fromJson(Map<String, dynamic> json) {
    return ProviderSearchModel(
      providerId: json['provider_id'],
      name: json['name'],
      bio: json['bio'],
      serviceArea: json['service_area'],
      verificationStatus: json['verification_status'],
      services: (json['services'] as List)
          .map((e) => ProviderSearchServiceItem.fromJson(e))
          .toList(),
    );
  }
}

class ProviderSearchServiceItem {
  final String id;
  final String title;
  final String category;
  final String description;
  final double price;
  final String pricingUnit;
  final List<String> skills;

  ProviderSearchServiceItem({
    required this.id,
    required this.title,
    required this.category,
    required this.description,
    required this.price,
    required this.pricingUnit,
    required this.skills,
  });

  factory ProviderSearchServiceItem.fromJson(Map<String, dynamic> json) {
    return ProviderSearchServiceItem(
      id: json['id'],
      title: json['title'],
      category: json['category'],
      description: json['description'],
    //   price: (json['price'] as num).toDouble(),
      price: double.parse(json['price'].toString()),
      pricingUnit: json['pricing_unit'],
      skills: (json['skills'] as List?)?.map((e) => e.toString()).toList() ?? [],
    );
  }
}
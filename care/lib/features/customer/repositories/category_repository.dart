import '../models/care_category.dart';

class CategoryRepository {
  List<CareCategory> getCategories() {
    return careCategories;
  }
}
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/care_category.dart';
import '../repositories/category_repository.dart';

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  return CategoryRepository();
});

final categoryProvider = Provider<List<CareCategory>>((ref) {
  final repository = ref.watch(categoryRepositoryProvider);
  return repository.getCategories();
});
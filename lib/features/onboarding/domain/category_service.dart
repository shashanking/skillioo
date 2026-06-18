import '../../../core/config/api_config.dart';
import '../../../core/services/base_service_provider.dart';

class CategoryService extends BaseServiceProvider {
  CategoryService({super.client}) : super(baseUrl: ApiConfig.customerBaseUrl);

  // Get all categories
  Future<Map<String, dynamic>> getCategories() async {
    return get(ApiConfig.category);
  }

  // Create a new category
  Future<Map<String, dynamic>> createCategory(String name) async {
    return post(ApiConfig.category, {'name': name});
  }

  // Get subcategories for a category
  Future<Map<String, dynamic>> getSubCategories(String categoryId) async {
    return getWithParams(ApiConfig.subCategory, {'categoryId': categoryId});
  }

  // Create a new subcategory
  Future<Map<String, dynamic>> createSubCategory({
    required String name,
    required String categoryId,
  }) async {
    return post(ApiConfig.subCategory, {
      'name': name,
      'categoryId': categoryId,
    });
  }
}

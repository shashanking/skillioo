import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/session_prefs.dart';
import '../../../core/services/shared_http_client.dart';
import '../domain/category_models.dart';
import '../domain/category_service.dart';

final categoryServiceProvider = Provider<CategoryService>((ref) {
  return CategoryService(client: ref.watch(sharedHttpClientProvider));
});

/// Fetches all category names from the API.
/// Cached by Riverpod — only one network call per app session.
final categoryNamesProvider = FutureProvider<List<String>>((ref) async {
  final service = ref.watch(categoryServiceProvider);
  final token = await SessionPrefs.instance.getAccessToken();
  if (token.isNotEmpty) {
    service.setAuthToken(token);
  }

  final response = await service.getCategories();
  final status = response['status'] as int? ?? 0;
  if (status != 200) return const [];

  final data = response['data'] as List<dynamic>? ?? [];
  final categories = data
      .map((json) => Category.fromJson(json as Map<String, dynamic>))
      .where((c) => !c.deleted)
      .map((c) => c.name)
      .toList()
    ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

  return categories;
});

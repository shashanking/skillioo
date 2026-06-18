import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/session_prefs.dart';
import '../../../core/services/shared_http_client.dart';
import '../domain/profile_list_service.dart';
import 'notifiers/profile_list_notifier.dart';
import 'states/profile_list_state.dart';

final dashboardCityFilterProvider = StateProvider<String?>((ref) => null);

final profileListServiceProvider = Provider<ProfileListService>((ref) {
  return ProfileListService(client: ref.watch(sharedHttpClientProvider));
});

final profileListNotifierProvider =
    StateNotifierProvider<ProfileListNotifier, ProfileListState>((ref) {
      final service = ref.watch(profileListServiceProvider);
      return ProfileListNotifier(service);
    });

/// Fetches real profiles filtered by [category]. Used by the messages
/// search ("pick a category → see creators in it").
///
/// Deliberately separate from [profileListNotifierProvider]: that notifier
/// is shared with the dashboard feed, so loading a category-filtered set
/// into it would corrupt the dashboard's listing. This isolated fetch
/// keeps the two independent.
final chatCategoryProfilesProvider =
    FutureProvider.family<List<ProfileItem>, String>((ref, category) async {
  if (category.trim().isEmpty) return const [];
  final accessToken = await SessionPrefs.instance.getAccessToken();
  if (accessToken.isEmpty) return const [];

  final service = ref.watch(profileListServiceProvider);
  final response = await service.getProfiles(
    accessToken: accessToken,
    perPage: 50,
    page: 1,
    category: category,
  );

  final status = response['status'] as int?;
  final success = response['success'] as bool? ?? (status == 200);
  if (status != 200 && !success) return const [];

  final data = response['data'] as Map<String, dynamic>? ?? {};
  final items = data['items'] as List<dynamic>? ?? [];
  final currentUserId = await SessionPrefs.instance.getProfileId();
  return items
      .whereType<Map<String, dynamic>>()
      .where((json) {
        final id = json['id'] as String? ?? '';
        return id.isNotEmpty && id != currentUserId;
      })
      .map(ProfileItem.fromJson)
      .toList();
});

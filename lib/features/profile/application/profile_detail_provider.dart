import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/session_prefs.dart';
import '../../../core/services/shared_http_client.dart';
import '../domain/profile_service.dart';

/// Fetches a single profile's full detail (`GET /v1/profile/:id`) by id.
///
/// The profile-list endpoint (`GET /v1/profile`) returns only a trimmed
/// payload — no `bio`, no `portfolioId` — so any UI that needs those must
/// fetch the full profile through this provider rather than reading the
/// list's [ProfileItem].
///
/// Returns the response `data` map, or an empty map on any failure so
/// callers can render a graceful empty state.
final profileDetailProvider =
    FutureProvider.family<Map<String, dynamic>, String>((ref, profileId) async {
  final accessToken = await SessionPrefs.instance.getAccessToken();
  if (accessToken.isEmpty || profileId.isEmpty) {
    return <String, dynamic>{};
  }
  try {
    final service = ProfileService(client: ref.watch(sharedHttpClientProvider));
    final response = await service.getProfile(
      profileId: profileId,
      accessToken: accessToken,
    );
    final data = response['data'];
    if (data is Map<String, dynamic>) return data;
  } catch (_) {
    // Network / shape failure — fall through to an empty map.
  }
  return <String, dynamic>{};
});

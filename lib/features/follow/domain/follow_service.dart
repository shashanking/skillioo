import '../../../core/config/api_config.dart';
import '../../../core/services/base_service_provider.dart';

class FollowService extends BaseServiceProvider {
  FollowService({super.client}) : super(baseUrl: ApiConfig.postBaseUrl);

  // ── Follow a user ──

  Future<Map<String, dynamic>> followUser(String followingId) async {
    return post(ApiConfig.follow, {'followingId': followingId});
  }

  // ── Unfollow a user ──

  Future<Map<String, dynamic>> unfollowUser(String followingId) async {
    return delete('${ApiConfig.follow}/$followingId');
  }

  // ── Check if following a user ──

  Future<Map<String, dynamic>> checkFollowing(String followingId) async {
    return getWithParams(ApiConfig.follow, {'followingId': followingId});
  }

  // ── Get followers ──

  Future<Map<String, dynamic>> getFollowers({
    int page = 1,
    int perPage = 10,
  }) async {
    return getWithParams(ApiConfig.followFollowers, {
      'page': page.toString(),
      'perPage': perPage.toString(),
    });
  }

  // ── Get following ──

  Future<Map<String, dynamic>> getFollowing({
    int page = 1,
    int perPage = 10,
  }) async {
    return getWithParams(ApiConfig.followFollowing, {
      'page': page.toString(),
      'perPage': perPage.toString(),
    });
  }

  // ── Get follow counts ──

  Future<Map<String, dynamic>> getFollowCount() async {
    return get(ApiConfig.followCount);
  }
}

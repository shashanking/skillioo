import '../../../core/config/api_config.dart';
import '../../../core/services/base_service_provider.dart';

class PostService extends BaseServiceProvider {
  PostService() : super(baseUrl: ApiConfig.postBaseUrl);

  // ── Short User ──

  Future<Map<String, dynamic>> createShortUser(
    Map<String, dynamic> data,
  ) async {
    return post(ApiConfig.shortUser, data);
  }

  Future<Map<String, dynamic>> updateShortUser(
    Map<String, dynamic> data,
  ) async {
    return put(ApiConfig.shortUser, data);
  }

  Future<Map<String, dynamic>> deleteShortUser(String referenceId) async {
    return delete('${ApiConfig.shortUser}/$referenceId');
  }

  Future<Map<String, dynamic>> getShortUser({String? nickName}) async {
    if (nickName != null) {
      return getWithParams(ApiConfig.shortUser, {'nickName': nickName});
    }
    return get(ApiConfig.shortUser);
  }

  // ── Media ──

  Future<Map<String, dynamic>> createMedia(Map<String, dynamic> data) async {
    return post(ApiConfig.media, data);
  }

  Future<Map<String, dynamic>> getMediaById(String id) async {
    return get('${ApiConfig.media}/$id');
  }

  Future<Map<String, dynamic>> getMediaByUser(
    String userReferenceId, {
    required String service,
    String? mediaType,
    int limit = 10,
    int page = 1,
  }) async {
    final params = <String, String>{
      'service': service,
      'limit': '$limit',
      'page': '$page',
    };
    if (mediaType != null) params['mediaType'] = mediaType;
    return getWithParams('${ApiConfig.media}/user/$userReferenceId', params);
  }

  Future<Map<String, dynamic>> getMedia({
    required String mediaType,
    int limit = 10,
    int page = 1,
  }) async {
    final params = <String, String>{'limit': '$limit', 'page': '$page'};
    params['mediaType'] = mediaType;
    return getWithParams(ApiConfig.media, params);
  }

  Future<Map<String, dynamic>> updateMedia(Map<String, dynamic> data) async {
    return put(ApiConfig.media, data);
  }

  Future<Map<String, dynamic>> deleteMedia(
    String id, {
    bool forceDelete = false,
  }) async {
    return delete('${ApiConfig.media}/$id?forceDelete=$forceDelete');
  }

  // ── Comment ──

  Future<Map<String, dynamic>> createComment(Map<String, dynamic> data) async {
    return post(ApiConfig.comment, data);
  }

  Future<Map<String, dynamic>> getComments(
    String targetId, {
    int limit = 10,
    int page = 1,
  }) async {
    return getWithParams('${ApiConfig.comment}/$targetId', {
      'limit': '$limit',
      'page': '$page',
    });
  }

  Future<Map<String, dynamic>> updateComment(Map<String, dynamic> data) async {
    return put(ApiConfig.comment, data);
  }

  Future<Map<String, dynamic>> deleteComment(
    String id, {
    bool forceDelete = false,
  }) async {
    return delete('${ApiConfig.comment}/$id?forceDelete=$forceDelete');
  }

  // ── Reaction ──

  Future<Map<String, dynamic>> createReaction(Map<String, dynamic> data) async {
    return post(ApiConfig.reaction, data);
  }

  Future<Map<String, dynamic>> getReactions(
    String targetId, {
    int limit = 10,
    int page = 1,
  }) async {
    return getWithParams('${ApiConfig.reaction}/$targetId', {
      'limit': '$limit',
      'page': '$page',
    });
  }

  Future<Map<String, dynamic>> updateReaction(Map<String, dynamic> data) async {
    return put(ApiConfig.reaction, data);
  }

  Future<Map<String, dynamic>> deleteReaction(String id) async {
    return delete('${ApiConfig.reaction}/$id');
  }
}

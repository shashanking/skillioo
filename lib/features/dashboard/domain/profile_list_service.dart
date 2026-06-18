import 'dart:convert';

import '../../../core/config/api_config.dart';
import '../../../core/services/base_service_provider.dart';

class ProfileListService extends BaseServiceProvider {
  ProfileListService({super.client}) : super(baseUrl: ApiConfig.baseUrl);

  /// GET /v1/profile?perPage=10&page=1&category=Music&...
  /// Fetches paginated list of profiles with optional filters
  Future<Map<String, dynamic>> getProfiles({
    required String accessToken,
    int perPage = 20,
    int page = 1,
    String? category,
    String? subCategory,
    String? nickName,
    String? profileType,
    String? proficiency,
    String? city,
    String? country,
    String? status,
  }) async {
    setAuthToken(accessToken);

    final queryParams = <String, String>{
      'perPage': perPage.toString(),
      'page': page.toString(),
    };

    if (category != null && category.isNotEmpty) {
      queryParams['category'] = category;
    }
    if (subCategory != null && subCategory.isNotEmpty) {
      queryParams['subCategory'] = subCategory;
    }
    if (nickName != null && nickName.isNotEmpty) {
      queryParams['nickName'] = nickName;
    }
    if (profileType != null && profileType.isNotEmpty) {
      queryParams['profileType'] = profileType;
    }
    if (proficiency != null && proficiency.isNotEmpty) {
      queryParams['proficiency'] = proficiency;
    }
    if (city != null && city.isNotEmpty) {
      queryParams['city'] = city;
    }
    if (country != null && country.isNotEmpty) {
      queryParams['country'] = country;
    }
    if (status != null && status.isNotEmpty) {
      queryParams['status'] = status;
    }

    Map<String, dynamic> primary;
    try {
      setAuthToken(accessToken);
      primary = await getWithParams(ApiConfig.profile, queryParams);
    } catch (_) {
      primary = <String, dynamic>{};
    }

    final primaryStatus = primary['status'];
    final primaryMessage = (primary['message'] as String? ?? '').toLowerCase();
    final isRouteNotFound =
        primaryStatus == 404 || primaryMessage.contains('route not found');

    if (primary.isNotEmpty && !isRouteNotFound) {
      return primary;
    }

    try {
      final uri = Uri.parse(
        '$baseUrl/v1/profile',
      ).replace(queryParameters: queryParams);
      final response = await client.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return json.decode(response.body) as Map<String, dynamic>;
      }

      try {
        return json.decode(response.body) as Map<String, dynamic>;
      } catch (_) {
        return {
          'status': response.statusCode,
          'message': 'Failed to fetch profiles',
          'data': {'items': []},
        };
      }
    } catch (_) {
      return {
        'status': 500,
        'message': 'Failed to fetch profiles',
        'data': {'items': []},
      };
    }
  }
}

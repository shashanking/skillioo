import 'dart:io';

import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../../core/config/api_config.dart';

class DocumentService {
  final String baseUrl;
  final http.Client client;

  DocumentService({String? baseUrl, http.Client? client})
    : baseUrl = baseUrl ?? ApiConfig.baseUrl,
      client = client ?? http.Client();

  /// POST /document (multipart form-data)
  /// Uploads a document file with type and optional remarks.
  Future<Map<String, dynamic>> uploadDocument({
    required File file,
    required String type,
    String remarks = '',
    String? accessToken,
  }) async {
    final uri = Uri.parse('$baseUrl${ApiConfig.document}');
    final request = http.MultipartRequest('POST', uri);

    if (accessToken != null && accessToken.isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $accessToken';
    }
    request.fields['type'] = type;
    request.fields['remarks'] = remarks;
    request.files.add(await http.MultipartFile.fromPath('file', file.path));

    final streamedResponse = await client.send(request);
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return json.decode(response.body);
    } else if (response.statusCode == 413) {
      return {
        'success': false,
        'message': 'File is too large. Please choose a smaller file.',
      };
    } else {
      String message = 'Upload failed. Please try again.';
      try {
        final body = json.decode(response.body) as Map<String, dynamic>;
        message = body['message'] as String? ?? message;
      } catch (_) {}
      return {'success': false, 'message': message};
    }
  }

  /// GET /v1/document/:profileId
  /// Fetches documents (urls + type + id) for the given profile.
  Future<Map<String, dynamic>> getDocumentsForProfile({
    required String profileId,
    required String accessToken,
  }) async {
    final uri = Uri.parse('$baseUrl${ApiConfig.document}/$profileId');
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
        'success': false,
        'message': 'Failed to fetch documents. Please try again.',
      };
    }
  }

  /// GET /v1/document/?ids=uuid1,uuid2
  /// Fetch documents by their IDs.
  Future<Map<String, dynamic>> getDocumentsByIds({
    required List<String> ids,
    String? accessToken,
  }) async {
    final idsParam = ids.where((e) => e.trim().isNotEmpty).join(',');
    if (idsParam.isEmpty) {
      return {
        'success': false,
        'message': 'No document ids provided',
        'data': <dynamic>[],
      };
    }

    final uri = Uri.parse(
      '$baseUrl${ApiConfig.document}/',
    ).replace(queryParameters: {'ids': idsParam});

    final headers = <String, String>{'Content-Type': 'application/json'};
    if (accessToken != null && accessToken.isNotEmpty) {
      headers['Authorization'] = 'Bearer $accessToken';
    }

    final response = await client.get(uri, headers: headers);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return json.decode(response.body) as Map<String, dynamic>;
    }

    try {
      return json.decode(response.body) as Map<String, dynamic>;
    } catch (_) {
      return {
        'success': false,
        'message': 'Failed to fetch documents. Please try again.',
        'data': <dynamic>[],
      };
    }
  }

  Future<Map<String, dynamic>> updateProfilePicture({
    required String profileId,
    required String accessToken,
    required File file,
  }) async {
    final uri = Uri.parse('$baseUrl/v1/document/$profileId/profile-picture');
    final request = http.MultipartRequest('PUT', uri);
    request.headers['Authorization'] = 'Bearer $accessToken';
    request.files.add(await http.MultipartFile.fromPath('file', file.path));

    final streamedResponse = await client.send(request);
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return json.decode(response.body) as Map<String, dynamic>;
    }

    try {
      return json.decode(response.body) as Map<String, dynamic>;
    } catch (_) {
      return {
        'success': false,
        'message': 'Failed to update profile picture. Please try again.',
      };
    }
  }

  void dispose() {
    client.close();
  }
}

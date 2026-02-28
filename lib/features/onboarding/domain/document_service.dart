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
  }) async {
    final uri = Uri.parse('$baseUrl${ApiConfig.document}');
    final request = http.MultipartRequest('POST', uri);

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

  void dispose() {
    client.close();
  }
}

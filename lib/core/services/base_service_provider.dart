import 'package:http/http.dart' as http;
import 'dart:convert';

abstract class BaseServiceProvider {
  final String baseUrl;
  final http.Client client;
  String? _authToken;

  BaseServiceProvider({required this.baseUrl, http.Client? client})
    : client = client ?? http.Client();

  void setAuthToken(String token) => _authToken = token;
  void clearAuthToken() => _authToken = null;

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (_authToken != null) 'Authorization': 'Bearer $_authToken',
  };

  Future<Map<String, dynamic>> get(String endpoint) async {
    final response = await client.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: _headers,
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> getWithParams(
    String endpoint,
    Map<String, String> queryParams,
  ) async {
    final uri = Uri.parse(
      '$baseUrl$endpoint',
    ).replace(queryParameters: queryParams);
    final response = await client.get(uri, headers: _headers);
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    final response = await client.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: _headers,
      body: json.encode(data),
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> put(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    final response = await client.put(
      Uri.parse('$baseUrl$endpoint'),
      headers: _headers,
      body: json.encode(data),
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> patch(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    final response = await client.patch(
      Uri.parse('$baseUrl$endpoint'),
      headers: _headers,
      body: json.encode(data),
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> delete(String endpoint) async {
    final response = await client.delete(
      Uri.parse('$baseUrl$endpoint'),
      headers: _headers,
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> deleteWithBody(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    final request = http.Request('DELETE', Uri.parse('$baseUrl$endpoint'));
    request.headers.addAll(_headers);
    request.body = json.encode(data);
    final streamed = await client.send(request);
    final response = await http.Response.fromStream(streamed);
    return _handleResponse(response);
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return json.decode(response.body);
    }
    // For client errors that return a structured JSON body (e.g. 400, 409),
    // return the body so callers can read success/message fields.
    if (response.statusCode >= 400 && response.statusCode < 500) {
      try {
        return json.decode(response.body) as Map<String, dynamic>;
      } catch (_) {}
    }
    throw Exception('HTTP Error: ${response.statusCode}');
  }

  void dispose() {
    client.close();
  }
}

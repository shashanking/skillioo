import 'package:http/http.dart' as http;
import 'dart:convert';

abstract class BaseServiceProvider {
  final String baseUrl;
  final http.Client client;

  BaseServiceProvider({required this.baseUrl, http.Client? client})
    : client = client ?? http.Client();

  Future<Map<String, dynamic>> get(String endpoint) async {
    final response = await client.get(Uri.parse('$baseUrl$endpoint'));
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    final response = await client.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: {'Content-Type': 'application/json'},
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
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> delete(String endpoint) async {
    final response = await client.delete(Uri.parse('$baseUrl$endpoint'));
    return _handleResponse(response);
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return json.decode(response.body);
    } else {
      throw Exception('HTTP Error: ${response.statusCode}');
    }
  }

  void dispose() {
    client.close();
  }
}

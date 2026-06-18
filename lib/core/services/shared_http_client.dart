import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'retry_http_client.dart';

/// Single http.Client reused across all service providers.
/// This keeps TCP connections alive (HTTP keep-alive) and avoids
/// the overhead of creating a new client for every API call.
///
/// Wrapped with [RetryHttpClient] so GET/HEAD calls automatically retry
/// on 502/503/504 and transient network errors — critical for cold-start
/// scenarios where Customer MS sometimes returns 502 on the first request
/// after an idle period.
final sharedHttpClientProvider = Provider<http.Client>((ref) {
  final client = RetryHttpClient(http.Client());
  ref.onDispose(client.close);
  return client;
});

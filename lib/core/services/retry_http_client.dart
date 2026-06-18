import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// http.Client wrapper that retries on transient backend failures.
///
/// Retries on:
///   - HTTP 502 / 503 / 504 (proxy / upstream errors, very common on cold start)
///   - SocketException / TimeoutException (network / DNS hiccups)
///
/// Backoff is 400ms, then 1200ms (total worst-case ~1.6s before giving up).
/// Only idempotent verbs (GET, HEAD) are retried; POST / PUT / PATCH / DELETE
/// fall through unchanged so we never accidentally double-write.
class RetryHttpClient extends http.BaseClient {
  RetryHttpClient(this._inner, {this.maxRetries = 2});

  final http.Client _inner;
  final int maxRetries;

  static const _retryStatuses = {502, 503, 504};
  static const _delays = [
    Duration(milliseconds: 400),
    Duration(milliseconds: 1200),
  ];

  bool _isIdempotent(String method) {
    final m = method.toUpperCase();
    return m == 'GET' || m == 'HEAD';
  }

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    if (!_isIdempotent(request.method)) {
      return _inner.send(request);
    }

    for (var attempt = 0; attempt <= maxRetries; attempt++) {
      try {
        // http.BaseRequest is single-use, so clone it for each attempt.
        final cloned = _cloneRequest(request);
        final response = await _inner.send(cloned);
        if (_retryStatuses.contains(response.statusCode) &&
            attempt < maxRetries) {
          if (kDebugMode) {
            debugPrint(
              'RetryHttpClient: ${request.method} ${request.url} '
              'returned ${response.statusCode}, retrying '
              '(attempt ${attempt + 1}/$maxRetries)',
            );
          }
          // Drain the response body so the connection can be reused.
          await response.stream.drain<void>();
          await Future.delayed(_delays[attempt.clamp(0, _delays.length - 1)]);
          continue;
        }
        return response;
      } on SocketException catch (e) {
        if (attempt >= maxRetries) rethrow;
        if (kDebugMode) {
          debugPrint(
            'RetryHttpClient: ${request.method} ${request.url} '
            'SocketException: $e, retrying '
            '(attempt ${attempt + 1}/$maxRetries)',
          );
        }
        await Future.delayed(_delays[attempt.clamp(0, _delays.length - 1)]);
      } on TimeoutException catch (e) {
        if (attempt >= maxRetries) rethrow;
        if (kDebugMode) {
          debugPrint(
            'RetryHttpClient: ${request.method} ${request.url} '
            'TimeoutException: $e, retrying '
            '(attempt ${attempt + 1}/$maxRetries)',
          );
        }
        await Future.delayed(_delays[attempt.clamp(0, _delays.length - 1)]);
      }
    }

    // Shouldn't reach here, but fall through with one last attempt.
    return _inner.send(_cloneRequest(request));
  }

  http.BaseRequest _cloneRequest(http.BaseRequest req) {
    if (req is http.Request) {
      final clone = http.Request(req.method, req.url)
        ..headers.addAll(req.headers)
        ..followRedirects = req.followRedirects
        ..maxRedirects = req.maxRedirects
        ..persistentConnection = req.persistentConnection;
      if (req.bodyBytes.isNotEmpty) clone.bodyBytes = req.bodyBytes;
      return clone;
    }
    // For multipart and streamed requests, don't attempt to clone — the body
    // is a one-shot stream. These are rare on idempotent verbs anyway.
    return req;
  }

  @override
  void close() {
    _inner.close();
    super.close();
  }
}

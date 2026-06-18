import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/shared_http_client.dart';
import '../domain/call_service.dart';
import 'notifiers/call_notifier.dart';
import 'states/call_state.dart';

final callServiceProvider = Provider<CallService>((ref) {
  return CallService(client: ref.watch(sharedHttpClientProvider));
});

final callNotifierProvider = StateNotifierProvider<CallNotifier, CallState>((ref) {
  final service = ref.watch(callServiceProvider);
  return CallNotifier(service);
});

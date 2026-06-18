import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/shared_http_client.dart';
import '../domain/follow_service.dart';
import 'notifiers/follow_notifier.dart';
import 'states/follow_state.dart';

final followServiceProvider = Provider<FollowService>(
  (ref) => FollowService(client: ref.watch(sharedHttpClientProvider)),
);

final followNotifierProvider =
    StateNotifierProvider<FollowNotifier, FollowState>((ref) {
      final service = ref.watch(followServiceProvider);
      return FollowNotifier(service);
    });

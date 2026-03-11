import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/subscription_service.dart';
import 'notifiers/subscription_notifier.dart';
import 'states/subscription_state.dart';

final subscriptionServiceProvider = Provider<SubscriptionService>(
  (ref) => SubscriptionService(),
);

final subscriptionNotifierProvider =
    StateNotifierProvider<SubscriptionNotifier, SubscriptionState>((ref) {
      final service = ref.watch(subscriptionServiceProvider);
      return SubscriptionNotifier(service);
    });

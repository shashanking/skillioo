import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/shared_http_client.dart';
import '../../payment/application/payment_providers.dart';
import '../domain/subscription_service.dart';
import 'notifiers/subscription_notifier.dart';
import 'states/subscription_state.dart';

final subscriptionServiceProvider = Provider<SubscriptionService>(
  (ref) => SubscriptionService(client: ref.watch(sharedHttpClientProvider)),
);

final subscriptionNotifierProvider =
    StateNotifierProvider<SubscriptionNotifier, SubscriptionState>((ref) {
      final service = ref.watch(subscriptionServiceProvider);
      final paymentService = ref.watch(paymentServiceProvider);
      return SubscriptionNotifier(service, paymentService);
    });

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/subscription_service.dart';

final subscriptionServiceProvider =
    Provider<SubscriptionService>((ref) => SubscriptionService());

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/shared_http_client.dart';
import '../domain/payment_service.dart';

final paymentServiceProvider =
    Provider<PaymentService>((ref) => PaymentService(client: ref.watch(sharedHttpClientProvider)));

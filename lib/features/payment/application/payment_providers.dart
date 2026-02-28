import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/payment_service.dart';

final paymentServiceProvider =
    Provider<PaymentService>((ref) => PaymentService());

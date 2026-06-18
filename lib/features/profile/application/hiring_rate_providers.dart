import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/session_prefs.dart';
import '../../../core/services/shared_http_client.dart';
import '../domain/hiring_rate_service.dart';
import 'notifiers/hiring_rate_notifier.dart';
import 'states/hiring_rate_state.dart';

final hiringRateServiceProvider = Provider<HiringRateService>((ref) {
  return HiringRateService(client: ref.watch(sharedHttpClientProvider));
});

final hiringRateNotifierProvider =
    StateNotifierProvider<HiringRateNotifier, HiringRateState>((ref) {
      final service = ref.watch(hiringRateServiceProvider);
      return HiringRateNotifier(service);
    });

final hiringRateProvider = FutureProvider.family<Map<String, dynamic>, String>((
  ref,
  portfolioId,
) async {
  final accessToken = await SessionPrefs.instance.getAccessToken();
  if (accessToken.isEmpty || portfolioId.isEmpty) {
    return <String, dynamic>{};
  }

  final service = ref.watch(hiringRateServiceProvider);
  // Backend returns HTTP 500 with `success:false, message:"Record not found"`
  // when the portfolio has no hiring rate yet. Treat that (and any other
  // transport/shape failure) as "no data" so the UI renders '-' for each row
  // instead of a blanket error.
  try {
    final response = await service.getHiringRate(
      portfolioId: portfolioId,
      accessToken: accessToken,
    );
    final data = response['data'];
    if (data is Map<String, dynamic>) return data;
    return <String, dynamic>{};
  } catch (_) {
    return <String, dynamic>{};
  }
});

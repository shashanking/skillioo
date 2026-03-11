import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/session_prefs.dart';
import '../domain/hiring_rate_service.dart';

final hiringRateServiceProvider = Provider<HiringRateService>((ref) {
  final service = HiringRateService();
  ref.onDispose(() => service.dispose());
  return service;
});

final hiringRateProvider = FutureProvider.family<Map<String, dynamic>, String>(
  (ref, portfolioId) async {
    final accessToken = await SessionPrefs.instance.getAccessToken();
    if (accessToken.isEmpty) {
      throw Exception('Not authenticated');
    }

    final service = ref.watch(hiringRateServiceProvider);
    final response = await service.getHiringRate(
      portfolioId: portfolioId,
      accessToken: accessToken,
    );

    final status = response['status'] as int? ?? 0;
    if (status != 200) {
      throw Exception(
        response['message'] as String? ?? 'Failed to fetch hiring rates',
      );
    }

    return response['data'] as Map<String, dynamic>? ?? <String, dynamic>{};
  },
);

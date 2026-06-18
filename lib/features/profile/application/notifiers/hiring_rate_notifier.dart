import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/session_prefs.dart';
import '../../domain/hiring_rate_service.dart';
import '../states/hiring_rate_state.dart';

class HiringRateNotifier extends StateNotifier<HiringRateState> {
  final HiringRateService _service;

  HiringRateNotifier(this._service) : super(const HiringRateState());

  Future<void> updateHiringRate({
    required String id,
    required double hourlyPricing,
    required double dailyPricing,
    required double weeklyPricing,
    required double monthlyPricing,
  }) async {
    state = state.copyWith(
      status: HiringRateStatus.loading,
      errorMessage: '',
    );

    try {
      final accessToken = await SessionPrefs.instance.getAccessToken();
      if (accessToken.isEmpty) {
        state = state.copyWith(
          status: HiringRateStatus.error,
          errorMessage: 'Not authenticated',
        );
        return;
      }

      final response = await _service.updateHiringRate(
        accessToken: accessToken,
        data: {
          'id': id,
          'hourlyPricing': hourlyPricing,
          'dailyPricing': dailyPricing,
          'weeklyPricing': weeklyPricing,
          'monthlyPricing': monthlyPricing,
        },
      );

      final status = response['status'] as int? ?? 0;
      if (status == 200) {
        final data = response['data'] as Map<String, dynamic>? ?? {};
        state = state.copyWith(
          status: HiringRateStatus.success,
          hiringRateData: data,
        );
      } else {
        state = state.copyWith(
          status: HiringRateStatus.error,
          errorMessage: response['message'] as String? ?? 'Update failed',
        );
      }
    } catch (e) {
      state = state.copyWith(
        status: HiringRateStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  void reset() {
    state = const HiringRateState();
  }
}

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/session_prefs.dart';
import '../../domain/subscription_models.dart';
import '../../domain/subscription_service.dart';
import '../states/subscription_state.dart';

class SubscriptionNotifier extends StateNotifier<SubscriptionState> {
  final SubscriptionService _service;

  SubscriptionNotifier(this._service) : super(const SubscriptionState());

  Future<bool> _ensureAuth() async {
    final token = await SessionPrefs.instance.getAccessToken();
    if (token.isEmpty) return false;
    _service.setAuthToken(token);
    return true;
  }

  // ── Fetch Plans ──

  Future<void> fetchPlans() async {
    if (state.plansStatus == SubscriptionStatus.loading) return;

    final hasAuth = await _ensureAuth();
    if (!hasAuth) {
      state = state.copyWith(
        plansStatus: SubscriptionStatus.error,
        errorMessage: 'Not authenticated',
      );
      return;
    }

    state = state.copyWith(
      plansStatus: SubscriptionStatus.loading,
      errorMessage: '',
    );

    try {
      final response = await _service.getPlans();

      final success = response['success'] as bool? ?? false;
      if (!success) {
        state = state.copyWith(
          plansStatus: SubscriptionStatus.error,
          errorMessage: response['message'] as String? ?? 'Failed to fetch',
        );
        return;
      }

      final rawList = response['data'] is List
          ? response['data'] as List
          : const [];

      final plans = <PlanMasterResponse>[];
      for (final item in rawList) {
        if (item is Map) {
          try {
            plans.add(
              PlanMasterResponse.fromJson(Map<String, dynamic>.from(item)),
            );
          } catch (e) {
            if (kDebugMode) debugPrint('SubscriptionNotifier parse plan: $e');
          }
        }
      }

      state = state.copyWith(
        plansStatus: SubscriptionStatus.success,
        plans: plans,
      );
    } catch (e) {
      if (kDebugMode) debugPrint('fetchPlans error: $e');
      state = state.copyWith(
        plansStatus: SubscriptionStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  // ── Initiate Subscription ──

  Future<bool> initiateSubscription(String planId) async {
    final hasAuth = await _ensureAuth();
    if (!hasAuth) return false;

    state = state.copyWith(
      initiateStatus: SubscriptionStatus.loading,
      errorMessage: '',
    );

    try {
      final response = await _service.initiateSubscription({
        'planId': planId,
      });

      final success = response['success'] as bool? ?? false;
      if (success) {
        final data = response['data'];
        UserSubscriptionResponse? sub;
        String paymentLink = '';
        if (data is Map) {
          try {
            sub = UserSubscriptionResponse.fromJson(
              Map<String, dynamic>.from(data),
            );
            paymentLink = sub.paymentLink ?? '';
          } catch (_) {}
        }
        state = state.copyWith(
          initiateStatus: SubscriptionStatus.success,
          activeSubscription: sub,
          paymentLink: paymentLink,
        );
        return true;
      }

      state = state.copyWith(
        initiateStatus: SubscriptionStatus.error,
        errorMessage: response['message'] as String? ?? 'Initiation failed',
      );
      return false;
    } catch (e) {
      if (kDebugMode) debugPrint('initiateSubscription error: $e');
      state = state.copyWith(
        initiateStatus: SubscriptionStatus.error,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  // ── Fetch Subscription for Plan ──

  Future<void> fetchSubscriptionForPlan(String planId) async {
    final hasAuth = await _ensureAuth();
    if (!hasAuth) return;

    state = state.copyWith(
      subscriptionStatus: SubscriptionStatus.loading,
      errorMessage: '',
    );

    try {
      final response = await _service.fetchSubscription(planId: planId);

      final success = response['success'] as bool? ?? false;
      if (!success) {
        state = state.copyWith(
          subscriptionStatus: SubscriptionStatus.error,
          errorMessage: response['message'] as String? ?? 'Failed to fetch',
        );
        return;
      }

      final data = response['data'];
      UserSubscriptionResponse? sub;
      if (data is Map) {
        try {
          sub = UserSubscriptionResponse.fromJson(
            Map<String, dynamic>.from(data),
          );
        } catch (_) {}
      }

      state = state.copyWith(
        subscriptionStatus: SubscriptionStatus.success,
        activeSubscription: sub,
      );
    } catch (e) {
      if (kDebugMode) debugPrint('fetchSubscriptionForPlan error: $e');
      state = state.copyWith(
        subscriptionStatus: SubscriptionStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  // ── Sync Subscription Status ──

  Future<bool> syncSubscriptionStatus(String subscriptionId) async {
    final hasAuth = await _ensureAuth();
    if (!hasAuth) return false;

    try {
      final response = await _service.syncSubscriptionStatus({
        'id': subscriptionId,
      });

      final success = response['success'] as bool? ?? false;
      return success;
    } catch (e) {
      if (kDebugMode) debugPrint('syncSubscriptionStatus error: $e');
      return false;
    }
  }
}

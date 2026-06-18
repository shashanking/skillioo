import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../../core/services/session_prefs.dart';
import '../../../payment/domain/payment_service.dart';
import '../../domain/subscription_models.dart';
import '../../domain/subscription_service.dart';
import '../states/subscription_state.dart';

class SubscriptionNotifier extends StateNotifier<SubscriptionState> {
  final SubscriptionService _service;
  final PaymentService _paymentService;

  SubscriptionNotifier(this._service, this._paymentService)
    : super(const SubscriptionState());

  Future<bool> _ensureAuth() async {
    final token = await SessionPrefs.instance.getAccessToken();
    if (token.isEmpty) return false;
    _service.setAuthToken(token);
    _paymentService.setAuthToken(token);
    return true;
  }

  Future<bool> hasUsableCallSubscription({bool refreshIfNeeded = true}) async {
    final current = state.activeSubscription;
    if (current != null &&
        (current.status == 'ACTIVE' || current.status == 'SUCCESS')) {
      return true;
    }

    if (!refreshIfNeeded) return false;

    await fetchPlanAggregatorAndSync();
    final refreshed = state.activeSubscription;
    return refreshed != null &&
        (refreshed.status == 'ACTIVE' || refreshed.status == 'SUCCESS');
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

      final status = response['status'] as int? ?? 0;
      if (status != 200) {
        state = state.copyWith(
          plansStatus: SubscriptionStatus.error,
          errorMessage: response['message'] as String? ?? 'Failed to fetch',
        );
        return;
      }

      // Parse data.items array
      final data = response['data'];
      final rawList = (data is Map && data['items'] is List)
          ? data['items'] as List
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

      if (kDebugMode) {
        debugPrint('SubscriptionNotifier: Fetched ${plans.length} plans');
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
      // Step 0: Check for existing non-terminal subscription for this plan
      debugPrint('Checking for existing non-terminal subscription...');
      final existingResponse = await _service.fetchSubscription(planId: planId);
      final existingStatus = existingResponse['status'] as int? ?? 0;
      final existingData = existingResponse['data'];

      if (existingStatus == 200 &&
          existingData is Map &&
          existingData.isNotEmpty) {
        // There's already a non-terminal subscription
        final existingSub = UserSubscriptionResponse.fromJson(
          Map<String, dynamic>.from(existingData),
        );
        final subStatus = existingSub.status ?? '';
        debugPrint(
          'Existing subscription found: ${existingSub.id}, status=$subStatus',
        );

        // If INITIATED or PENDING, return the existing payment link
        if (subStatus == 'INITIATED' || subStatus == 'PENDING') {
          final paymentLink = existingSub.paymentLink ?? '';
          debugPrint('Resuming existing payment link: $paymentLink');
          if (existingSub.id != null && existingSub.id!.isNotEmpty) {
            await SessionPrefs.instance.setLastSubscriptionId(existingSub.id!);
          }
          state = state.copyWith(
            initiateStatus: SubscriptionStatus.success,
            activeSubscription: existingSub,
            paymentLink: paymentLink,
          );
          return true;
        }

        // If ACTIVE, user already has an active subscription
        if (subStatus == 'ACTIVE') {
          state = state.copyWith(
            initiateStatus: SubscriptionStatus.error,
            activeSubscription: existingSub,
            errorMessage:
                'You already have an active subscription for this plan',
          );
          return false;
        }
      }

      // Step 1: Get profile info
      final profile = await SessionPrefs.instance.getProfile();
      final profileId = await SessionPrefs.instance.getProfileId();

      if (profileId.isEmpty) {
        throw Exception('Profile ID not found');
      }

      // Extract name and phone from profile
      String name = '';
      String phoneNo = '';

      if (profile != null) {
        // Look for phone directly in profile
        final rawPhone = profile['phoneNumber'];

        debugPrint(
          'Profile phoneNumber field: $rawPhone (${rawPhone.runtimeType})',
        );

        // Sometimes it's a list, sometimes a string depending on how it was saved
        if (rawPhone is List && rawPhone.isNotEmpty) {
          phoneNo = rawPhone.first.toString();
          debugPrint('Phone extracted from list: $phoneNo');
        } else if (rawPhone is String && rawPhone.isNotEmpty) {
          phoneNo = rawPhone;
          debugPrint('Phone extracted from string: $phoneNo');
        }

        // If phone not found in root, check contacts array
        if (phoneNo.isEmpty) {
          final contacts = profile['contacts'];
          debugPrint('Checking contacts array: $contacts');
          if (contacts is List) {
            for (final contact in contacts) {
              debugPrint('Checking contact: $contact');
              if (contact is Map && contact['type'] == 'PHONE_NUMBER') {
                phoneNo = contact['value']?.toString() ?? '';
                debugPrint('Phone extracted from contacts: $phoneNo');
                if (phoneNo.isNotEmpty) break;
              }
            }
          }
        }

        // Clean up phone number
        if (phoneNo.startsWith('+91')) {
          phoneNo = phoneNo.substring(3);
        }

        // Extract name
        final firstName = profile['firstName'] as String? ?? '';
        final lastName = profile['lastName'] as String? ?? '';
        final nickName = profile['nickName'] as String? ?? '';
        final groupName = profile['groupName'] as String? ?? '';
        final type = profile['profileType'] as String? ?? '';

        if (type == 'GROUP' && groupName.isNotEmpty) {
          name = groupName;
        } else if (firstName.isNotEmpty || lastName.isNotEmpty) {
          name = '$firstName $lastName'.trim();
        } else {
          name = nickName;
        }

        debugPrint('Extracted name: $name');
      }

      // If we still don't have a phone, try the secure storage as fallback
      if (phoneNo.isEmpty) {
        debugPrint('Phone not found in profile, checking secure storage...');
        try {
          const storage = FlutterSecureStorage();
          final savedPhone = await storage.read(key: 'last_phone_number');
          debugPrint('Secure storage phone: $savedPhone');
          if (savedPhone != null && savedPhone.isNotEmpty) {
            phoneNo = savedPhone.startsWith('+91')
                ? savedPhone.substring(3)
                : savedPhone;
            debugPrint('Phone extracted from secure storage: $phoneNo');
          }
        } catch (e) {
          debugPrint('Error reading from secure storage: $e');
        }
      }

      // If name is still empty, provide a fallback
      if (name.isEmpty) {
        name = 'User $profileId';
      }

      debugPrint('Final phone number: $phoneNo, name: $name');

      if (phoneNo.isEmpty) {
        throw Exception('Phone number not found in profile or secure storage');
      }

      if (kDebugMode) {
        debugPrint(
          'Creating payment user: name=$name, phone=$phoneNo, ref=$profileId',
        );
      }

      // Step 2: Try to fetch existing payment user first
      debugPrint('Fetching payment user by referenceId: $profileId');
      var paymentUserResponse = await _paymentService.fetchPaymentUser(
        profileId,
      );

      debugPrint('Payment user fetch response: $paymentUserResponse');

      var paymentUserStatus = paymentUserResponse['status'] as int? ?? 0;
      var paymentUserId = '';

      // If user doesn't exist (404), create it
      if (paymentUserStatus == 404) {
        debugPrint('Payment user not found, creating new user...');
        debugPrint(
          'Creating payment user: name=$name, phone=$phoneNo, ref=$profileId',
        );

        final createResponse = await _paymentService.createPaymentUser({
          'name': name,
          'phoneNo': phoneNo,
          'referenceId': profileId,
        });

        debugPrint('Payment user create response: $createResponse');

        final createStatus = createResponse['status'] as int? ?? 0;
        final createSuccess = createResponse['success'] as bool? ?? false;

        // 201 Created or 200 OK is success
        if (createStatus != 201 && createStatus != 200 && !createSuccess) {
          final errorMsg =
              createResponse['error'] as String? ??
              createResponse['message'] as String? ??
              'Failed to create payment user';
          throw Exception(errorMsg);
        }

        // Now fetch the created user
        paymentUserResponse = await _paymentService.fetchPaymentUser(profileId);
        debugPrint('Payment user fetch after create: $paymentUserResponse');
        paymentUserStatus = paymentUserResponse['status'] as int? ?? 0;
      }

      // Check if fetch was successful
      if (paymentUserStatus != 200) {
        throw Exception(
          paymentUserResponse['message'] as String? ??
              'Failed to fetch payment user',
        );
      }

      final paymentUserData =
          paymentUserResponse['data'] as Map<String, dynamic>?;
      paymentUserId = paymentUserData?['id'] as String? ?? '';

      if (paymentUserId.isEmpty) {
        throw Exception('Payment user ID not found in response');
      }

      debugPrint('Payment user ID: $paymentUserId');

      // Step 3: Now initiate subscription with only planId
      // The API uses the authenticated user's context (from token)
      final subscriptionPayload = {'planId': planId};
      debugPrint('Subscription payload: $subscriptionPayload');

      final response = await _service.initiateSubscription(subscriptionPayload);

      debugPrint('Subscription response: $response');

      final responseStatus = response['status'] as int? ?? 0;
      final data = response['data'];

      // API returns status 200 or 201 on success (no 'success' field)
      if ((responseStatus == 200 || responseStatus == 201) && data is Map) {
        UserSubscriptionResponse? sub;
        String paymentLink = '';
        try {
          sub = UserSubscriptionResponse.fromJson(
            Map<String, dynamic>.from(data),
          );
          paymentLink = sub.paymentLink ?? '';
          if (sub.id != null && sub.id!.isNotEmpty) {
            await SessionPrefs.instance.setLastSubscriptionId(sub.id!);
          }
        } catch (e) {
          debugPrint('Parse subscription response error: $e');
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
        errorMessage: e.toString().replaceAll('Exception: ', ''),
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

  Future<bool> syncLastKnownSubscription() async {
    final subscriptionId = await SessionPrefs.instance.getLastSubscriptionId();
    debugPrint('syncLastKnownSubscription: lastSubscriptionId=$subscriptionId');
    if (subscriptionId.isEmpty) return false;
    return syncSubscriptionStatus(subscriptionId, hard: true);
  }

  // ── Fetch Plan Aggregator and Sync All Subscriptions ──

  Future<void> fetchPlanAggregatorAndSync() async {
    final hasAuth = await _ensureAuth();
    if (!hasAuth) return;

    try {
      final profileId = await SessionPrefs.instance.getProfileId();
      if (profileId.isEmpty) return;

      final response = await _service.getPlanAggregator(profileId);

      final status = response['status'] as int? ?? 0;
      final data = response['data'];

      if (status == 200 && data is Map) {
        final aggregator = PlanAggregatorResponse.fromJson(
          Map<String, dynamic>.from(data),
        );

        state = state.copyWith(aggregator: aggregator);

        // Do NOT call syncSubscriptionStatus here — every call appends a
        // duplicate entry to the aggregator on the backend (backend bug:
        // append instead of upsert), causing limits to grow unboundedly.
        //
        // Instead, derive active subscription status from the aggregator's
        // activePlans field (>0 means active) and restore the subscription
        // ID from SessionPrefs where it was saved after the last payment sync.
        final activePlans = aggregator.activePlans ?? 0;
        if (activePlans > 0) {
          // If we already have a valid active subscription in state, keep it.
          final current = state.activeSubscription;
          final alreadyActive = current != null &&
              (current.status == 'ACTIVE' || current.status == 'SUCCESS');
          if (!alreadyActive) {
            // Restore from the subscription ID saved at payment time.
            final cachedId = await SessionPrefs.instance.getLastSubscriptionId();
            if (cachedId.isNotEmpty) {
              state = state.copyWith(
                activeSubscription: UserSubscriptionResponse(
                  id: cachedId,
                  status: 'SUCCESS',
                  planCode: current?.planCode,
                  planDetails: SubscriptionPlanDetails(
                    callLimits: aggregator.callLimits,
                    chatLimits: aggregator.chatLimits,
                  ),
                ),
              );
            }
          }
        } else {
          // No active plans according to aggregator — clear stale state.
          state = state.copyWith(activeSubscription: null);
        }
      }
    } catch (e) {
      debugPrint('fetchPlanAggregatorAndSync error: $e');
    }
  }

  // ── Sync Subscription Status ──

  Future<bool> syncSubscriptionStatus(
    String subscriptionId, {
    bool hard = true,
  }) async {
    debugPrint(
      'syncSubscriptionStatus: CALLED with id=$subscriptionId hard=$hard',
    );

    final hasAuth = await _ensureAuth();
    if (!hasAuth) {
      debugPrint('syncSubscriptionStatus: No auth, returning false');
      return false;
    }

    debugPrint('syncSubscriptionStatus: Auth OK, setting loading state');
    state = state.copyWith(
      subscriptionStatus: SubscriptionStatus.loading,
      errorMessage: '',
    );

    try {
      debugPrint('syncSubscriptionStatus: Calling API...');
      final response = await _service.syncSubscriptionStatus({
        'id': subscriptionId,
        'hard': hard,
      });

      debugPrint('syncSubscriptionStatus: API response received: $response');

      final status = response['status'] as int? ?? 0;
      final data = response['data'];

      if (status == 200 && data is Map && data.isNotEmpty) {
        final subData = Map<String, dynamic>.from(data);
        final sub = UserSubscriptionResponse.fromJson(subData);
        final subStatus = sub.status ?? '';

        if (subStatus == 'ACTIVE' || subStatus == 'SUCCESS') {
          if (sub.id != null && sub.id!.isNotEmpty) {
            await SessionPrefs.instance.setLastSubscriptionId(sub.id!);
          }

          state = state.copyWith(
            subscriptionStatus: SubscriptionStatus.success,
            activeSubscription: sub,
            paymentLink: '',
          );
          debugPrint(
            'syncSubscriptionStatus: SUCCESS - Details for ${sub.id} (Status: ${sub.status})',
          );
          debugPrint(
            'syncSubscriptionStatus: NOTE - Individual Plan Limits: callLimits=${sub.planDetails?.callLimits}, chatLimits=${sub.planDetails?.chatLimits}',
          );
          return true;
        }

        debugPrint(
          'syncSubscriptionStatus: Ignoring non-active subscription ${sub.id} status=${sub.status}',
        );
        // If the previously-cached activeSubscription is the same record
        // we just learned is non-active (cancelled / expired / failed),
        // clear it so the profile screen's Plan Limits panel doesn't
        // keep showing stale entitlements.
        final cachedId = state.activeSubscription?.id;
        final shouldClear = cachedId != null && cachedId == sub.id;
        state = state.copyWith(
          subscriptionStatus: SubscriptionStatus.success,
          activeSubscription: shouldClear ? null : state.activeSubscription,
          paymentLink: '',
        );
        return false;
      }

      state = state.copyWith(
        subscriptionStatus: SubscriptionStatus.error,
        errorMessage: response['message'] as String? ?? 'Sync failed',
      );
      return false;
    } catch (e) {
      if (kDebugMode) debugPrint('syncSubscriptionStatus error: $e');
      state = state.copyWith(
        subscriptionStatus: SubscriptionStatus.error,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/call/application/call_providers.dart';
import '../../features/onboarding/domain/registration_models.dart';
import '../../features/subscription/application/subscription_providers.dart';
import '../../features/subscription/presentation/subscription.dart';
import '../services/session_prefs.dart';
import '../widgets/subscription_required_dialog.dart';

/// Gate that runs before any call/chat action.
///
/// Branches on the user's profile state:
/// - **No profile** (neither creator nor hirer) → routes to the lightweight
///   onboarding form so they can create a profile first.
/// - **Hirer profile, not subscribed** → sends straight to the subscription
///   screen (they already have a profile, no need to re-show the form).
/// - **Creator profile, not subscribed** → shows the subscription dialog
///   (existing behaviour).
/// - **Subscribed** (creator or hirer) → returns true; the action proceeds.
///
/// Returns true only when the caller may proceed with the call/chat.
Future<bool> _gateCallOrChat({
  required BuildContext context,
  required WidgetRef ref,
}) async {
  final profile = await SessionPrefs.instance.getProfile();
  final isCreator = profile?['isCreator'] as bool? ?? false;
  final isHirer = (profile?['profileType'] as String?) == ProfileType.hirer;

  // No profile at all → send to the onboarding form. Use push (not go)
  // so the dashboard stays underneath and the user returns to it after
  // the onboarding → subscription flow.
  if (!isCreator && !isHirer) {
    if (context.mounted) context.push('/hirer-onboarding');
    return false;
  }

  final hasSubscription = await ref
      .read(subscriptionNotifierProvider.notifier)
      .hasUsableCallSubscription();
  if (hasSubscription) return true;

  // Has a profile (creator or hirer) but no subscription — show the
  // subscription popup. The user is NOT sent through onboarding again.
  if (context.mounted) await _showSubscriptionDialog(context);
  return false;
}

/// Runs the profile/subscription gate, then initiates the call.
/// Returns true if the call was successfully initiated.
Future<bool> initiateCallWithSubscriptionCheck({
  required BuildContext context,
  required WidgetRef ref,
  required String recipientId,
}) async {
  final allowed = await _gateCallOrChat(context: context, ref: ref);
  if (!allowed) return false;

  return ref.read(callNotifierProvider.notifier).initiateCall(recipientId);
}

/// Runs the profile/subscription gate before allowing chat.
/// Returns true if chat is allowed.
Future<bool> checkChatSubscription({
  required BuildContext context,
  required WidgetRef ref,
}) async {
  return _gateCallOrChat(context: context, ref: ref);
}

Future<void> _showSubscriptionDialog(BuildContext context) {
  return SubscriptionRequiredDialog.show(
    context,
    onViewPlans: () {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const SubscriptionScreen(),
        ),
      );
    },
  );
}

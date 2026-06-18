import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/onboarding/domain/registration_models.dart';
import '../services/session_state_provider.dart';

/// True when the logged-in user is a lightweight (hirer-type) profile.
///
/// Synchronous — reads from the in-memory [sessionStateProvider] snapshot,
/// not from secure storage, so it can be called from tap handlers without
/// awaiting.
bool isCurrentUserHirer(WidgetRef ref) {
  final profile = ref.read(sessionStateProvider).profile;
  return (profile?['profileType'] as String?) == ProfileType.hirer;
}

/// Show a neutral toast when a hirer-type user tries to use a creator-only
/// interaction (like / comment / follow). Wording deliberately avoids the
/// internal "hirer" label — client requirement.
void _showHirerBlockedToast(BuildContext context) {
  final messenger = ScaffoldMessenger.maybeOf(context);
  if (messenger == null) return;
  messenger.hideCurrentSnackBar();
  messenger.showSnackBar(
    SnackBar(
      content: const Text(
        "This feature isn't available on your profile.",
        style: TextStyle(
          fontFamily: 'Outfit',
          fontWeight: FontWeight.w500,
        ),
      ),
      backgroundColor: Colors.black.withValues(alpha: 0.85),
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 2),
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  );
}

/// Gate for creator-only interactions (like, comment, follow). If the
/// current user is a hirer, shows a toast and returns `true` so the
/// caller can early-return; otherwise returns `false`.
///
/// Usage:
/// ```dart
/// onTap: () {
///   if (blockIfHirer(context, ref)) return;
///   // ...real action
/// }
/// ```
bool blockIfHirer(BuildContext context, WidgetRef ref) {
  if (!isCurrentUserHirer(ref)) return false;
  _showHirerBlockedToast(context);
  return true;
}

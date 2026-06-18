import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/shared_http_client.dart';
import '../domain/profile_auth_service.dart';
import '../domain/verification_service.dart';
import 'notifiers/auth_notifier.dart';
import 'states/auth_state.dart';

/// Service provider for VerificationService
final verificationServiceProvider = Provider<VerificationService>((ref) {
  return VerificationService(client: ref.watch(sharedHttpClientProvider));
});

/// Service provider for ProfileAuthService (login)
final profileAuthServiceProvider = Provider<ProfileAuthService>((ref) {
  return ProfileAuthService(client: ref.watch(sharedHttpClientProvider));
});

/// StateNotifier provider for auth flow
final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((
  ref,
) {
  final service = ref.watch(verificationServiceProvider);
  return AuthNotifier(service);
});

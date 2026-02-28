import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/verification_service.dart';
import 'notifiers/auth_notifier.dart';
import 'states/auth_state.dart';

/// Service provider for VerificationService
final verificationServiceProvider = Provider<VerificationService>((ref) {
  final service = VerificationService();
  ref.onDispose(() => service.dispose());
  return service;
});

/// StateNotifier provider for auth flow
final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final service = ref.watch(verificationServiceProvider);
  return AuthNotifier(service);
});

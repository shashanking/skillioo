import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/document_service.dart';
import '../domain/registration_service.dart';
import 'notifiers/registration_notifier.dart';
import 'states/registration_state.dart';

/// Service provider for DocumentService
final documentServiceProvider = Provider<DocumentService>((ref) {
  final service = DocumentService();
  ref.onDispose(() => service.dispose());
  return service;
});

/// Service provider for RegistrationService
final registrationServiceProvider = Provider<RegistrationService>((ref) {
  final service = RegistrationService();
  ref.onDispose(() => service.dispose());
  return service;
});

/// StateNotifier provider for registration flow
final registrationNotifierProvider =
    StateNotifierProvider<RegistrationNotifier, RegistrationState>((ref) {
  final registrationService = ref.watch(registrationServiceProvider);
  final documentService = ref.watch(documentServiceProvider);
  return RegistrationNotifier(registrationService, documentService);
});

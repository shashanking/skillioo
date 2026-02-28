import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../domain/verification_models.dart';
import '../../domain/verification_service.dart';
import '../states/auth_state.dart';

const _kVerificationIdKey = 'last_verification_id';

class AuthNotifier extends StateNotifier<AuthState> {
  final VerificationService _verificationService;
  final FlutterSecureStorage _storage;

  AuthNotifier(this._verificationService, {FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage(),
      super(const AuthState());

  /// Step 1: Send OTP to phone number
  Future<void> sendOtp({
    required String phoneNumber,
    String purpose = VerificationPurpose.login,
  }) async {
    state = state.copyWith(
      status: AuthStatus.loading,
      phoneNumber: phoneNumber,
      purpose: purpose,
      errorMessage: '',
    );

    try {
      final response = await _verificationService.createVerificationRequest(
        phoneNumber: phoneNumber,
        purpose: purpose,
      );

      debugPrint('sendOtp response: $response');
      final success = response['success'] as bool? ?? false;
      final data = response['data'] as Map<String, dynamic>?;
      final verification = data?['verification'] as Map<String, dynamic>? ?? {};
      final verificationId = verification['id'] as String? ?? '';

      if (success && verificationId.isNotEmpty) {
        // Persist verificationId for use in OTP screen & registration
        await _storage.write(key: _kVerificationIdKey, value: verificationId);
        state = state.copyWith(
          status: AuthStatus.otpSent,
          verificationId: verificationId,
        );
      } else if (!success) {
        final message = response['message'] as String? ?? '';
        // 409: verification already in-progress — load saved ID and proceed
        if (message.toLowerCase().contains('already exists') ||
            message.toLowerCase().contains('in progress')) {
          final savedId = await _storage.read(key: _kVerificationIdKey) ?? '';
          final resolvedId = verificationId.isNotEmpty
              ? verificationId
              : savedId;
          if (resolvedId.isNotEmpty) {
            await _storage.write(key: _kVerificationIdKey, value: resolvedId);
          }

          // Always allow user into OTP screen so they can enter existing OTP or resend.
          state = state.copyWith(
            status: AuthStatus.otpSent,
            verificationId: resolvedId,
            errorMessage: resolvedId.isEmpty
                ? 'A verification is already in progress. Please resend OTP.'
                : '',
          );
        } else {
          state = state.copyWith(
            status: AuthStatus.error,
            errorMessage: message.isNotEmpty ? message : 'Failed to send OTP',
          );
        }
      }
    } catch (e) {
      debugPrint('sendOtp error: $e');
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  /// Step 2: Resend OTP
  Future<void> resendOtp() async {
    // Try to load verificationId from storage if state is empty
    if (state.verificationId.isEmpty) {
      final savedId = await _storage.read(key: _kVerificationIdKey) ?? '';
      if (savedId.isNotEmpty) {
        state = state.copyWith(verificationId: savedId);
      }
    }

    if (state.verificationId.isEmpty || state.phoneNumber.isEmpty) {
      state = state.copyWith(
        isResending: false,
        errorMessage: 'Unable to resend OTP. Please go back and try again.',
      );
      return;
    }

    state = state.copyWith(isResending: true, errorMessage: '');

    try {
      final response = await _verificationService.resendOtp(
        phoneNumber: state.phoneNumber,
        verificationId: state.verificationId,
      );

      final success = response['success'] as bool? ?? false;
      if (success) {
        state = state.copyWith(isResending: false);
      } else {
        final message =
            response['message'] as String? ?? 'Failed to resend OTP';
        state = state.copyWith(isResending: false, errorMessage: message);
      }
    } catch (e) {
      debugPrint('resendOtp error: $e');
      state = state.copyWith(isResending: false, errorMessage: e.toString());
    }
  }

  /// Step 3: Verify OTP
  Future<void> verifyOtp({required String otpCode}) async {
    // Try to load verificationId from storage if state is empty
    if (state.verificationId.isEmpty) {
      final savedId = await _storage.read(key: _kVerificationIdKey) ?? '';
      if (savedId.isNotEmpty) {
        state = state.copyWith(verificationId: savedId);
      } else {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: 'Session expired. Please go back and try again.',
        );
        return;
      }
    }
    state = state.copyWith(status: AuthStatus.loading, errorMessage: '');

    try {
      final response = await _verificationService.verifyOtp(
        otpCode: otpCode,
        verificationId: state.verificationId,
      );

      debugPrint('verifyOtp response: $response');
      final success = response['success'] as bool? ?? false;
      if (success) {
        state = state.copyWith(status: AuthStatus.otpVerified);
      } else {
        final message =
            response['message'] as String? ?? 'OTP verification failed';
        // 409: OTP already verified — treat as success
        if (message.toLowerCase().contains('already been verified')) {
          state = state.copyWith(status: AuthStatus.otpVerified);
        } else {
          state = state.copyWith(
            status: AuthStatus.error,
            errorMessage: message,
          );
        }
      }
    } catch (e) {
      debugPrint('verifyOtp error: $e');
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  /// Reset state
  void reset() {
    state = const AuthState();
  }
}

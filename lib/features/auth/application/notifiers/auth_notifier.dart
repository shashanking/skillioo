import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../domain/verification_models.dart';
import '../../domain/verification_service.dart';
import '../states/auth_state.dart';

const _kVerificationIdKey = 'last_verification_id';
const _kLastPhoneNumberKey = 'last_phone_number';
const _kLastPhoneVerificationIdKey = 'last_phone_verification_id';

class AuthNotifier extends StateNotifier<AuthState> {
  final VerificationService _verificationService;
  final FlutterSecureStorage _storage;

  AuthNotifier(this._verificationService, {FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage(),
      super(const AuthState());

  Future<String> _getSavedPhoneNumber() async {
    return await _storage.read(key: _kLastPhoneNumberKey) ?? '';
  }

  Future<String> _getSavedPhoneVerificationId() async {
    return await _storage.read(key: _kLastPhoneVerificationIdKey) ?? '';
  }

  Future<bool> isKnownLoginPhone({required String phoneNumber}) async {
    final savedPhone = await _getSavedPhoneNumber();
    final savedVerificationId = await _getSavedPhoneVerificationId();
    return savedPhone.isNotEmpty &&
        savedVerificationId.isNotEmpty &&
        savedPhone == phoneNumber;
  }

  Future<String> getSavedPhoneVerificationId() async {
    return await _getSavedPhoneVerificationId();
  }

  /// Decides whether the user is logging in or signing up, then sends OTP.
  ///
  /// Rules:
  /// - If saved phone + saved verificationId exist AND phone matches → LOGIN
  /// - Else → SIGNUP
  Future<void> decideAndSendOtp({required String phoneNumber}) async {
    final savedPhone = await _getSavedPhoneNumber();
    final savedVerificationId = await _getSavedPhoneVerificationId();

    final shouldLogin =
        savedPhone.isNotEmpty &&
        savedVerificationId.isNotEmpty &&
        savedPhone == phoneNumber;

    await sendOtp(
      phoneNumber: phoneNumber,
      purpose: shouldLogin
          ? VerificationPurpose.login
          : VerificationPurpose.signup,
    );
  }

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
      // Persist last phone so we can decide LOGIN vs SIGNUP automatically next time.
      await _storage.write(key: _kLastPhoneNumberKey, value: phoneNumber);

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
        await _storage.write(
          key: _kLastPhoneVerificationIdKey,
          value: verificationId,
        );
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
            await _storage.write(
              key: _kLastPhoneVerificationIdKey,
              value: resolvedId,
            );
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
        // Extract and store verificationId from response data for auto-login
        final data = response['data'] as Map<String, dynamic>?;
        final verifiedId =
            data?['verificationId'] as String? ?? state.verificationId;
        if (verifiedId.isNotEmpty) {
          await _storage.write(key: _kVerificationIdKey, value: verifiedId);
          await _storage.write(
            key: _kLastPhoneVerificationIdKey,
            value: verifiedId,
          );
        }
        state = state.copyWith(
          status: AuthStatus.otpVerified,
          verificationId: verifiedId,
        );
      } else {
        final message =
            response['message'] as String? ?? 'OTP verification failed';
        // OTP already verified: persist ID and surface message so UI can offer login.
        if (message.toLowerCase().contains('already been verified')) {
          final data = response['data'] as Map<String, dynamic>?;
          final verifiedId =
              data?['verificationId'] as String? ?? state.verificationId;
          if (verifiedId.isNotEmpty) {
            await _storage.write(key: _kVerificationIdKey, value: verifiedId);
            await _storage.write(
              key: _kLastPhoneVerificationIdKey,
              value: verifiedId,
            );
          }
          state = state.copyWith(
            status: AuthStatus.error,
            verificationId: verifiedId,
            errorMessage: message,
          );
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

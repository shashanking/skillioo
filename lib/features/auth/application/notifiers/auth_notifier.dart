import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../../core/services/session_prefs.dart';
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

  /// Step 1: ask the backend what to do for this phone number.
  ///
  /// Backend response decides the next screen:
  ///  - `data.isPinSet == true`           → user has a PIN; client should
  ///    show the PIN-entry screen. No OTP was sent. State enters
  ///    [AuthStatus.pinRequired].
  ///  - `data.verificationId` present     → an OTP was sent (returning user
  ///    without PIN, or fresh user). State enters [AuthStatus.otpSent].
  Future<void> verifyPhone({required String phoneNumber}) async {
    state = state.copyWith(
      status: AuthStatus.loading,
      phoneNumber: phoneNumber,
      errorMessage: '',
    );

    try {
      await _storage.write(key: _kLastPhoneNumberKey, value: phoneNumber);

      final response = await _verificationService.createVerificationRequest(
        phoneNumber: phoneNumber,
      );
      debugPrint('verifyPhone response: $response');

      final success = response['success'] as bool? ?? false;
      final data = response['data'] as Map<String, dynamic>? ?? {};

      // Returning user with PIN — backend shortcuts the OTP step.
      if (success && data['isPinSet'] == true) {
        state = state.copyWith(status: AuthStatus.pinRequired);
        return;
      }

      // Pull verificationId from any of the shapes the backend uses.
      final verification = data['verification'] as Map<String, dynamic>? ?? {};
      final verificationId = (verification['id'] as String? ?? '').isNotEmpty
          ? verification['id'] as String
          : (data['verificationId'] as String? ?? '');

      if (success && verificationId.isNotEmpty) {
        await _storage.write(key: _kVerificationIdKey, value: verificationId);
        await _storage.write(
          key: _kLastPhoneVerificationIdKey,
          value: verificationId,
        );
        state = state.copyWith(
          status: AuthStatus.otpSent,
          verificationId: verificationId,
        );
        return;
      }

      // Fallback — handle 409 "already in progress" by reusing saved id.
      final message = response['message'] as String? ?? '';
      if (message.toLowerCase().contains('already exists') ||
          message.toLowerCase().contains('in progress')) {
        final savedId = await _storage.read(key: _kVerificationIdKey) ?? '';
        if (savedId.isNotEmpty) {
          state = state.copyWith(
            status: AuthStatus.otpSent,
            verificationId: savedId,
          );
          return;
        }
      }

      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: message.isNotEmpty ? message : 'Failed to verify number',
      );
    } catch (e) {
      debugPrint('verifyPhone error: $e');
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  /// Step 2: Resend OTP
  Future<void> resendOtp() async {
    if (state.verificationId.isEmpty) {
      final savedId = await _storage.read(key: _kVerificationIdKey) ?? '';
      if (savedId.isNotEmpty) {
        state = state.copyWith(verificationId: savedId);
      }
    }
    if (state.phoneNumber.isEmpty) {
      final savedPhone =
          await _storage.read(key: _kLastPhoneNumberKey) ?? '';
      if (savedPhone.isNotEmpty) {
        state = state.copyWith(phoneNumber: savedPhone);
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
        final data = response['data'] as Map<String, dynamic>?;
        final verification =
            data?['verification'] as Map<String, dynamic>? ?? {};
        final newId = verification['id'] as String? ?? '';
        if (newId.isNotEmpty && newId != state.verificationId) {
          await _storage.write(key: _kVerificationIdKey, value: newId);
          state = state.copyWith(isResending: false, verificationId: newId);
        } else {
          state = state.copyWith(isResending: false);
        }
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

  /// Step 3: Verify OTP — also creates the profile and returns tokens.
  ///
  /// Successful response carries: `verificationId, profileId, isOnboarded,
  /// isCreator, accessToken, refreshToken`. Tokens + profileId are persisted
  /// to [SessionPrefs] so subsequent authenticated calls (e.g. updatePin)
  /// have a Bearer token without going through the PIN-login screen.
  Future<void> verifyOtp({required String otpCode}) async {
    if (state.verificationId.isEmpty) {
      final savedId = await _storage.read(key: _kVerificationIdKey) ?? '';
      if (savedId.isNotEmpty) {
        state = state.copyWith(verificationId: savedId);
      } else {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage:
              'Verification session expired. Please request a new OTP.',
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
      final data = response['data'] as Map<String, dynamic>? ?? {};

      if (success) {
        final verifiedId =
            data['verificationId'] as String? ?? state.verificationId;
        final profileId = data['profileId'] as String? ?? '';
        final accessToken = data['accessToken'] as String? ?? '';
        final refreshToken = data['refreshToken'] as String? ?? '';
        final isCreator = data['isCreator'] as bool? ?? false;
        final isOnboarded = data['isOnboarded'] as bool? ?? false;

        if (verifiedId.isNotEmpty) {
          await _storage.write(key: _kVerificationIdKey, value: verifiedId);
          await _storage.write(
            key: _kLastPhoneVerificationIdKey,
            value: verifiedId,
          );
        }

        // Persist session so update-PIN and downstream APIs have a Bearer.
        // Also stash isCreator/isOnboarded so the splash screen can decide
        // dashboard vs. options on next app launch without another API hit.
        if (accessToken.isNotEmpty && refreshToken.isNotEmpty) {
          await SessionPrefs.instance.setSession(
            accessToken: accessToken,
            refreshToken: refreshToken,
            profile: {
              if (profileId.isNotEmpty) 'id': profileId,
              'isCreator': isCreator,
              'isOnboarded': isOnboarded,
            },
          );
          // Stash the phone we used to verify — the settings PIN-update
          // flow needs it as the credential (nickName doesn't resolve
          // for hirer-type profiles backend-side).
          if (state.phoneNumber.isNotEmpty) {
            await SessionPrefs.instance.setLastPhoneNumber(state.phoneNumber);
          }
        }

        state = state.copyWith(
          status: AuthStatus.otpVerified,
          verificationId: verifiedId,
          profileId: profileId,
          accessToken: accessToken,
          refreshToken: refreshToken,
          isCreator: isCreator,
          isOnboarded: isOnboarded,
        );
        return;
      }

      final message =
          response['message'] as String? ?? 'OTP verification failed';
      if (message.toLowerCase().contains('already been verified')) {
        final verifiedId =
            data['verificationId'] as String? ?? state.verificationId;
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
    } catch (e) {
      debugPrint('verifyOtp error: $e');
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  /// Reset state
  Future<void> reset() async {
    await _storage.delete(key: _kVerificationIdKey);
    await _storage.delete(key: _kLastPhoneNumberKey);
    await _storage.delete(key: _kLastPhoneVerificationIdKey);
    state = const AuthState();
  }
}

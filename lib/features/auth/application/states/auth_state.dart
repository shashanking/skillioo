import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_state.freezed.dart';

enum AuthStatus { initial, loading, otpSent, pinRequired, otpVerified, error }

@freezed
class AuthState with _$AuthState {
  const factory AuthState({
    @Default(AuthStatus.initial) AuthStatus status,
    @Default('') String phoneNumber,
    @Default('') String verificationId,
    @Default('') String purpose,
    @Default('') String errorMessage,
    @Default(false) bool isResending,
    @Default('') String profileId,
    @Default('') String accessToken,
    @Default('') String refreshToken,
    @Default(false) bool isCreator,
    @Default(false) bool isOnboarded,
  }) = _AuthState;
}

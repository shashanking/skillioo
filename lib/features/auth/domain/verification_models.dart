import 'package:json_annotation/json_annotation.dart';

part 'verification_models.g.dart';

// ─── Request Models ───

@JsonSerializable()
class CreateVerificationRequest {
  final String phoneNumber;
  final String purpose;

  const CreateVerificationRequest({
    required this.phoneNumber,
    required this.purpose,
  });

  factory CreateVerificationRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateVerificationRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CreateVerificationRequestToJson(this);
}

@JsonSerializable()
class ResendOtpRequest {
  final String phoneNumber;
  final String verificationId;

  const ResendOtpRequest({
    required this.phoneNumber,
    required this.verificationId,
  });

  factory ResendOtpRequest.fromJson(Map<String, dynamic> json) =>
      _$ResendOtpRequestFromJson(json);

  Map<String, dynamic> toJson() => _$ResendOtpRequestToJson(this);
}

@JsonSerializable()
class VerifyOtpRequest {
  final String otpCode;
  final String verificationId;

  const VerifyOtpRequest({
    required this.otpCode,
    required this.verificationId,
  });

  factory VerifyOtpRequest.fromJson(Map<String, dynamic> json) =>
      _$VerifyOtpRequestFromJson(json);

  Map<String, dynamic> toJson() => _$VerifyOtpRequestToJson(this);
}

// ─── Response Models ───

@JsonSerializable()
class VerificationData {
  final VerificationInfo? verification;

  const VerificationData({this.verification});

  factory VerificationData.fromJson(Map<String, dynamic> json) =>
      _$VerificationDataFromJson(json);

  Map<String, dynamic> toJson() => _$VerificationDataToJson(this);
}

@JsonSerializable()
class VerificationInfo {
  final String id;
  final String purpose;
  final bool? notificationSent;

  const VerificationInfo({
    required this.id,
    required this.purpose,
    this.notificationSent,
  });

  factory VerificationInfo.fromJson(Map<String, dynamic> json) =>
      _$VerificationInfoFromJson(json);

  Map<String, dynamic> toJson() => _$VerificationInfoToJson(this);
}

@JsonSerializable()
class VerifyOtpData {
  final String verificationId;

  const VerifyOtpData({required this.verificationId});

  factory VerifyOtpData.fromJson(Map<String, dynamic> json) =>
      _$VerifyOtpDataFromJson(json);

  Map<String, dynamic> toJson() => _$VerifyOtpDataToJson(this);
}

// ─── Enums ───

class VerificationPurpose {
  static const String login = 'LOGIN';
  static const String phoneVerification = 'PHONE_VERIFICATION';
  static const String emailVerification = 'EMAIL_VERIFICATION';
  static const String signup = 'SIGNUP';
}

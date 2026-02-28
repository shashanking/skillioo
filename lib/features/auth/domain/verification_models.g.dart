// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'verification_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateVerificationRequest _$CreateVerificationRequestFromJson(
  Map<String, dynamic> json,
) => CreateVerificationRequest(
  phoneNumber: json['phoneNumber'] as String,
  purpose: json['purpose'] as String,
);

Map<String, dynamic> _$CreateVerificationRequestToJson(
  CreateVerificationRequest instance,
) => <String, dynamic>{
  'phoneNumber': instance.phoneNumber,
  'purpose': instance.purpose,
};

ResendOtpRequest _$ResendOtpRequestFromJson(Map<String, dynamic> json) =>
    ResendOtpRequest(
      phoneNumber: json['phoneNumber'] as String,
      verificationId: json['verificationId'] as String,
    );

Map<String, dynamic> _$ResendOtpRequestToJson(ResendOtpRequest instance) =>
    <String, dynamic>{
      'phoneNumber': instance.phoneNumber,
      'verificationId': instance.verificationId,
    };

VerifyOtpRequest _$VerifyOtpRequestFromJson(Map<String, dynamic> json) =>
    VerifyOtpRequest(
      otpCode: json['otpCode'] as String,
      verificationId: json['verificationId'] as String,
    );

Map<String, dynamic> _$VerifyOtpRequestToJson(VerifyOtpRequest instance) =>
    <String, dynamic>{
      'otpCode': instance.otpCode,
      'verificationId': instance.verificationId,
    };

VerificationData _$VerificationDataFromJson(Map<String, dynamic> json) =>
    VerificationData(
      verification: json['verification'] == null
          ? null
          : VerificationInfo.fromJson(
              json['verification'] as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$VerificationDataToJson(VerificationData instance) =>
    <String, dynamic>{'verification': instance.verification};

VerificationInfo _$VerificationInfoFromJson(Map<String, dynamic> json) =>
    VerificationInfo(
      id: json['id'] as String,
      purpose: json['purpose'] as String,
      notificationSent: json['notificationSent'] as bool?,
    );

Map<String, dynamic> _$VerificationInfoToJson(VerificationInfo instance) =>
    <String, dynamic>{
      'id': instance.id,
      'purpose': instance.purpose,
      'notificationSent': instance.notificationSent,
    };

VerifyOtpData _$VerifyOtpDataFromJson(Map<String, dynamic> json) =>
    VerifyOtpData(verificationId: json['verificationId'] as String);

Map<String, dynamic> _$VerifyOtpDataToJson(VerifyOtpData instance) =>
    <String, dynamic>{'verificationId': instance.verificationId};

import 'package:json_annotation/json_annotation.dart';

part 'payment_models.g.dart';

// ── Payment ──

@JsonSerializable()
class CreatePaymentRequest {
  final int amount;
  final String provider;
  final String service;
  final String userReferenceId;

  const CreatePaymentRequest({
    required this.amount,
    required this.provider,
    required this.service,
    required this.userReferenceId,
  });

  factory CreatePaymentRequest.fromJson(Map<String, dynamic> json) =>
      _$CreatePaymentRequestFromJson(json);
  Map<String, dynamic> toJson() => _$CreatePaymentRequestToJson(this);
}

@JsonSerializable()
class PaymentMetaData {
  final String? paymentLinkId;
  final String? shortUrl;
  final String? shortUrlStatus;
  final String? eventId;

  const PaymentMetaData({
    this.paymentLinkId,
    this.shortUrl,
    this.shortUrlStatus,
    this.eventId,
  });

  factory PaymentMetaData.fromJson(Map<String, dynamic> json) =>
      _$PaymentMetaDataFromJson(json);
  Map<String, dynamic> toJson() => _$PaymentMetaDataToJson(this);
}

@JsonSerializable()
class PaymentResponse {
  final String? id;
  final String? amount;
  final int? provider;
  final int? service;
  final PaymentMetaData? metaData;
  final String? createdAt;
  final String? updatedAt;

  const PaymentResponse({
    this.id,
    this.amount,
    this.provider,
    this.service,
    this.metaData,
    this.createdAt,
    this.updatedAt,
  });

  factory PaymentResponse.fromJson(Map<String, dynamic> json) =>
      _$PaymentResponseFromJson(json);
  Map<String, dynamic> toJson() => _$PaymentResponseToJson(this);
}

@JsonSerializable()
class PaymentListResponse {
  final List<PaymentResponse>? items;
  final int? total;
  final int? page;
  final int? prePage;
  final String? sortBy;
  final String? sortDirection;

  const PaymentListResponse({
    this.items,
    this.total,
    this.page,
    this.prePage,
    this.sortBy,
    this.sortDirection,
  });

  factory PaymentListResponse.fromJson(Map<String, dynamic> json) =>
      _$PaymentListResponseFromJson(json);
  Map<String, dynamic> toJson() => _$PaymentListResponseToJson(this);
}

// ── Payment User ──

@JsonSerializable()
class CreatePaymentUserRequest {
  final String name;
  final String phoneNo;
  final String referenceId;

  const CreatePaymentUserRequest({
    required this.name,
    required this.phoneNo,
    required this.referenceId,
  });

  factory CreatePaymentUserRequest.fromJson(Map<String, dynamic> json) =>
      _$CreatePaymentUserRequestFromJson(json);
  Map<String, dynamic> toJson() => _$CreatePaymentUserRequestToJson(this);
}

@JsonSerializable()
class UpdatePaymentUserRequest {
  final String referenceId;
  final String? phoneNo;
  final String? name;

  const UpdatePaymentUserRequest({
    required this.referenceId,
    this.phoneNo,
    this.name,
  });

  factory UpdatePaymentUserRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdatePaymentUserRequestFromJson(json);
  Map<String, dynamic> toJson() => _$UpdatePaymentUserRequestToJson(this);
}

@JsonSerializable()
class PaymentUserResponse {
  final String? id;
  final String? name;
  final String? phoneNo;
  final String? referenceId;
  final String? createdAt;
  final String? updatedAt;

  const PaymentUserResponse({
    this.id,
    this.name,
    this.phoneNo,
    this.referenceId,
    this.createdAt,
    this.updatedAt,
  });

  factory PaymentUserResponse.fromJson(Map<String, dynamic> json) =>
      _$PaymentUserResponseFromJson(json);
  Map<String, dynamic> toJson() => _$PaymentUserResponseToJson(this);
}

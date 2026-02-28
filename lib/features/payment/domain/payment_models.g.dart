// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreatePaymentRequest _$CreatePaymentRequestFromJson(
  Map<String, dynamic> json,
) => CreatePaymentRequest(
  amount: (json['amount'] as num).toInt(),
  provider: json['provider'] as String,
  service: json['service'] as String,
  userReferenceId: json['userReferenceId'] as String,
);

Map<String, dynamic> _$CreatePaymentRequestToJson(
  CreatePaymentRequest instance,
) => <String, dynamic>{
  'amount': instance.amount,
  'provider': instance.provider,
  'service': instance.service,
  'userReferenceId': instance.userReferenceId,
};

PaymentMetaData _$PaymentMetaDataFromJson(Map<String, dynamic> json) =>
    PaymentMetaData(
      paymentLinkId: json['paymentLinkId'] as String?,
      shortUrl: json['shortUrl'] as String?,
      shortUrlStatus: json['shortUrlStatus'] as String?,
      eventId: json['eventId'] as String?,
    );

Map<String, dynamic> _$PaymentMetaDataToJson(PaymentMetaData instance) =>
    <String, dynamic>{
      'paymentLinkId': instance.paymentLinkId,
      'shortUrl': instance.shortUrl,
      'shortUrlStatus': instance.shortUrlStatus,
      'eventId': instance.eventId,
    };

PaymentResponse _$PaymentResponseFromJson(Map<String, dynamic> json) =>
    PaymentResponse(
      id: json['id'] as String?,
      amount: json['amount'] as String?,
      provider: (json['provider'] as num?)?.toInt(),
      service: (json['service'] as num?)?.toInt(),
      metaData: json['metaData'] == null
          ? null
          : PaymentMetaData.fromJson(json['metaData'] as Map<String, dynamic>),
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
    );

Map<String, dynamic> _$PaymentResponseToJson(PaymentResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'amount': instance.amount,
      'provider': instance.provider,
      'service': instance.service,
      'metaData': instance.metaData,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
    };

PaymentListResponse _$PaymentListResponseFromJson(Map<String, dynamic> json) =>
    PaymentListResponse(
      items: (json['items'] as List<dynamic>?)
          ?.map((e) => PaymentResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: (json['total'] as num?)?.toInt(),
      page: (json['page'] as num?)?.toInt(),
      prePage: (json['prePage'] as num?)?.toInt(),
      sortBy: json['sortBy'] as String?,
      sortDirection: json['sortDirection'] as String?,
    );

Map<String, dynamic> _$PaymentListResponseToJson(
  PaymentListResponse instance,
) => <String, dynamic>{
  'items': instance.items,
  'total': instance.total,
  'page': instance.page,
  'prePage': instance.prePage,
  'sortBy': instance.sortBy,
  'sortDirection': instance.sortDirection,
};

CreatePaymentUserRequest _$CreatePaymentUserRequestFromJson(
  Map<String, dynamic> json,
) => CreatePaymentUserRequest(
  name: json['name'] as String,
  phoneNo: json['phoneNo'] as String,
  referenceId: json['referenceId'] as String,
);

Map<String, dynamic> _$CreatePaymentUserRequestToJson(
  CreatePaymentUserRequest instance,
) => <String, dynamic>{
  'name': instance.name,
  'phoneNo': instance.phoneNo,
  'referenceId': instance.referenceId,
};

UpdatePaymentUserRequest _$UpdatePaymentUserRequestFromJson(
  Map<String, dynamic> json,
) => UpdatePaymentUserRequest(
  referenceId: json['referenceId'] as String,
  phoneNo: json['phoneNo'] as String?,
  name: json['name'] as String?,
);

Map<String, dynamic> _$UpdatePaymentUserRequestToJson(
  UpdatePaymentUserRequest instance,
) => <String, dynamic>{
  'referenceId': instance.referenceId,
  'phoneNo': instance.phoneNo,
  'name': instance.name,
};

PaymentUserResponse _$PaymentUserResponseFromJson(Map<String, dynamic> json) =>
    PaymentUserResponse(
      id: json['id'] as String?,
      name: json['name'] as String?,
      phoneNo: json['phoneNo'] as String?,
      referenceId: json['referenceId'] as String?,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
    );

Map<String, dynamic> _$PaymentUserResponseToJson(
  PaymentUserResponse instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'phoneNo': instance.phoneNo,
  'referenceId': instance.referenceId,
  'createdAt': instance.createdAt,
  'updatedAt': instance.updatedAt,
};

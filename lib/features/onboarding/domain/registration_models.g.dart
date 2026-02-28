// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'registration_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RegisterProfileRequest _$RegisterProfileRequestFromJson(
  Map<String, dynamic> json,
) => RegisterProfileRequest(
  firstName: json['firstName'] as String,
  lastName: json['lastName'] as String,
  groupName: json['groupName'] as String? ?? '',
  nickName: json['nickName'] as String,
  profileType: json['profileType'] as String,
  pin: json['pin'] as String,
  role: json['role'] as String? ?? 'USER',
  profileDocumentId: json['profileDocumentId'] as String,
  contacts: (json['contacts'] as List<dynamic>)
      .map((e) => ContactRequest.fromJson(e as Map<String, dynamic>))
      .toList(),
  address: AddressRequest.fromJson(json['address'] as Map<String, dynamic>),
  portfolio: PortfolioRequest.fromJson(
    json['portfolio'] as Map<String, dynamic>,
  ),
);

Map<String, dynamic> _$RegisterProfileRequestToJson(
  RegisterProfileRequest instance,
) => <String, dynamic>{
  'firstName': instance.firstName,
  'lastName': instance.lastName,
  'groupName': instance.groupName,
  'nickName': instance.nickName,
  'profileType': instance.profileType,
  'pin': instance.pin,
  'role': instance.role,
  'profileDocumentId': instance.profileDocumentId,
  'contacts': instance.contacts,
  'address': instance.address,
  'portfolio': instance.portfolio,
};

ContactRequest _$ContactRequestFromJson(Map<String, dynamic> json) =>
    ContactRequest(
      type: json['type'] as String,
      value: json['value'] as String,
      verificationId: json['verificationId'] as String,
    );

Map<String, dynamic> _$ContactRequestToJson(ContactRequest instance) =>
    <String, dynamic>{
      'type': instance.type,
      'value': instance.value,
      'verificationId': instance.verificationId,
    };

AddressRequest _$AddressRequestFromJson(Map<String, dynamic> json) =>
    AddressRequest(
      streetAddress: json['streetAddress'] as String,
      city: json['city'] as String,
      state: json['state'] as String,
      pinCode: (json['pinCode'] as num).toInt(),
      country: json['country'] as String,
      location: LocationRequest.fromJson(
        json['location'] as Map<String, dynamic>,
      ),
    );

Map<String, dynamic> _$AddressRequestToJson(AddressRequest instance) =>
    <String, dynamic>{
      'streetAddress': instance.streetAddress,
      'city': instance.city,
      'state': instance.state,
      'pinCode': instance.pinCode,
      'country': instance.country,
      'location': instance.location,
    };

LocationRequest _$LocationRequestFromJson(Map<String, dynamic> json) =>
    LocationRequest(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );

Map<String, dynamic> _$LocationRequestToJson(LocationRequest instance) =>
    <String, dynamic>{
      'latitude': instance.latitude,
      'longitude': instance.longitude,
    };

PortfolioRequest _$PortfolioRequestFromJson(Map<String, dynamic> json) =>
    PortfolioRequest(
      category: json['category'] as String,
      subCategory: json['subCategory'] as String,
      proficiency: json['proficiency'] as String,
      bio: json['bio'] as String,
      totalEvents: (json['totalEvents'] as num).toInt(),
      videoDocumentId: json['videoDocumentId'] as String?,
      imageDocumentId: json['imageDocumentId'] as String?,
      eventsDoneDocumentId: json['eventsDoneDocumentId'] as String?,
      hiringRate: json['hiringRate'] == null
          ? null
          : HiringRateRequest.fromJson(
              json['hiringRate'] as Map<String, dynamic>,
            ),
      follows: json['follows'] == null
          ? null
          : FollowsRequest.fromJson(json['follows'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$PortfolioRequestToJson(PortfolioRequest instance) =>
    <String, dynamic>{
      'category': instance.category,
      'subCategory': instance.subCategory,
      'proficiency': instance.proficiency,
      'bio': instance.bio,
      'totalEvents': instance.totalEvents,
      'videoDocumentId': instance.videoDocumentId,
      'imageDocumentId': instance.imageDocumentId,
      'eventsDoneDocumentId': instance.eventsDoneDocumentId,
      'hiringRate': instance.hiringRate,
      'follows': instance.follows,
    };

HiringRateRequest _$HiringRateRequestFromJson(Map<String, dynamic> json) =>
    HiringRateRequest(
      hourlyPricing: (json['hourlyPricing'] as num?)?.toDouble(),
      dailyPricing: (json['dailyPricing'] as num?)?.toDouble(),
      weeklyPricing: (json['weeklyPricing'] as num?)?.toDouble(),
      monthlyPricing: (json['monthlyPricing'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$HiringRateRequestToJson(HiringRateRequest instance) =>
    <String, dynamic>{
      'hourlyPricing': instance.hourlyPricing,
      'dailyPricing': instance.dailyPricing,
      'weeklyPricing': instance.weeklyPricing,
      'monthlyPricing': instance.monthlyPricing,
    };

FollowsRequest _$FollowsRequestFromJson(Map<String, dynamic> json) =>
    FollowsRequest(
      instaFollwers: (json['instaFollwers'] as num?)?.toInt(),
      instaFollowing: (json['instaFollowing'] as num?)?.toInt(),
      facebookFollowers: (json['facebookFollowers'] as num?)?.toInt(),
      facebookFollowing: (json['facebookFollowing'] as num?)?.toInt(),
    );

Map<String, dynamic> _$FollowsRequestToJson(FollowsRequest instance) =>
    <String, dynamic>{
      'instaFollwers': instance.instaFollwers,
      'instaFollowing': instance.instaFollowing,
      'facebookFollowers': instance.facebookFollowers,
      'facebookFollowing': instance.facebookFollowing,
    };

ProfileResponse _$ProfileResponseFromJson(Map<String, dynamic> json) =>
    ProfileResponse(
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      groupName: json['groupName'] as String,
      nickName: json['nickName'] as String,
      profileType: json['profileType'] as String,
      contacts: (json['contacts'] as List<dynamic>)
          .map((e) => ContactResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
      address: AddressResponse.fromJson(
        json['address'] as Map<String, dynamic>,
      ),
      portfolio: PortfolioResponse.fromJson(
        json['portfolio'] as Map<String, dynamic>,
      ),
    );

Map<String, dynamic> _$ProfileResponseToJson(ProfileResponse instance) =>
    <String, dynamic>{
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'groupName': instance.groupName,
      'nickName': instance.nickName,
      'profileType': instance.profileType,
      'contacts': instance.contacts,
      'address': instance.address,
      'portfolio': instance.portfolio,
    };

ContactResponse _$ContactResponseFromJson(Map<String, dynamic> json) =>
    ContactResponse(
      type: json['type'] as String,
      value: json['value'] as String,
      primary: json['primary'] as bool,
      isVerified: json['isVerified'] as bool,
    );

Map<String, dynamic> _$ContactResponseToJson(ContactResponse instance) =>
    <String, dynamic>{
      'type': instance.type,
      'value': instance.value,
      'primary': instance.primary,
      'isVerified': instance.isVerified,
    };

AddressResponse _$AddressResponseFromJson(Map<String, dynamic> json) =>
    AddressResponse(
      streetAddress: json['streetAddress'] as String,
      city: json['city'] as String,
      country: json['country'] as String,
      state: json['state'] as String,
      pinCode: (json['pinCode'] as num).toInt(),
      location: LocationResponse.fromJson(
        json['location'] as Map<String, dynamic>,
      ),
    );

Map<String, dynamic> _$AddressResponseToJson(AddressResponse instance) =>
    <String, dynamic>{
      'streetAddress': instance.streetAddress,
      'city': instance.city,
      'country': instance.country,
      'state': instance.state,
      'pinCode': instance.pinCode,
      'location': instance.location,
    };

LocationResponse _$LocationResponseFromJson(Map<String, dynamic> json) =>
    LocationResponse(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );

Map<String, dynamic> _$LocationResponseToJson(LocationResponse instance) =>
    <String, dynamic>{
      'latitude': instance.latitude,
      'longitude': instance.longitude,
    };

PortfolioResponse _$PortfolioResponseFromJson(Map<String, dynamic> json) =>
    PortfolioResponse(
      category: json['category'] as String,
      subCategory: json['subCategory'] as String,
      proficiency: json['proficiency'] as String,
      totalEvents: (json['totalEvents'] as num).toInt(),
      bio: json['bio'] as String,
      hiringRate: json['hiringRate'] as Map<String, dynamic>?,
      follows: json['follows'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$PortfolioResponseToJson(PortfolioResponse instance) =>
    <String, dynamic>{
      'category': instance.category,
      'subCategory': instance.subCategory,
      'proficiency': instance.proficiency,
      'totalEvents': instance.totalEvents,
      'bio': instance.bio,
      'hiringRate': instance.hiringRate,
      'follows': instance.follows,
    };

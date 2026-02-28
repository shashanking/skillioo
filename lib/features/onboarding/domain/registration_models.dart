import 'package:json_annotation/json_annotation.dart';

part 'registration_models.g.dart';

// ─── Request Models ───

@JsonSerializable()
class RegisterProfileRequest {
  final String firstName;
  final String lastName;
  final String groupName;
  final String nickName;
  final String profileType;
  final String pin;
  final String role;
  final String profileDocumentId;
  final List<ContactRequest> contacts;
  final AddressRequest address;
  final PortfolioRequest portfolio;

  const RegisterProfileRequest({
    required this.firstName,
    required this.lastName,
    this.groupName = '',
    required this.nickName,
    required this.profileType,
    required this.pin,
    this.role = 'USER',
    required this.profileDocumentId,
    required this.contacts,
    required this.address,
    required this.portfolio,
  });

  factory RegisterProfileRequest.fromJson(Map<String, dynamic> json) =>
      _$RegisterProfileRequestFromJson(json);

  Map<String, dynamic> toJson() => _$RegisterProfileRequestToJson(this);
}

@JsonSerializable()
class ContactRequest {
  final String type;
  final String value;
  final String verificationId;

  const ContactRequest({
    required this.type,
    required this.value,
    required this.verificationId,
  });

  factory ContactRequest.fromJson(Map<String, dynamic> json) =>
      _$ContactRequestFromJson(json);

  Map<String, dynamic> toJson() => _$ContactRequestToJson(this);
}

@JsonSerializable()
class AddressRequest {
  final String streetAddress;
  final String city;
  final String state;
  final int pinCode;
  final String country;
  final LocationRequest location;

  const AddressRequest({
    required this.streetAddress,
    required this.city,
    required this.state,
    required this.pinCode,
    required this.country,
    required this.location,
  });

  factory AddressRequest.fromJson(Map<String, dynamic> json) =>
      _$AddressRequestFromJson(json);

  Map<String, dynamic> toJson() => _$AddressRequestToJson(this);
}

@JsonSerializable()
class LocationRequest {
  final double latitude;
  final double longitude;

  const LocationRequest({
    required this.latitude,
    required this.longitude,
  });

  factory LocationRequest.fromJson(Map<String, dynamic> json) =>
      _$LocationRequestFromJson(json);

  Map<String, dynamic> toJson() => _$LocationRequestToJson(this);
}

@JsonSerializable()
class PortfolioRequest {
  final String category;
  final String subCategory;
  final String proficiency;
  final String bio;
  final int totalEvents;
  final String? videoDocumentId;
  final String? imageDocumentId;
  final String? eventsDoneDocumentId;
  final HiringRateRequest? hiringRate;
  final FollowsRequest? follows;

  const PortfolioRequest({
    required this.category,
    required this.subCategory,
    required this.proficiency,
    required this.bio,
    required this.totalEvents,
    this.videoDocumentId,
    this.imageDocumentId,
    this.eventsDoneDocumentId,
    this.hiringRate,
    this.follows,
  });

  factory PortfolioRequest.fromJson(Map<String, dynamic> json) =>
      _$PortfolioRequestFromJson(json);

  Map<String, dynamic> toJson() => _$PortfolioRequestToJson(this);
}

@JsonSerializable()
class HiringRateRequest {
  final double? hourlyPricing;
  final double? dailyPricing;
  final double? weeklyPricing;
  final double? monthlyPricing;

  const HiringRateRequest({
    this.hourlyPricing,
    this.dailyPricing,
    this.weeklyPricing,
    this.monthlyPricing,
  });

  factory HiringRateRequest.fromJson(Map<String, dynamic> json) =>
      _$HiringRateRequestFromJson(json);

  Map<String, dynamic> toJson() => _$HiringRateRequestToJson(this);
}

@JsonSerializable()
class FollowsRequest {
  final int? instaFollwers;
  final int? instaFollowing;
  final int? facebookFollowers;
  final int? facebookFollowing;

  const FollowsRequest({
    this.instaFollwers,
    this.instaFollowing,
    this.facebookFollowers,
    this.facebookFollowing,
  });

  factory FollowsRequest.fromJson(Map<String, dynamic> json) =>
      _$FollowsRequestFromJson(json);

  Map<String, dynamic> toJson() => _$FollowsRequestToJson(this);
}

// ─── Response Models ───

@JsonSerializable()
class ProfileResponse {
  final String firstName;
  final String lastName;
  final String groupName;
  final String nickName;
  final String profileType;
  final List<ContactResponse> contacts;
  final AddressResponse address;
  final PortfolioResponse portfolio;

  const ProfileResponse({
    required this.firstName,
    required this.lastName,
    required this.groupName,
    required this.nickName,
    required this.profileType,
    required this.contacts,
    required this.address,
    required this.portfolio,
  });

  factory ProfileResponse.fromJson(Map<String, dynamic> json) =>
      _$ProfileResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ProfileResponseToJson(this);
}

@JsonSerializable()
class ContactResponse {
  final String type;
  final String value;
  final bool primary;
  final bool isVerified;

  const ContactResponse({
    required this.type,
    required this.value,
    required this.primary,
    required this.isVerified,
  });

  factory ContactResponse.fromJson(Map<String, dynamic> json) =>
      _$ContactResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ContactResponseToJson(this);
}

@JsonSerializable()
class AddressResponse {
  final String streetAddress;
  final String city;
  final String country;
  final String state;
  final int pinCode;
  final LocationResponse location;

  const AddressResponse({
    required this.streetAddress,
    required this.city,
    required this.country,
    required this.state,
    required this.pinCode,
    required this.location,
  });

  factory AddressResponse.fromJson(Map<String, dynamic> json) =>
      _$AddressResponseFromJson(json);

  Map<String, dynamic> toJson() => _$AddressResponseToJson(this);
}

@JsonSerializable()
class LocationResponse {
  final double latitude;
  final double longitude;

  const LocationResponse({
    required this.latitude,
    required this.longitude,
  });

  factory LocationResponse.fromJson(Map<String, dynamic> json) =>
      _$LocationResponseFromJson(json);

  Map<String, dynamic> toJson() => _$LocationResponseToJson(this);
}

@JsonSerializable()
class PortfolioResponse {
  final String category;
  final String subCategory;
  final String proficiency;
  final int totalEvents;
  final String bio;
  final Map<String, dynamic>? hiringRate;
  final Map<String, dynamic>? follows;

  const PortfolioResponse({
    required this.category,
    required this.subCategory,
    required this.proficiency,
    required this.totalEvents,
    required this.bio,
    this.hiringRate,
    this.follows,
  });

  factory PortfolioResponse.fromJson(Map<String, dynamic> json) =>
      _$PortfolioResponseFromJson(json);

  Map<String, dynamic> toJson() => _$PortfolioResponseToJson(this);
}

// ─── Enums ───

class ProfileType {
  static const String individual = 'INDIVIDUAL';
  static const String group = 'GROUP';
}

class ContactType {
  static const String phone = 'PHONE';
  static const String email = 'EMAIL';
}

class Proficiency {
  static const String professional = 'PROFESSIONAL';
  static const String skilled = 'SKILLED';
}

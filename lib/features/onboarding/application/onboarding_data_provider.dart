import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Accumulates all onboarding form data across screens so it can be
/// submitted in a single registerProfile API call at the end.
class OnboardingData {
  // ── Identity ──
  final String firstName;
  final String lastName;
  final String groupName;
  final String nickName;
  final String profileType;
  final String pin;

  // ── Contacts ──
  final String phoneNumber;
  final String phoneVerificationId;
  final String email;
  final String emailVerificationId;

  // ── Address ──
  final String streetAddress;
  final String city;
  final String state;
  final int pinCode;
  final String country;
  final double latitude;
  final double longitude;

  // ── Portfolio ──
  final String category;
  final String subCategory;
  final String proficiency;
  final String bio;
  final int totalEvents;

  // ── Hiring Rate ──
  final double hourlyPricing;
  final double dailyPricing;
  final double weeklyPricing;
  final double monthlyPricing;

  // ── Social Media Follows (new structure) ──
  final List<Map<String, dynamic>> socialMediaFollows;

  // ── Document IDs (filled after upload) - now arrays ──
  final String profileDocumentId;
  final List<String> videoDocumentIds;
  final List<String> imageDocumentIds;
  final List<String> eventsDoneDocumentIds;

  // ── Social Links (legacy, can be removed later) ──
  final List<String> socialLinks;

  const OnboardingData({
    this.firstName = '',
    this.lastName = '',
    this.groupName = '',
    this.nickName = '',
    this.profileType = 'INDIVIDUAL',
    this.pin = '',
    this.phoneNumber = '',
    this.phoneVerificationId = '',
    this.email = '',
    this.emailVerificationId = '',
    this.streetAddress = '',
    this.city = '',
    this.state = '',
    this.pinCode = 0,
    this.country = '',
    this.latitude = 0.0,
    this.longitude = 0.0,
    this.category = '',
    this.subCategory = '',
    this.proficiency = 'PROFESSIONAL',
    this.bio = '',
    this.totalEvents = 0,
    this.hourlyPricing = 0,
    this.dailyPricing = 0,
    this.weeklyPricing = 0,
    this.monthlyPricing = 0,
    this.socialMediaFollows = const [],
    this.profileDocumentId = '',
    this.videoDocumentIds = const [],
    this.imageDocumentIds = const [],
    this.eventsDoneDocumentIds = const [],
    this.socialLinks = const [],
  });

  OnboardingData copyWith({
    String? firstName,
    String? lastName,
    String? groupName,
    String? nickName,
    String? profileType,
    String? pin,
    String? phoneNumber,
    String? phoneVerificationId,
    String? email,
    String? emailVerificationId,
    String? streetAddress,
    String? city,
    String? state,
    int? pinCode,
    String? country,
    double? latitude,
    double? longitude,
    String? category,
    String? subCategory,
    String? proficiency,
    String? bio,
    int? totalEvents,
    double? hourlyPricing,
    double? dailyPricing,
    double? weeklyPricing,
    double? monthlyPricing,
    List<Map<String, dynamic>>? socialMediaFollows,
    String? profileDocumentId,
    List<String>? videoDocumentIds,
    List<String>? imageDocumentIds,
    List<String>? eventsDoneDocumentIds,
    List<String>? socialLinks,
  }) {
    return OnboardingData(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      groupName: groupName ?? this.groupName,
      nickName: nickName ?? this.nickName,
      profileType: profileType ?? this.profileType,
      pin: pin ?? this.pin,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      phoneVerificationId: phoneVerificationId ?? this.phoneVerificationId,
      email: email ?? this.email,
      emailVerificationId: emailVerificationId ?? this.emailVerificationId,
      streetAddress: streetAddress ?? this.streetAddress,
      city: city ?? this.city,
      state: state ?? this.state,
      pinCode: pinCode ?? this.pinCode,
      country: country ?? this.country,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      category: category ?? this.category,
      subCategory: subCategory ?? this.subCategory,
      proficiency: proficiency ?? this.proficiency,
      bio: bio ?? this.bio,
      totalEvents: totalEvents ?? this.totalEvents,
      hourlyPricing: hourlyPricing ?? this.hourlyPricing,
      dailyPricing: dailyPricing ?? this.dailyPricing,
      weeklyPricing: weeklyPricing ?? this.weeklyPricing,
      monthlyPricing: monthlyPricing ?? this.monthlyPricing,
      socialMediaFollows: socialMediaFollows ?? this.socialMediaFollows,
      profileDocumentId: profileDocumentId ?? this.profileDocumentId,
      videoDocumentIds: videoDocumentIds ?? this.videoDocumentIds,
      imageDocumentIds: imageDocumentIds ?? this.imageDocumentIds,
      eventsDoneDocumentIds:
          eventsDoneDocumentIds ?? this.eventsDoneDocumentIds,
      socialLinks: socialLinks ?? this.socialLinks,
    );
  }

  /// Returns a nickName that is never identical to groupName.
  String _resolveNickName() {
    if (nickName.isNotEmpty && nickName != groupName) return nickName;
    if (firstName.isNotEmpty) {
      return '${firstName.toLowerCase()}${DateTime.now().millisecondsSinceEpoch % 10000}';
    }
    // groupName path: append suffix to guarantee uniqueness
    return '${groupName.toLowerCase()}${DateTime.now().millisecondsSinceEpoch % 10000}';
  }

  /// Build the full registration body matching the backend API spec.
  Map<String, dynamic> toRegistrationJson() {
    // Backend expects just the 10-digit number, not the +91 prefixed form.
    final rawPhone = phoneNumber.startsWith('+91')
        ? phoneNumber.substring(3)
        : phoneNumber;

    final contacts = <Map<String, dynamic>>[
      {
        'type': 'PHONE',
        'value': rawPhone,
        'verificationId': phoneVerificationId,
      },
    ];
    if (email.isNotEmpty && emailVerificationId.isNotEmpty) {
      contacts.add({
        'type': 'EMAIL',
        'value': email,
        'verificationId': emailVerificationId,
      });
    }

    return {
      'firstName': firstName,
      'lastName': lastName,
      'groupName': groupName,
      'nickName': _resolveNickName(),
      'profileType': profileType,
      'pin': pin.isNotEmpty ? pin : '0000',
      'role': 'USER',
      'profileDocumentId': profileDocumentId,
      'contacts': contacts,
      'address': {
        'streetAddress': streetAddress,
        'city': city,
        'state': state,
        'pinCode': pinCode,
        'country': country,
        'location': {'latitude': latitude, 'longitude': longitude},
      },
      'portfolio': {
        'category': category,
        'subCategory': subCategory,
        'proficiency': proficiency,
        'bio': bio,
        'totalEvents': totalEvents,
        'hiringRate': {
          'hourlyPricing': hourlyPricing,
          'dailyPricing': dailyPricing,
          'weeklyPricing': weeklyPricing,
          'monthlyPricing': monthlyPricing,
        },
        'follows': socialMediaFollows,
        'videoDocumentIds': videoDocumentIds,
        'imageDocumentIds': imageDocumentIds,
        'eventsDoneDocumentIds': eventsDoneDocumentIds,
      },
    };
  }
}

final onboardingDataProvider = StateProvider<OnboardingData>(
  (ref) => const OnboardingData(),
);

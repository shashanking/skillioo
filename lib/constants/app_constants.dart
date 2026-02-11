import 'package:flutter/material.dart';

class AppColors {
  static const Color primaryGradientStart = Color(0xFF8F39B2);
  static const Color primaryGradientMiddle = Color(0xFF2F208E);
  static const Color primaryGradientEnd = Color(0xFF0D0D0D);

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.bottomLeft,
    end: Alignment.topRight,
    colors: [primaryGradientStart, primaryGradientMiddle, primaryGradientEnd],
    stops: [0.0, 0.3045, 0.6041],
    transform: GradientRotation(201.96 * 3.14159 / 180),
  );

  static const LinearGradient ctaGradient = LinearGradient(
    // +20 degree turn relative to baseline
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
    colors: [
      Color.fromRGBO(192, 15, 139, 0.4),
      Color.fromRGBO(5, 218, 241, 0.4),
    ],
    transform: GradientRotation(320 * 3.14159 / 180),
    stops: [0.0, 0.9],
  );
}

class AppStrings {
  static const String appName = 'Skillioo';
  static const String tagline = 'INDIA\'S FIRST TALENT HUB';
  static const String welcome = 'Welcome!';
  static const String welcomeDescription =
      "We bring together a community of like-minded individuals and connections for top talent. Showcase your skills,  build your network, and land your dreams.";
  static const String letsGo = 'Let\'s Go';
  static const String trendingTimer = '1:25';
}

class AppAssets {
  static const String logoGif = 'assets/logo.gif';
  static const String logoPng = 'assets/logo.png';
  static const String loaderGif = 'assets/loader.gif';
  static const String verifiedPng = 'assets/verified.png';
  static const String thumbPng = 'assets/thumb.png';
  static const String welcomeCardLeft = 'assets/images/welcome-img-1.png';
  static const String welcomeCardCenter = 'assets/images/welcome-img-2.png';
  static const String welcomeCardRight = 'assets/images/welcome-img-3.png';
  static const String selectLanguagePng = 'assets/select-language.png';
  static const String createProfilePng = 'assets/create-profile.png';
  static const String proceedDashboardPng = 'assets/proceed-dashbaord.png';
  static const String individualProfileJpg = 'assets/individual-profile.jpg';
  static const String groupProfileJpg = 'assets/group-profile.jpg';
  static const String professionalJpg = 'assets/professional.jpg';
  static const String profileUploadPng = 'assets/images/profile-upload-img.png';
  static const String uploadIconPng = 'assets/upload.png';
  static const String menuPng = 'assets/menu.png';
  static const String locationPng = 'assets/location.png';
  static const String addPng = 'assets/add.png';
  static const String searchPng = 'assets/search.png';
  static const String micPng = 'assets/mic.png';
  static const String skilledProfileJpg = 'assets/images/skilled-profile.jpg';
  static const String professionalProfileJpg =
      'assets/images/professional-profile.jpg';
}

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

  static const Color secondaryGradientStart = Color(0xFF8F39B2);
  static const Color secondaryGradientEnd = Color(0xFF2F208E);

  // Background Gradients
  static const List<Color> primaryBackgroundGradient = [
    Color(0xFF7B2FF7),
    Color(0xFF14121A),
    Color(0xFF0C0B10),
  ];

  static const List<Color> darkBackgroundGradient = [
    Color(0xFF4A148C),
    Color(0xFF121212),
    Color(0xFF000000),
  ];

  // Glass Effect Colors
  static Color glassBackground = Colors.white.withValues(alpha: 0.1);
  static Color glassBorder = Colors.white.withValues(alpha: 0.2);
  static Color glassBackgroundDark = const Color(
    0xFF1E1E2C,
  ).withValues(alpha: 0.6);
  static Color glassBorderLight = Colors.white.withValues(alpha: 0.05);

  // Card Colors
  static const Color cardBackground = Color(0xFF1F1F1F);
  static const Color cardBorder = Color(0xFF2F2F2F);
  static const Color cardBackgroundDark = Color(0xFF2A2A2A);

  // Text Colors
  static Color textPrimary = Colors.white;
  static Color textSecondary = Colors.white.withValues(alpha: 0.9);
  static Color textTertiary = Colors.white.withValues(alpha: 0.75);
  static Color textQuaternary = Colors.white.withValues(alpha: 0.7);
  static Color textHint = Colors.white54;

  // Button Colors
  static const Color buttonPrimary = Color(0xFFB00000);
  static const Color buttonGradientStart = Color(0xFF00D9FF);
  static const Color buttonGradientEnd = Color(0xFF8F39B2);
  static const Color buttonGradientOpacityStart = Color(0x6600D9FF);
  static const Color buttonGradientOpacityEnd = Color(0x668F39B2);

  // Accent Colors
  static const Color accentCyan = Color(0xFF00D9FF);
  static const Color accentPurple = Color(0xFF8F39B2);
  static const Color accentPink = Color(0xFFC00F8B);
  static const Color accentBlue = Color(0xFF2F208E);

  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFB00000);
  static const Color warning = Color(0xFFFF9800);
  static const Color info = Color(0xFF2196F3);

  // Icon Colors
  static Color iconPrimary = Colors.white;
  static Color iconSecondary = Colors.white70;
  static Color iconTertiary = Colors.white.withValues(alpha: 0.9);

  // Border Colors
  static Color borderPrimary = Colors.white.withValues(alpha: 0.1);
  static Color borderSecondary = Colors.white.withValues(alpha: 0.2);
  static Color borderTertiary = Colors.white.withValues(alpha: 0.6);
  static Color borderAccent = const Color(0xFF05DAF1).withValues(alpha: 0.3);

  // Shadow Colors
  static Color shadowPrimary = Colors.black.withValues(alpha: 0.3);
  static Color shadowSecondary = Colors.black.withValues(alpha: 0.1);
  static Color shadowAccent = const Color(0xFF05DAF1).withValues(alpha: 0.1);

  // Navigation Colors
  static const Color navGradientStart = Color(0xFF05DAF1);
  static const Color navGradientEnd = Color(0xFFC00F8B);
  static const Color navBackground = Color(0xFF2C3E50);
}

class AppGradients {
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.primaryGradientStart, AppColors.primaryGradientEnd],
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.secondaryGradientStart, AppColors.secondaryGradientEnd],
  );

  static const LinearGradient buttonGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [AppColors.buttonGradientStart, AppColors.buttonGradientEnd],
  );

  static const LinearGradient buttonGradientOpacity = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      AppColors.buttonGradientOpacityStart,
      AppColors.buttonGradientOpacityEnd,
    ],
  );

  static const LinearGradient navGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.navGradientStart, AppColors.navGradientEnd],
  );

  static const LinearGradient tabIndicatorGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.primaryGradientEnd, AppColors.primaryGradientStart],
  );

  static LinearGradient primaryBackground = const LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: AppColors.primaryBackgroundGradient,
    stops: [0.0, 0.45, 1.0],
  );

  static LinearGradient darkBackground = const LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: AppColors.darkBackgroundGradient,
    stops: [0.0, 0.3, 1.0],
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

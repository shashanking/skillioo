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

  static const LinearGradient ctaGradientDeactivated = LinearGradient(
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
    colors: [
      Color.fromRGBO(192, 15, 139, 0.24),
      Color.fromRGBO(5, 218, 241, 0.24),
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

  // Foundation Colors (Figma tokens)
  static const Color foundationBlack20 = Color(0xFFF5F5F5);
  static const Color foundationBlack80 = Color(0xFF949494);
  static const Color foundationBlack100 = Color(0xFF757575);
  static const Color foundationBlack400 = Color(0xFF4A4A4A);
  static const Color foundationBlack800 = Color(0xFF0D0D0D);
  static const Color foundationHint = Color(0xFFB0B0B0);
  static const Color foundationTimestamp = Color(0xFFDEDEDE);
  static const Color foundationGreenNormal = Color(0xFF198754);
  static const Color foundationGreenLight = Color(0xFFE8F3EE);
  static const Color foundationErrorNormal = Color(0xFFFF0000);
  static const Color foundationErrorDark = Color(0xFFBF0000);
  static const Color foundationErrorDarkHover = Color(0xFF990000);
  static const Color foundationErrorActive = Color(0xFFCC0000);
  static const Color foundationFilterPurpleStart = Color(0xFF6B21A8);
  static const Color foundationFilterPurpleEnd = Color(0xFF3B0764);
  static Color glassWhite12 = Colors.white.withValues(alpha: 0.12);
  static Color glassWhite08 = Colors.white.withValues(alpha: 0.08);
  static Color glassWhite06 = Colors.white.withValues(alpha: 0.06);
  static Color glassWhite48 = Colors.white.withValues(alpha: 0.48);
  static Color glassWhite50 = Colors.white.withValues(alpha: 0.5);

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

  // Chat Strings
  static const String messages = 'Messages';
  static const String searchHintCoach = 'Are you looking for Coach';
  static const String searchHintGeneric = 'Are you looking for';
  static const String nowTalking = 'Now Talking';
  static const String chatWith = 'Chat With ';
  static const String coach = 'Coach';
  static const String switchToFullScreen = 'Switch To Full Screen Chat';
  static const String switchToHalfScreen = 'Switch To Half Screen Chat';
  static const String typeMessage = 'Type Your message....';
  static const String endChat = 'End Chat';
  static const String noSkillsFound = 'No skills found';
  static const String noCreatorsFound = 'No creators found';
  static const String resultsFor = 'Results for ';
  static const String filters = 'Filters';

  // Call Strings
  static const String callsSection = 'Calls Section';
  static const String today = 'Today';
  static const String yesterday = 'Yesterday';
  static const String missedCall = 'Missed Call';
  static const String outgoingCall = 'Outgoing Call';
  static const String incomingCall = 'Incoming Call';
  static const String callEnded = 'Call Ended';

  // Menu Strings
  static const String home = 'Home';
  static const String aboutUs = 'About Us';
  static const String termsAndConditions = 'Terms & Conditions';
  static const String settings = 'Settings';
  static const String faqs = 'FAQs';
  static const String favourites = 'Favourites';
  static const String languageSelection = 'Language Selection';
  static const String privacyPolicy = 'Privacy Policy';
  static const String helpAndSupport = 'Help & Support';
  static const String deleteAccount = 'Delete Account';
  static const String areYouSure = 'Are You Sure?';
  static const String deleteAccountWarning =
      'All your profile data, videos, and documents will be permanently removed. This action cannot be undone.';
  static const String cancel = 'Cancel';
  static const String continueText = 'Continue';

  // About Us Strings
  static const String aboutSkillioo = 'About Skillioo';
  static const String aboutSkilliooBody =
      'Skillioo is India\'s first talent hub — a platform built to discover, showcase, and hire skilled individuals across dance, music, acting, animation, and more.';
  static const String ourPurpose = 'Our Purpose';
  static const String ourPurposeBody =
      'We believe every talented person deserves a stage. Skillioo connects skilled creators with hirers looking for real talent — no middlemen, no gatekeeping.';
  static const String howItWorks = 'How It Works';
  static const String howItWorksBody =
      'Create your profile, upload your best work, and get discovered. Hirers can browse, shortlist, and directly connect with talent they love.';
  static const String ourVision = 'Our Vision';
  static const String ourVisionBody =
      'To become the go-to platform for talent discovery in India and beyond — empowering millions of creators to turn their passion into profession.';

  // Terms & Conditions Strings
  static const String accountAndPrivacy = 'Account & Privacy';
  static const String accountAndPrivacyBody =
      'Users must provide accurate details during registration. Personal data (name, contact info) stays hidden until hiring, ensuring privacy.';
  static const String contentUpload = 'Content Upload';
  static const String contentUploadBody =
      'Only upload original videos, images or certificates related to your skills. No copyrighted, offensive or misleading content is allowed.';
  static const String paymentsAndSubscriptions = 'Payments & Subscriptions';
  static const String paymentsAndSubscriptionsBody =
      'Paid features (like profile visibility or hiring access) are non-refundable once activated.';
  static const String behaviorAndSafety = 'Behavior & Safety';
  static const String behaviorAndSafetyBody =
      'Harassment, hate speech or misuse of the platform will lead to account suspension.';
  static const String rightsAndOwnership = 'Rights & Ownership';
  static const String rightsAndOwnershipBody =
      'You own your uploaded content but grant Skillioo permission to display it publicly within the app.';
  static const String modifications = 'Modifications';
  static const String modificationsBody =
      'Skillioo may update these terms at any time. Continued use of the app means you accept the latest version.';

  // Help & Support Strings
  static const String accountHelp = 'Account Help';
  static const String accountHelpBody =
      'Trouble logging in or verifying your number? Tap Forgot PIN or Resend OTP to recover access.';
  static const String profileAndUploads = 'Profile & Uploads';
  static const String profileAndUploadsBody =
      'Having issues uploading videos or documents? Check your internet connection or file size (max 200MB).';
  static const String hiringOrPickTalent = 'Hiring or "Pick the Talent"';
  static const String hiringOrPickTalentBody =
      'Didn\'t receive a response? Allow notifications and check the requests regularly.';
  static const String payments = 'Payments';
  static const String paymentsBody =
      'Payment not showing? Wait a few minutes or contact support with your transaction ID.';
  static const String contactSupport = 'Contact Support';
  static const String contactSupportBody =
      'support@skillioo.com\nAvailable : 9 AM - 6 PM (Mon - Sat)';

  // Privacy Policy Strings
  static const String privacyPolicyBody =
      'Skillioo respects your privacy and is committed to protecting your personal information. We collect basic details such as your name, email, phone number, and location only to verify your account, create your profile, and improve your experience.\n\nAll personal data is encrypted and remains hidden from others until you are hired. You own the videos, images, and certificates you upload. Skillioo only displays them within the app to connect you with opportunities.\n\nWe do not share or sell your personal data to third parties without your consent. You can edit or delete your data anytime through your account settings.\n\nSkillioo may update this policy from time to time, and you\'ll be notified of any major changes within the app.';

  // Settings Strings
  static const String appLanguage = 'App Language';
  static const String biometrics = 'Biometrics';
  static const String notificationPreferences = 'Notification Preferences';
  static const String notifications = 'Notifications';
  static const String likesCommentsFollow = 'Likes , Comments & Follow';
  static const String messagesCalls = 'Messages/Calls';
  static const String securityAlerts = 'Security Alerts';

  // Language Selection Strings
  static const String selectYourLanguage = 'Select Your Language';
  static const String languageSubtitle =
      'Tell us how you\'d like the app to talk to you.';

  // FAQs Strings
  static const String faqQ1 = 'Q.1 What is Skillioo?';
  static const String faqQ2 = 'Q.2 How do I create a profile?';
  static const String faqQ3 = 'Q.3 Is Skillioo free to use?';
  static const String faqQ4 = 'Q.4 How do hirers find me?';

  // Biometrics Strings
  static const String fingerprint1 = 'Fingerprint 1';
  static const String fingerprint2 = 'Fingerprint 2';
  static const String addNewFingerprint = 'Add New Fingerprint';
  static const String verifyIdentity = 'Verify Identity';
  static const String verifyIdentityBody =
      'Place your finger on the sensor to verify your identity before adding a new fingerprint.';
  static const String verificationFailed = 'Verification Failed';
  static const String verificationFailedBody =
      'Could not verify your identity. Please try again.';
  static const String placeYourFinger = 'Place Your Finger';
  static const String placeYourFingerBody =
      'Place your finger on the sensor to register a new fingerprint.';
  static const String fingerprintAdded = 'Fingerprint Added';
  static const String fingerprintAddedBody =
      'Your new fingerprint has been registered successfully.';
  static const String tryAgain = 'Try Again';
  static const String done = 'Done';
  static const String deleteFingerprint = 'Delete Fingerprint';
  static const String deleteFingerprintBody =
      'Are you sure you want to remove this fingerprint? You will need to re-register it to use it again.';

  // Favourites Strings
  static const String professional = 'Professional';
  static const String skilled = 'Skilled';

  // Pin Setup Strings
  static const String pinSetup = 'Pin Setup';
  static const String enterOtp = 'Enter OTP';
  static const String enterOtpBody =
      'We have sent a 4-digit OTP on mobile number 87******99.';
  static const String invalidOtp = 'Invalid OTP';
  static const String invalidOtpBody =
      'Resend OTP on your mobile number and verify once again.';
  static const String resendOtp = 'Resend OTP';
  static const String enterNewPin = 'Enter New Pin';
  static const String enterNewPinBody = 'Please enter a 4-digit pin.';
  static const String enterNewPinAgain = 'Enter New Pin Again';
  static const String enterNewPinAgainBody = 'Please enter new pin again.';
  static const String pinMismatch = 'Pin Mismatch';
  static const String pinMismatchBody =
      'The pins you entered do not match. Please try again.';
  static const String verifying = 'Verifying...';
  static const String verify = 'Verify';
  static const String confirm = 'Confirm';

  // Edit Hiring Charges Strings
  static const String editHiringCharges = 'Edit Hiring Charges';
  static const String hourlyPricing = 'Hourly Pricing';
  static const String dailyPricing = 'Daily Pricing';
  static const String weeklyPricing = 'Weekly Pricing';
  static const String monthlyPricing = 'Monthly Pricing';
  static const String saveChanges = 'Save Changes';
  static const String saving = 'Saving...';
  static const String changesSaved = 'Changes Saved';
  static const String somethingWentWrong = 'Something Went Wrong, Try Again.';

  // Edit Profile Strings
  static const String editProfile = 'Edit Profile';
  static const String changeProfilePicture = 'Change Profile Picture';
  static const String firstName = 'First Name';
  static const String lastName = 'Last Name';
  static const String eventsCount = 'Events Count';
  static const String accountsBinded = 'Accounts Binded';
  static const String addAccount = 'Add Account';
  static const String followers = 'Followers';

  // Profile Section Strings
  static const String profileSection = 'Profile Section';
  static const String chatHistory = 'Chat History';
  static const String privacy = 'Privacy';
  static const String publicOption = 'Public';
  static const String friendsOption = 'Friends';
  static const String privateOption = 'Private';
  static const String chatLastedFor = 'Chat lasted for';
  static const String mins = 'mins';
  static const String hour = 'hour';

  // Comments Strings
  static const String comments = 'Comments';
  static const String shareYourThoughts = 'Share your thoughts....';
  static const String reply = 'Reply';
  static const String likes = 'Likes';

  static const String skip = 'Skip';

  // In-App Notifications Strings
  static const String likedYourPost = 'liked your post.';
  static const String commentedOnYourPost = 'commented on your post';
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
  static const String profileImg1 = 'assets/images/profile-img-1.jpg';
  static const String sendPng = 'assets/send.png';
  static const String dialSquarePng = 'assets/dial-sqare.png';

  // Icons
  static const String callSvg = 'assets/icons/call.svg';
  static const String messageSvg = 'assets/icons/message.svg';
}

// Custom page transition duration (used app-wide)
class AppTransitions {
  static const Duration duration = Duration(milliseconds: 800);
}

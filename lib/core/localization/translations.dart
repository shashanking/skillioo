import 'app_locale.dart';

class Translations {
  final AppLocale locale;

  const Translations(this.locale);

  String get(String key) {
    return _translations[locale]?[key] ??
        _translations[AppLocale.en]?[key] ??
        key;
  }

  // ── App ──
  String get appName => get('appName');
  String get tagline => get('tagline');

  // ── Welcome / Onboarding ──
  String get welcome => get('welcome');
  String get welcomeDescription => get('welcomeDescription');
  String get letsGo => get('letsGo');
  String get welcomeToSkillioo => get('welcomeToSkillioo');
  String get selectAppLanguage => get('selectAppLanguage');
  String get createProfile => get('createProfile');
  String get proceedToDashboard => get('proceedToDashboard');
  String get skip => get('skip');
  String get next => get('next');
  String get back => get('back');
  String get continueText => get('continueText');

  // ── Auth ──
  String get enterPhoneNumber => get('enterPhoneNumber');
  String get phoneNumberHint => get('phoneNumberHint');
  String get sendOtp => get('sendOtp');
  String get enterOtp => get('enterOtp');
  String get enterOtpBody => get('enterOtpBody');
  String get invalidOtp => get('invalidOtp');
  String get invalidOtpBody => get('invalidOtpBody');
  String get resendOtp => get('resendOtp');
  String get verify => get('verify');
  String get verifying => get('verifying');
  String get verified => get('verified');
  String get enterPin => get('enterPin');
  String get enterPinBody => get('enterPinBody');
  String get enterNewPin => get('enterNewPin');
  String get enterNewPinBody => get('enterNewPinBody');
  String get enterNewPinAgain => get('enterNewPinAgain');
  String get enterNewPinAgainBody => get('enterNewPinAgainBody');
  String get pinMismatch => get('pinMismatch');
  String get pinMismatchBody => get('pinMismatchBody');
  String get pinSetup => get('pinSetup');
  String get confirm => get('confirm');

  // ── Profile ──
  String get profileSection => get('profileSection');
  String get editProfile => get('editProfile');
  String get changeProfilePicture => get('changeProfilePicture');
  String get firstName => get('firstName');
  String get lastName => get('lastName');
  String get groupName => get('groupName');
  String get email => get('email');
  String get phoneNumber => get('phoneNumber');
  String get address => get('address');
  String get streetAddress => get('streetAddress');
  String get city => get('city');
  String get state => get('state');
  String get country => get('country');
  String get pinCode => get('pinCode');
  String get bio => get('bio');
  String get eventsCount => get('eventsCount');
  String get accountsBinded => get('accountsBinded');
  String get addAccount => get('addAccount');
  String get followers => get('followers');
  String get following => get('following');
  String get reactions => get('reactions');
  String get impressions => get('impressions');
  String get videos => get('videos');
  String get posts => get('posts');
  String get views => get('views');
  String get online => get('online');
  String get offline => get('offline');
  String get professional => get('professional');
  String get skilled => get('skilled');
  String get individual => get('individual');
  String get group => get('group');

  // ── Profile Type / Talent ──
  String get selectProfileType => get('selectProfileType');
  String get selectTalentCategory => get('selectTalentCategory');
  String get selectTalentSubcategory => get('selectTalentSubcategory');
  String get selectTalentType => get('selectTalentType');
  String get uploadProfilePhoto => get('uploadProfilePhoto');
  String get uploadVideos => get('uploadVideos');
  String get uploadCertificates => get('uploadCertificates');
  String get professionalBio => get('professionalBio');
  String get socialLinks => get('socialLinks');
  String get eventsPerformed => get('eventsPerformed');

  // ── Chat ──
  String get messages => get('messages');
  String get searchHintCoach => get('searchHintCoach');
  String get searchHintGeneric => get('searchHintGeneric');
  String get nowTalking => get('nowTalking');
  String get chatWith => get('chatWith');
  String get coach => get('coach');
  String get switchToFullScreen => get('switchToFullScreen');
  String get switchToHalfScreen => get('switchToHalfScreen');
  String get typeMessage => get('typeMessage');
  String get endChat => get('endChat');
  String get noSkillsFound => get('noSkillsFound');
  String get noCreatorsFound => get('noCreatorsFound');
  String get resultsFor => get('resultsFor');
  String get filters => get('filters');
  String get chatHistory => get('chatHistory');
  String get chatLastedFor => get('chatLastedFor');
  String get mins => get('mins');
  String get hour => get('hour');

  // ── Call ──
  String get callsSection => get('callsSection');
  String get today => get('today');
  String get yesterday => get('yesterday');
  String get missedCall => get('missedCall');
  String get outgoingCall => get('outgoingCall');
  String get incomingCall => get('incomingCall');
  String get callEnded => get('callEnded');
  String get call => get('call');
  String get chat => get('chat');

  // ── Menu ──
  String get home => get('home');
  String get aboutUs => get('aboutUs');
  String get termsAndConditions => get('termsAndConditions');
  String get settings => get('settings');
  String get faqs => get('faqs');
  String get favourites => get('favourites');
  String get languageSelection => get('languageSelection');
  String get privacyPolicy => get('privacyPolicy');
  String get helpAndSupport => get('helpAndSupport');
  String get deleteAccount => get('deleteAccount');
  String get areYouSure => get('areYouSure');
  String get deleteAccountWarning => get('deleteAccountWarning');
  String get cancel => get('cancel');
  String get logout => get('logout');

  // ── About Us ──
  String get aboutSkillioo => get('aboutSkillioo');
  String get aboutSkilliooBody => get('aboutSkilliooBody');
  String get ourPurpose => get('ourPurpose');
  String get ourPurposeBody => get('ourPurposeBody');
  String get howItWorks => get('howItWorks');
  String get howItWorksBody => get('howItWorksBody');
  String get ourVision => get('ourVision');
  String get ourVisionBody => get('ourVisionBody');

  // ── Terms & Conditions ──
  String get accountAndPrivacy => get('accountAndPrivacy');
  String get accountAndPrivacyBody => get('accountAndPrivacyBody');
  String get contentUpload => get('contentUpload');
  String get contentUploadBody => get('contentUploadBody');
  String get paymentsAndSubscriptions => get('paymentsAndSubscriptions');
  String get paymentsAndSubscriptionsBody =>
      get('paymentsAndSubscriptionsBody');
  String get behaviorAndSafety => get('behaviorAndSafety');
  String get behaviorAndSafetyBody => get('behaviorAndSafetyBody');
  String get rightsAndOwnership => get('rightsAndOwnership');
  String get rightsAndOwnershipBody => get('rightsAndOwnershipBody');
  String get modifications => get('modifications');
  String get modificationsBody => get('modificationsBody');

  // ── Help & Support ──
  String get accountHelp => get('accountHelp');
  String get accountHelpBody => get('accountHelpBody');
  String get profileAndUploads => get('profileAndUploads');
  String get profileAndUploadsBody => get('profileAndUploadsBody');
  String get hiringOrPickTalent => get('hiringOrPickTalent');
  String get hiringOrPickTalentBody => get('hiringOrPickTalentBody');
  String get payments => get('payments');
  String get paymentsBody => get('paymentsBody');
  String get contactSupport => get('contactSupport');
  String get contactSupportBody => get('contactSupportBody');

  // ── Privacy Policy ──
  String get privacyPolicyBody => get('privacyPolicyBody');

  // ── Settings ──
  String get appLanguage => get('appLanguage');
  String get biometrics => get('biometrics');
  String get notificationPreferences => get('notificationPreferences');
  String get notifications => get('notifications');
  String get likesCommentsFollow => get('likesCommentsFollow');
  String get messagesCalls => get('messagesCalls');
  String get securityAlerts => get('securityAlerts');

  // ── Language Selection ──
  String get selectYourLanguage => get('selectYourLanguage');
  String get languageSubtitle => get('languageSubtitle');

  // ── FAQs ──
  String get faqQ1 => get('faqQ1');
  String get faqQ2 => get('faqQ2');
  String get faqQ3 => get('faqQ3');
  String get faqQ4 => get('faqQ4');
  String get faqA3 => get('faqA3');
  String get faqA4 => get('faqA4');

  // ── Biometrics ──
  String get fingerprint1 => get('fingerprint1');
  String get fingerprint2 => get('fingerprint2');
  String get addNewFingerprint => get('addNewFingerprint');
  String get verifyIdentity => get('verifyIdentity');
  String get verifyIdentityBody => get('verifyIdentityBody');
  String get verificationFailed => get('verificationFailed');
  String get verificationFailedBody => get('verificationFailedBody');
  String get placeYourFinger => get('placeYourFinger');
  String get placeYourFingerBody => get('placeYourFingerBody');
  String get fingerprintAdded => get('fingerprintAdded');
  String get fingerprintAddedBody => get('fingerprintAddedBody');
  String get tryAgain => get('tryAgain');
  String get done => get('done');
  String get deleteFingerprint => get('deleteFingerprint');
  String get deleteFingerprintBody => get('deleteFingerprintBody');

  // ── Favourites ──
  String get addedToFavorites => get('addedToFavorites');

  // ── Hiring Charges ──
  String get editHiringCharges => get('editHiringCharges');
  String get hourlyPricing => get('hourlyPricing');
  String get dailyPricing => get('dailyPricing');
  String get weeklyPricing => get('weeklyPricing');
  String get monthlyPricing => get('monthlyPricing');
  String get saveChanges => get('saveChanges');
  String get saving => get('saving');
  String get changesSaved => get('changesSaved');
  String get somethingWentWrong => get('somethingWentWrong');

  // ── Comments ──
  String get comments => get('comments');
  String get shareYourThoughts => get('shareYourThoughts');
  String get reply => get('reply');
  String get likes => get('likes');
  String get noCommentsYet => get('noCommentsYet');

  // ── Notifications ──
  String get likedYourPost => get('likedYourPost');
  String get commentedOnYourPost => get('commentedOnYourPost');

  // ── Dashboard / Feed ──
  String get reels => get('reels');
  String get explore => get('explore');
  String get forYou => get('forYou');
  String get trending => get('trending');
  String get follow => get('follow');
  String get unfollow => get('unfollow');
  String get share => get('share');
  String get noPostsYet => get('noPostsYet');
  String get loadMore => get('loadMore');
  String get retry => get('retry');
  String get noProfilesAvailable => get('noProfilesAvailable');
  String get failedToLoadProfiles => get('failedToLoadProfiles');
  String get search => get('search');
  String get viewCharges => get('viewCharges');

  // ── Subscription ──
  String get subscription => get('subscription');
  String get subscriptionRequired => get('subscriptionRequired');
  String get subscriptionRequiredBody => get('subscriptionRequiredBody');
  String get viewPlans => get('viewPlans');
  String get upgrade => get('upgrade');
  String get completePayment => get('completePayment');
  String get subscribedSuccessfully => get('subscribedSuccessfully');
  String get perMonth => get('perMonth');
  String get subscribe => get('subscribe');
  String get choosePlan => get('choosePlan');
  String get currentPlan => get('currentPlan');

  // ── Post Creation ──
  String get createPost => get('createPost');
  String get selectMedia => get('selectMedia');
  String get caption => get('caption');
  String get post => get('post');
  String get posting => get('posting');

  // ── Social ──
  String get social => get('social');
  String get general => get('general');
  String get privacy => get('privacy');
  String get publicOption => get('publicOption');
  String get friendsOption => get('friendsOption');
  String get privateOption => get('privateOption');

  // ── Location ──
  String get selectLocation => get('selectLocation');
  String get searchLocation => get('searchLocation');

  // ── Misc ──
  String get trendingTimer => get('trendingTimer');
  String get noResultsFound => get('noResultsFound');
  String get loading => get('loading');
  String get error => get('error');
  String get success => get('success');
  String get ok => get('ok');
  String get yes => get('yes');
  String get no => get('no');
  String get close => get('close');
  String get delete => get('delete');
  String get edit => get('edit');
  String get save => get('save');
  String get update => get('update');
  String get add => get('add');
  String get remove => get('remove');

  static const Map<AppLocale, Map<String, String>> _translations = {
    // ════════════════════════════════════════
    // ENGLISH
    // ════════════════════════════════════════
    AppLocale.en: {
      'appName': 'Skillioo',
      'tagline': "INDIA'S FIRST TALENT HUB",
      'welcome': 'Welcome!',
      'welcomeDescription':
          "We bring together a community of like-minded individuals and connections for top talent. Showcase your skills, build your network, and land your dreams.",
      'letsGo': "Let's Go",
      'welcomeToSkillioo': 'Welcome to Skillioo',
      'selectAppLanguage': 'Select App Language',
      'createProfile': 'Create Profile',
      'proceedToDashboard': 'Proceed To Dashboard',
      'skip': 'Skip',
      'next': 'Next',
      'back': 'Back',
      'continueText': 'Continue',
      'enterPhoneNumber': 'Enter Phone Number',
      'phoneNumberHint': 'Phone Number',
      'sendOtp': 'Send OTP',
      'enterOtp': 'Enter OTP',
      'enterOtpBody': 'We have sent a 4-digit OTP on your mobile number.',
      'invalidOtp': 'Invalid OTP',
      'invalidOtpBody':
          'Resend OTP on your mobile number and verify once again.',
      'resendOtp': 'Resend OTP',
      'verify': 'Verify',
      'verifying': 'Verifying...',
      'verified': 'Verified',
      'enterPin': 'Enter Pin',
      'enterPinBody': 'Please enter your 4-digit pin.',
      'enterNewPin': 'Enter New Pin',
      'enterNewPinBody': 'Please enter a 4-digit pin.',
      'enterNewPinAgain': 'Enter New Pin Again',
      'enterNewPinAgainBody': 'Please enter new pin again.',
      'pinMismatch': 'Pin Mismatch',
      'pinMismatchBody': 'The pins you entered do not match. Please try again.',
      'pinSetup': 'Pin Setup',
      'confirm': 'Confirm',
      'profileSection': 'Profile Section',
      'editProfile': 'Edit Profile',
      'changeProfilePicture': 'Change Profile Picture',
      'firstName': 'First Name',
      'lastName': 'Last Name',
      'groupName': 'Group Name',
      'email': 'Email',
      'phoneNumber': 'Phone Number',
      'address': 'Address',
      'streetAddress': 'Street Address',
      'city': 'City',
      'state': 'State',
      'country': 'Country',
      'pinCode': 'Pin Code',
      'bio': 'Bio',
      'eventsCount': 'Events Count',
      'accountsBinded': 'Accounts Binded',
      'addAccount': 'Add Account',
      'followers': 'Followers',
      'following': 'Following',
      'reactions': 'Reactions',
      'impressions': 'Impressions',
      'videos': 'Videos',
      'posts': 'Posts',
      'views': 'Views',
      'online': 'Online',
      'offline': 'Offline',
      'professional': 'Professional',
      'skilled': 'Skilled',
      'individual': 'Individual',
      'group': 'Group',
      'selectProfileType': 'Select Profile Type',
      'selectTalentCategory': 'Select Talent Category',
      'selectTalentSubcategory': 'Select Talent Subcategory',
      'selectTalentType': 'Select Talent Type',
      'uploadProfilePhoto': 'Upload Profile Photo',
      'uploadVideos': 'Upload Videos',
      'uploadCertificates': 'Upload Certificates',
      'professionalBio': 'Professional Bio',
      'socialLinks': 'Social Links',
      'eventsPerformed': 'Events Performed',
      'messages': 'Messages',
      'searchHintCoach': 'Are you looking for Coach',
      'searchHintGeneric': 'Are you looking for',
      'nowTalking': 'Now Talking',
      'chatWith': 'Chat With ',
      'coach': 'Coach',
      'switchToFullScreen': 'Switch To Full Screen Chat',
      'switchToHalfScreen': 'Switch To Half Screen Chat',
      'typeMessage': 'Type Your message....',
      'endChat': 'End Chat',
      'noSkillsFound': 'No skills found',
      'noCreatorsFound': 'No creators found',
      'resultsFor': 'Results for ',
      'filters': 'Filters',
      'chatHistory': 'Chat History',
      'chatLastedFor': 'Chat lasted for',
      'mins': 'mins',
      'hour': 'hour',
      'callsSection': 'Calls Section',
      'today': 'Today',
      'yesterday': 'Yesterday',
      'missedCall': 'Missed Call',
      'outgoingCall': 'Outgoing Call',
      'incomingCall': 'Incoming Call',
      'callEnded': 'Call Ended',
      'call': 'Call',
      'chat': 'Chat',
      'home': 'Home',
      'aboutUs': 'About Us',
      'termsAndConditions': 'Terms & Conditions',
      'settings': 'Settings',
      'faqs': 'FAQs',
      'favourites': 'Favourites',
      'languageSelection': 'Language Selection',
      'privacyPolicy': 'Privacy Policy',
      'helpAndSupport': 'Help & Support',
      'deleteAccount': 'Delete Account',
      'areYouSure': 'Are You Sure?',
      'deleteAccountWarning':
          'All your profile data, videos, and documents will be permanently removed. This action cannot be undone.',
      'cancel': 'Cancel',
      'logout': 'Logout',
      'aboutSkillioo': 'About Skillioo',
      'aboutSkilliooBody':
          "Skillioo is India's first talent hub — a platform built to discover, showcase, and hire skilled individuals across dance, music, acting, animation, and more.",
      'ourPurpose': 'Our Purpose',
      'ourPurposeBody':
          'We believe every talented person deserves a stage. Skillioo connects skilled creators with hirers looking for real talent — no middlemen, no gatekeeping.',
      'howItWorks': 'How It Works',
      'howItWorksBody':
          'Create your profile, upload your best work, and get discovered. Hirers can browse, shortlist, and directly connect with talent they love.',
      'ourVision': 'Our Vision',
      'ourVisionBody':
          'To become the go-to platform for talent discovery in India and beyond — empowering millions of creators to turn their passion into profession.',
      'accountAndPrivacy': 'Account & Privacy',
      'accountAndPrivacyBody':
          'Users must provide accurate details during registration. Personal data (name, contact info) stays hidden until hiring, ensuring privacy.',
      'contentUpload': 'Content Upload',
      'contentUploadBody':
          'Only upload original videos, images or certificates related to your skills. No copyrighted, offensive or misleading content is allowed.',
      'paymentsAndSubscriptions': 'Payments & Subscriptions',
      'paymentsAndSubscriptionsBody':
          'Paid features (like profile visibility or hiring access) are non-refundable once activated.',
      'behaviorAndSafety': 'Behavior & Safety',
      'behaviorAndSafetyBody':
          'Harassment, hate speech or misuse of the platform will lead to account suspension.',
      'rightsAndOwnership': 'Rights & Ownership',
      'rightsAndOwnershipBody':
          'You own your uploaded content but grant Skillioo permission to display it publicly within the app.',
      'modifications': 'Modifications',
      'modificationsBody':
          'Skillioo may update these terms at any time. Continued use of the app means you accept the latest version.',
      'accountHelp': 'Account Help',
      'accountHelpBody':
          'Trouble logging in or verifying your number? Tap Forgot PIN or Resend OTP to recover access.',
      'profileAndUploads': 'Profile & Uploads',
      'profileAndUploadsBody':
          "Having issues uploading videos or documents? Check your internet connection or file size (max 200MB).",
      'hiringOrPickTalent': 'Hiring or "Pick the Talent"',
      'hiringOrPickTalentBody':
          "Didn't receive a response? Allow notifications and check the requests regularly.",
      'payments': 'Payments',
      'paymentsBody':
          'Payment not showing? Wait a few minutes or contact support with your transaction ID.',
      'contactSupport': 'Contact Support',
      'contactSupportBody':
          'support@skillioo.com\nAvailable : 9 AM - 6 PM (Mon - Sat)',
      'privacyPolicyBody':
          "Skillioo respects your privacy and is committed to protecting your personal information. We collect basic details such as your name, email, phone number, and location only to verify your account, create your profile, and improve your experience.\n\nAll personal data is encrypted and remains hidden from others until you are hired. You own the videos, images, and certificates you upload. Skillioo only displays them within the app to connect you with opportunities.\n\nWe do not share or sell your personal data to third parties without your consent. You can edit or delete your data anytime through your account settings.\n\nSkillioo may update this policy from time to time, and you'll be notified of any major changes within the app.",
      'appLanguage': 'App Language',
      'biometrics': 'Biometrics',
      'notificationPreferences': 'Notification Preferences',
      'notifications': 'Notifications',
      'likesCommentsFollow': 'Likes , Comments & Follow',
      'messagesCalls': 'Messages/Calls',
      'securityAlerts': 'Security Alerts',
      'selectYourLanguage': 'Select Your Language',
      'languageSubtitle': "Tell us how you'd like the app to talk to you.",
      'faqQ1': 'Q.1 What is Skillioo?',
      'faqQ2': 'Q.2 How do I create a profile?',
      'faqQ3': 'Q.3 Is Skillioo free to use?',
      'faqQ4': 'Q.4 How do hirers find me?',
      'faqA3':
          'Yes! Creating a profile and showcasing your talent is completely free. Some premium features may require a subscription.',
      'faqA4':
          'Hirers can browse talent by category, watch your videos, view your certificates, and directly connect with you through the app.',
      'fingerprint1': 'Fingerprint 1',
      'fingerprint2': 'Fingerprint 2',
      'addNewFingerprint': 'Add New Fingerprint',
      'verifyIdentity': 'Verify Identity',
      'verifyIdentityBody':
          'Place your finger on the sensor to verify your identity before adding a new fingerprint.',
      'verificationFailed': 'Verification Failed',
      'verificationFailedBody':
          'Could not verify your identity. Please try again.',
      'placeYourFinger': 'Place Your Finger',
      'placeYourFingerBody':
          'Place your finger on the sensor to register a new fingerprint.',
      'fingerprintAdded': 'Fingerprint Added',
      'fingerprintAddedBody':
          'Your new fingerprint has been registered successfully.',
      'tryAgain': 'Try Again',
      'done': 'Done',
      'deleteFingerprint': 'Delete Fingerprint',
      'deleteFingerprintBody':
          'Are you sure you want to remove this fingerprint? You will need to re-register it to use it again.',
      'addedToFavorites': 'Added to favorites',
      'editHiringCharges': 'Edit Hiring Charges',
      'hourlyPricing': 'Hourly Pricing',
      'dailyPricing': 'Daily Pricing',
      'weeklyPricing': 'Weekly Pricing',
      'monthlyPricing': 'Monthly Pricing',
      'saveChanges': 'Save Changes',
      'saving': 'Saving...',
      'changesSaved': 'Changes Saved',
      'somethingWentWrong': 'Something Went Wrong, Try Again.',
      'comments': 'Comments',
      'shareYourThoughts': 'Share your thoughts....',
      'reply': 'Reply',
      'likes': 'Likes',
      'noCommentsYet': 'No comments yet',
      'likedYourPost': 'liked your post.',
      'commentedOnYourPost': 'commented on your post',
      'reels': 'Reels',
      'explore': 'Explore',
      'forYou': 'For You',
      'trending': 'Trending Talents',
      'follow': 'Follow',
      'unfollow': 'Following',
      'share': 'Share',
      'noPostsYet': 'No posts yet',
      'loadMore': 'Load more',
      'retry': 'Retry',
      'noProfilesAvailable': 'No profiles available',
      'failedToLoadProfiles': 'Failed to load profiles',
      'search': 'Search',
      'viewCharges': 'View Charges',
      'subscription': 'Subscription',
      'subscriptionRequired': 'Subscription Required',
      'subscriptionRequiredBody':
          'You need an active subscription to use this feature.',
      'viewPlans': 'View Plans',
      'upgrade': 'Upgrade',
      'completePayment': 'Complete Payment',
      'subscribedSuccessfully': 'Subscribed Successfully',
      'perMonth': '/month',
      'subscribe': 'Subscribe',
      'choosePlan': 'Choose a Plan',
      'currentPlan': 'Current Plan',
      'createPost': 'Create Post',
      'selectMedia': 'Select Media',
      'caption': 'Caption',
      'post': 'Post',
      'posting': 'Posting...',
      'social': 'Social',
      'general': 'General',
      'privacy': 'Privacy',
      'publicOption': 'Public',
      'friendsOption': 'Friends',
      'privateOption': 'Private',
      'selectLocation': 'Select Location',
      'searchLocation': 'Search Location',
      'trendingTimer': '1:25',
      'noResultsFound': 'No results found',
      'loading': 'Loading...',
      'error': 'Error',
      'success': 'Success',
      'ok': 'OK',
      'yes': 'Yes',
      'no': 'No',
      'close': 'Close',
      'delete': 'Delete',
      'edit': 'Edit',
      'save': 'Save',
      'update': 'Update',
      'add': 'Add',
      'remove': 'Remove',
    },

    // ════════════════════════════════════════
    // HINDI
    // ════════════════════════════════════════
    AppLocale.hi: {
      'appName': 'स्किलियो',
      'tagline': 'भारत का पहला टैलेंट हब',
      'welcome': 'स्वागत है!',
      'welcomeDescription':
          'हम समान विचारधारा वाले लोगों और शीर्ष प्रतिभाओं के लिए कनेक्शन का एक समुदाय बनाते हैं। अपनी प्रतिभा दिखाएं, नेटवर्क बनाएं और सपने पूरे करें।',
      'letsGo': 'चलो शुरू करें',
      'welcomeToSkillioo': 'स्किलियो में आपका स्वागत है',
      'selectAppLanguage': 'ऐप भाषा चुनें',
      'createProfile': 'प्रोफ़ाइल बनाएं',
      'proceedToDashboard': 'डैशबोर्ड पर जाएं',
      'skip': 'छोड़ें',
      'next': 'आगे',
      'back': 'पीछे',
      'continueText': 'जारी रखें',
      'enterPhoneNumber': 'फ़ोन नंबर दर्ज करें',
      'phoneNumberHint': 'फ़ोन नंबर',
      'sendOtp': 'OTP भेजें',
      'enterOtp': 'OTP दर्ज करें',
      'enterOtpBody': 'हमने आपके मोबाइल नंबर पर 4 अंकों का OTP भेजा है।',
      'invalidOtp': 'गलत OTP',
      'invalidOtpBody':
          'अपने मोबाइल नंबर पर OTP दोबारा भेजें और फिर से सत्यापित करें।',
      'resendOtp': 'OTP दोबारा भेजें',
      'verify': 'सत्यापित करें',
      'verifying': 'सत्यापित हो रहा है...',
      'verified': 'सत्यापित',
      'enterPin': 'पिन दर्ज करें',
      'enterPinBody': 'कृपया अपना 4 अंकों का पिन दर्ज करें।',
      'enterNewPin': 'नया पिन दर्ज करें',
      'enterNewPinBody': 'कृपया 4 अंकों का पिन दर्ज करें।',
      'enterNewPinAgain': 'नया पिन दोबारा दर्ज करें',
      'enterNewPinAgainBody': 'कृपया नया पिन दोबारा दर्ज करें।',
      'pinMismatch': 'पिन मेल नहीं खाता',
      'pinMismatchBody':
          'आपने जो पिन दर्ज किए वे मेल नहीं खाते। कृपया पुनः प्रयास करें।',
      'pinSetup': 'पिन सेटअप',
      'confirm': 'पुष्टि करें',
      'profileSection': 'प्रोफ़ाइल अनुभाग',
      'editProfile': 'प्रोफ़ाइल संपादित करें',
      'changeProfilePicture': 'प्रोफ़ाइल फ़ोटो बदलें',
      'firstName': 'पहला नाम',
      'lastName': 'अंतिम नाम',
      'groupName': 'समूह का नाम',
      'email': 'ईमेल',
      'phoneNumber': 'फ़ोन नंबर',
      'address': 'पता',
      'streetAddress': 'गली का पता',
      'city': 'शहर',
      'state': 'राज्य',
      'country': 'देश',
      'pinCode': 'पिन कोड',
      'bio': 'बायो',
      'eventsCount': 'इवेंट्स की संख्या',
      'accountsBinded': 'जुड़े हुए खाते',
      'addAccount': 'खाता जोड़ें',
      'followers': 'फ़ॉलोअर्स',
      'following': 'फ़ॉलोइंग',
      'reactions': 'प्रतिक्रियाएं',
      'impressions': 'इम्प्रेशन',
      'videos': 'वीडियो',
      'posts': 'पोस्ट',
      'views': 'व्यूज',
      'online': 'ऑनलाइन',
      'offline': 'ऑफ़लाइन',
      'professional': 'प्रोफ़ेशनल',
      'skilled': 'कुशल',
      'individual': 'व्यक्तिगत',
      'group': 'समूह',
      'selectProfileType': 'प्रोफ़ाइल प्रकार चुनें',
      'selectTalentCategory': 'प्रतिभा श्रेणी चुनें',
      'selectTalentSubcategory': 'प्रतिभा उपश्रेणी चुनें',
      'selectTalentType': 'प्रतिभा प्रकार चुनें',
      'uploadProfilePhoto': 'प्रोफ़ाइल फ़ोटो अपलोड करें',
      'uploadVideos': 'वीडियो अपलोड करें',
      'uploadCertificates': 'प्रमाणपत्र अपलोड करें',
      'professionalBio': 'प्रोफ़ेशनल बायो',
      'socialLinks': 'सोशल लिंक्स',
      'eventsPerformed': 'किए गए इवेंट्स',
      'messages': 'संदेश',
      'searchHintCoach': 'क्या आप कोच ढूंढ रहे हैं',
      'searchHintGeneric': 'क्या आप ढूंढ रहे हैं',
      'nowTalking': 'अभी बात कर रहे हैं',
      'chatWith': 'चैट करें ',
      'coach': 'कोच',
      'switchToFullScreen': 'फ़ुल स्क्रीन चैट पर जाएं',
      'switchToHalfScreen': 'हाफ़ स्क्रीन चैट पर जाएं',
      'typeMessage': 'अपना संदेश लिखें....',
      'endChat': 'चैट समाप्त करें',
      'noSkillsFound': 'कोई कौशल नहीं मिला',
      'noCreatorsFound': 'कोई क्रिएटर नहीं मिला',
      'resultsFor': 'परिणाम: ',
      'filters': 'फ़िल्टर',
      'chatHistory': 'चैट इतिहास',
      'chatLastedFor': 'चैट की अवधि',
      'mins': 'मिनट',
      'hour': 'घंटा',
      'callsSection': 'कॉल अनुभाग',
      'today': 'आज',
      'yesterday': 'कल',
      'missedCall': 'मिस्ड कॉल',
      'outgoingCall': 'आउटगोइंग कॉल',
      'incomingCall': 'इनकमिंग कॉल',
      'callEnded': 'कॉल समाप्त',
      'call': 'कॉल',
      'chat': 'चैट',
      'home': 'होम',
      'aboutUs': 'हमारे बारे में',
      'termsAndConditions': 'नियम और शर्तें',
      'settings': 'सेटिंग्स',
      'faqs': 'अक्सर पूछे जाने वाले प्रश्न',
      'favourites': 'पसंदीदा',
      'languageSelection': 'भाषा चयन',
      'privacyPolicy': 'गोपनीयता नीति',
      'helpAndSupport': 'सहायता और समर्थन',
      'deleteAccount': 'खाता हटाएं',
      'areYouSure': 'क्या आप सुनिश्चित हैं?',
      'deleteAccountWarning':
          'आपकी सभी प्रोफ़ाइल डेटा, वीडियो और दस्तावेज़ स्थायी रूप से हटा दिए जाएंगे। यह क्रिया पूर्ववत नहीं की जा सकती।',
      'cancel': 'रद्द करें',
      'logout': 'लॉगआउट',
      'aboutSkillioo': 'स्किलियो के बारे में',
      'aboutSkilliooBody':
          'स्किलियो भारत का पहला टैलेंट हब है — नृत्य, संगीत, अभिनय, एनिमेशन और अन्य क्षेत्रों में कुशल व्यक्तियों को खोजने, प्रदर्शित करने और भर्ती करने के लिए बनाया गया प्लेटफ़ॉर्म।',
      'ourPurpose': 'हमारा उद्देश्य',
      'ourPurposeBody':
          'हम मानते हैं कि हर प्रतिभाशाली व्यक्ति एक मंच का हकदार है। स्किलियो कुशल क्रिएटर्स को असली प्रतिभा की तलाश करने वाले नियोक्ताओं से जोड़ता है।',
      'howItWorks': 'यह कैसे काम करता है',
      'howItWorksBody':
          'अपनी प्रोफ़ाइल बनाएं, अपना सर्वश्रेष्ठ काम अपलोड करें और खोजे जाएं। नियोक्ता ब्राउज़ कर सकते हैं, शॉर्टलिस्ट कर सकते हैं और सीधे प्रतिभा से जुड़ सकते हैं।',
      'ourVision': 'हमारा विज़न',
      'ourVisionBody':
          'भारत और उससे आगे प्रतिभा खोज के लिए पसंदीदा प्लेटफ़ॉर्म बनना — लाखों क्रिएटर्स को अपने जुनून को पेशे में बदलने के लिए सशक्त बनाना।',
      'accountAndPrivacy': 'खाता और गोपनीयता',
      'accountAndPrivacyBody':
          'पंजीकरण के दौरान उपयोगकर्ताओं को सटीक विवरण प्रदान करना होगा। व्यक्तिगत डेटा भर्ती तक छिपा रहता है।',
      'contentUpload': 'सामग्री अपलोड',
      'contentUploadBody':
          'केवल अपनी कौशल से संबंधित मूल वीडियो, छवियां या प्रमाणपत्र अपलोड करें। कॉपीराइट, आपत्तिजनक या भ्रामक सामग्री की अनुमति नहीं है।',
      'paymentsAndSubscriptions': 'भुगतान और सदस्यता',
      'paymentsAndSubscriptionsBody':
          'सशुल्क सुविधाएं सक्रिय होने के बाद अ-वापसी योग्य हैं।',
      'behaviorAndSafety': 'व्यवहार और सुरक्षा',
      'behaviorAndSafetyBody':
          'उत्पीड़न, घृणा भाषण या प्लेटफ़ॉर्म के दुरुपयोग से खाता निलंबन होगा।',
      'rightsAndOwnership': 'अधिकार और स्वामित्व',
      'rightsAndOwnershipBody':
          'आप अपनी अपलोड की गई सामग्री के मालिक हैं लेकिन स्किलियो को ऐप में सार्वजनिक रूप से प्रदर्शित करने की अनुमति देते हैं।',
      'modifications': 'संशोधन',
      'modificationsBody':
          'स्किलियो किसी भी समय इन शर्तों को अपडेट कर सकता है। ऐप का निरंतर उपयोग नवीनतम संस्करण की स्वीकृति मानी जाएगी।',
      'accountHelp': 'खाता सहायता',
      'accountHelpBody':
          'लॉगिन या नंबर सत्यापित करने में समस्या? पिन भूल गए या OTP दोबारा भेजें टैप करें।',
      'profileAndUploads': 'प्रोफ़ाइल और अपलोड',
      'profileAndUploadsBody':
          'वीडियो या दस्तावेज़ अपलोड करने में समस्या? अपना इंटरनेट कनेक्शन या फ़ाइल आकार (अधिकतम 200MB) जांचें।',
      'hiringOrPickTalent': 'भर्ती या "टैलेंट चुनें"',
      'hiringOrPickTalentBody':
          'प्रतिक्रिया नहीं मिली? नोटिफ़िकेशन अनुमति दें और नियमित रूप से अनुरोध जांचें।',
      'payments': 'भुगतान',
      'paymentsBody':
          'भुगतान दिखाई नहीं दे रहा? कुछ मिनट प्रतीक्षा करें या अपनी लेनदेन आईडी के साथ सहायता से संपर्क करें।',
      'contactSupport': 'सहायता से संपर्क करें',
      'contactSupportBody':
          'support@skillioo.com\nउपलब्ध: सुबह 9 - शाम 6 (सोम - शनि)',
      'privacyPolicyBody':
          'स्किलियो आपकी गोपनीयता का सम्मान करता है। हम केवल आपके खाते को सत्यापित करने और अनुभव बेहतर बनाने के लिए बुनियादी विवरण एकत्र करते हैं।\n\nसभी व्यक्तिगत डेटा एन्क्रिप्टेड है और भर्ती तक छिपा रहता है। आप अपलोड की गई सामग्री के मालिक हैं।\n\nहम आपकी सहमति के बिना आपका डेटा तीसरे पक्ष को साझा या बेचते नहीं हैं।\n\nस्किलियो समय-समय पर इस नीति को अपडेट कर सकता है।',
      'appLanguage': 'ऐप भाषा',
      'biometrics': 'बायोमेट्रिक्स',
      'notificationPreferences': 'नोटिफ़िकेशन प्राथमिकताएं',
      'notifications': 'नोटिफ़िकेशन',
      'likesCommentsFollow': 'लाइक, कमेंट और फ़ॉलो',
      'messagesCalls': 'संदेश/कॉल',
      'securityAlerts': 'सुरक्षा अलर्ट',
      'selectYourLanguage': 'अपनी भाषा चुनें',
      'languageSubtitle': 'बताएं कि आप ऐप से कैसे बात करना चाहते हैं।',
      'faqQ1': 'प्र.1 स्किलियो क्या है?',
      'faqQ2': 'प्र.2 प्रोफ़ाइल कैसे बनाएं?',
      'faqQ3': 'प्र.3 क्या स्किलियो मुफ़्त है?',
      'faqQ4': 'प्र.4 नियोक्ता मुझे कैसे ढूंढते हैं?',
      'faqA3':
          'हाँ! प्रोफ़ाइल बनाना और अपनी प्रतिभा दिखाना पूरी तरह मुफ़्त है। कुछ प्रीमियम सुविधाओं के लिए सदस्यता की आवश्यकता हो सकती है।',
      'faqA4':
          'नियोक्ता श्रेणी के अनुसार प्रतिभा ब्राउज़ कर सकते हैं, आपके वीडियो देख सकते हैं, आपके प्रमाणपत्र देख सकते हैं और ऐप के माध्यम से सीधे आपसे जुड़ सकते हैं।',
      'fingerprint1': 'फ़िंगरप्रिंट 1',
      'fingerprint2': 'फ़िंगरप्रिंट 2',
      'addNewFingerprint': 'नया फ़िंगरप्रिंट जोड़ें',
      'verifyIdentity': 'पहचान सत्यापित करें',
      'verifyIdentityBody':
          'नया फ़िंगरप्रिंट जोड़ने से पहले सेंसर पर अपनी उंगली रखें।',
      'verificationFailed': 'सत्यापन विफल',
      'verificationFailedBody':
          'आपकी पहचान सत्यापित नहीं हो सकी। कृपया पुनः प्रयास करें।',
      'placeYourFinger': 'अपनी उंगली रखें',
      'placeYourFingerBody':
          'नया फ़िंगरप्रिंट रजिस्टर करने के लिए सेंसर पर अपनी उंगली रखें।',
      'fingerprintAdded': 'फ़िंगरप्रिंट जोड़ा गया',
      'fingerprintAddedBody':
          'आपका नया फ़िंगरप्रिंट सफलतापूर्वक रजिस्टर हो गया है।',
      'tryAgain': 'पुनः प्रयास करें',
      'done': 'पूर्ण',
      'deleteFingerprint': 'फ़िंगरप्रिंट हटाएं',
      'deleteFingerprintBody':
          'क्या आप इस फ़िंगरप्रिंट को हटाना चाहते हैं? इसे फिर से उपयोग करने के लिए आपको इसे दोबारा रजिस्टर करना होगा।',
      'addedToFavorites': 'पसंदीदा में जोड़ा गया',
      'editHiringCharges': 'भर्ती शुल्क संपादित करें',
      'hourlyPricing': 'प्रति घंटा मूल्य',
      'dailyPricing': 'दैनिक मूल्य',
      'weeklyPricing': 'साप्ताहिक मूल्य',
      'monthlyPricing': 'मासिक मूल्य',
      'saveChanges': 'बदलाव सेव करें',
      'saving': 'सेव हो रहा है...',
      'changesSaved': 'बदलाव सेव हो गए',
      'somethingWentWrong': 'कुछ गलत हो गया, पुनः प्रयास करें।',
      'comments': 'टिप्पणियाँ',
      'shareYourThoughts': 'अपने विचार साझा करें....',
      'reply': 'जवाब दें',
      'likes': 'लाइक्स',
      'noCommentsYet': 'अभी कोई टिप्पणी नहीं',
      'likedYourPost': 'ने आपकी पोस्ट पसंद की।',
      'commentedOnYourPost': 'ने आपकी पोस्ट पर टिप्पणी की',
      'reels': 'रील्स',
      'explore': 'एक्सप्लोर',
      'forYou': 'आपके लिए',
      'trending': 'ट्रेंडिंग',
      'follow': 'फ़ॉलो करें',
      'unfollow': 'फ़ॉलो कर रहे हैं',
      'share': 'शेयर',
      'noPostsYet': 'अभी कोई पोस्ट नहीं',
      'loadMore': 'और लोड करें',
      'retry': 'पुनः प्रयास',
      'noProfilesAvailable': 'कोई प्रोफ़ाइल उपलब्ध नहीं',
      'failedToLoadProfiles': 'प्रोफ़ाइल लोड करने में विफल',
      'search': 'खोजें',
      'viewCharges': 'शुल्क देखें',
      'subscription': 'सदस्यता',
      'subscriptionRequired': 'सदस्यता आवश्यक',
      'subscriptionRequiredBody':
          'इस सुविधा का उपयोग करने के लिए आपको एक सक्रिय सदस्यता चाहिए।',
      'viewPlans': 'प्लान देखें',
      'upgrade': 'अपग्रेड',
      'completePayment': 'भुगतान पूरा करें',
      'subscribedSuccessfully': 'सफलतापूर्वक सब्सक्राइब किया',
      'perMonth': '/महीना',
      'subscribe': 'सब्सक्राइब करें',
      'choosePlan': 'प्लान चुनें',
      'currentPlan': 'वर्तमान प्लान',
      'createPost': 'पोस्ट बनाएं',
      'selectMedia': 'मीडिया चुनें',
      'caption': 'कैप्शन',
      'post': 'पोस्ट',
      'posting': 'पोस्ट हो रहा है...',
      'social': 'सोशल',
      'general': 'सामान्य',
      'privacy': 'गोपनीयता',
      'publicOption': 'सार्वजनिक',
      'friendsOption': 'मित्र',
      'privateOption': 'निजी',
      'selectLocation': 'स्थान चुनें',
      'searchLocation': 'स्थान खोजें',
      'trendingTimer': '1:25',
      'noResultsFound': 'कोई परिणाम नहीं मिला',
      'loading': 'लोड हो रहा है...',
      'error': 'त्रुटि',
      'success': 'सफल',
      'ok': 'ठीक है',
      'yes': 'हाँ',
      'no': 'नहीं',
      'close': 'बंद करें',
      'delete': 'हटाएं',
      'edit': 'संपादित करें',
      'save': 'सेव करें',
      'update': 'अपडेट करें',
      'add': 'जोड़ें',
      'remove': 'हटाएं',
    },

    // ════════════════════════════════════════
    // MARATHI
    // ════════════════════════════════════════
    AppLocale.mr: {
      'appName': 'स्किलिओ',
      'tagline': 'भारताचे पहिले टॅलेंट हब',
      'welcome': 'स्वागत आहे!',
      'welcomeDescription':
          'आम्ही समविचारी व्यक्ती आणि उत्कृष्ट प्रतिभांसाठी कनेक्शनचा एक समुदाय तयार करतो। तुमचे कौशल्य दाखवा, नेटवर्क तयार करा आणि स्वप्ने साकार करा.',
      'letsGo': 'चला सुरू करूया',
      'welcomeToSkillioo': 'स्किलिओमध्ये आपले स्वागत आहे',
      'selectAppLanguage': 'अ‍ॅप भाषा निवडा',
      'createProfile': 'प्रोफाइल तयार करा',
      'proceedToDashboard': 'डॅशबोर्डवर जा',
      'skip': 'वगळा',
      'next': 'पुढे',
      'back': 'मागे',
      'continueText': 'पुढे चला',
      'enterPhoneNumber': 'फोन नंबर टाका',
      'phoneNumberHint': 'फोन नंबर',
      'sendOtp': 'OTP पाठवा',
      'enterOtp': 'OTP टाका',
      'enterOtpBody': 'आम्ही तुमच्या मोबाइल नंबरवर 4 अंकी OTP पाठवला आहे.',
      'invalidOtp': 'चुकीचा OTP',
      'invalidOtpBody':
          'तुमच्या मोबाइल नंबरवर OTP पुन्हा पाठवा आणि पुन्हा सत्यापित करा.',
      'resendOtp': 'OTP पुन्हा पाठवा',
      'verify': 'सत्यापित करा',
      'verifying': 'सत्यापित होत आहे...',
      'verified': 'सत्यापित',
      'enterPin': 'पिन टाका',
      'enterPinBody': 'कृपया तुमचा 4 अंकी पिन टाका.',
      'enterNewPin': 'नवीन पिन टाका',
      'enterNewPinBody': 'कृपया 4 अंकी पिन टाका.',
      'enterNewPinAgain': 'नवीन पिन पुन्हा टाका',
      'enterNewPinAgainBody': 'कृपया नवीन पिन पुन्हा टाका.',
      'pinMismatch': 'पिन जुळत नाही',
      'pinMismatchBody':
          'तुम्ही टाकलेले पिन जुळत नाहीत. कृपया पुन्हा प्रयत्न करा.',
      'pinSetup': 'पिन सेटअप',
      'confirm': 'पुष्टी करा',
      'profileSection': 'प्रोफाइल विभाग',
      'editProfile': 'प्रोफाइल संपादित करा',
      'changeProfilePicture': 'प्रोफाइल फोटो बदला',
      'firstName': 'पहिले नाव',
      'lastName': 'आडनाव',
      'groupName': 'गटाचे नाव',
      'email': 'ईमेल',
      'phoneNumber': 'फोन नंबर',
      'address': 'पत्ता',
      'streetAddress': 'रस्त्याचा पत्ता',
      'city': 'शहर',
      'state': 'राज्य',
      'country': 'देश',
      'pinCode': 'पिन कोड',
      'bio': 'बायो',
      'eventsCount': 'कार्यक्रम संख्या',
      'accountsBinded': 'जोडलेली खाती',
      'addAccount': 'खाते जोडा',
      'followers': 'फॉलोअर्स',
      'following': 'फॉलोइंग',
      'reactions': 'प्रतिक्रिया',
      'impressions': 'इम्प्रेशन',
      'videos': 'व्हिडिओ',
      'posts': 'पोस्ट',
      'views': 'व्ह्यूज',
      'online': 'ऑनलाइन',
      'offline': 'ऑफलाइन',
      'professional': 'व्यावसायिक',
      'skilled': 'कुशल',
      'individual': 'वैयक्तिक',
      'group': 'गट',
      'messages': 'संदेश',
      'chatHistory': 'चॅट इतिहास',
      'call': 'कॉल',
      'chat': 'चॅट',
      'home': 'होम',
      'aboutUs': 'आमच्याबद्दल',
      'termsAndConditions': 'अटी आणि शर्ती',
      'settings': 'सेटिंग्ज',
      'faqs': 'वारंवार विचारले जाणारे प्रश्न',
      'favourites': 'आवडीचे',
      'languageSelection': 'भाषा निवड',
      'privacyPolicy': 'गोपनीयता धोरण',
      'helpAndSupport': 'मदत आणि समर्थन',
      'deleteAccount': 'खाते हटवा',
      'areYouSure': 'तुम्हाला खात्री आहे?',
      'cancel': 'रद्द करा',
      'logout': 'लॉगआउट',
      'follow': 'फॉलो करा',
      'unfollow': 'फॉलो करत आहे',
      'share': 'शेअर करा',
      'search': 'शोधा',
      'reels': 'रील्स',
      'explore': 'एक्सप्लोर',
      'selectYourLanguage': 'तुमची भाषा निवडा',
      'languageSubtitle': 'अ‍ॅप तुमच्याशी कसे बोलावे ते सांगा.',
      'notifications': 'सूचना',
      'subscription': 'सदस्यता',
      'viewPlans': 'प्लॅन बघा',
      'upgrade': 'अपग्रेड करा',
      'loading': 'लोड होत आहे...',
      'retry': 'पुन्हा प्रयत्न करा',
      'loadMore': 'अजून लोड करा',
      'noProfilesAvailable': 'प्रोफाइल उपलब्ध नाहीत',
      'viewCharges': 'शुल्क बघा',
      'social': 'सोशल',
      'general': 'सामान्य',
      'privacy': 'गोपनीयता',
      'comments': 'टिप्पण्या',
      'likes': 'लाइक्स',
    },

    // ════════════════════════════════════════
    // KANNADA
    // ════════════════════════════════════════
    AppLocale.kn: {
      'appName': 'ಸ್ಕಿಲಿಯೋ',
      'tagline': 'ಭಾರತದ ಮೊದಲ ಪ್ರತಿಭಾ ಕೇಂದ್ರ',
      'welcome': 'ಸ್ವಾಗತ!',
      'welcomeDescription':
          'ಅಗ್ರ ಪ್ರತಿಭೆಗಾಗಿ ಸಮಾನ ಮನಸ್ಕ ವ್ಯಕ್ತಿಗಳ ಸಮುದಾಯವನ್ನು ನಾವು ಒಟ್ಟುಗೂಡಿಸುತ್ತೇವೆ. ನಿಮ್ಮ ಕೌಶಲ್ಯ ಪ್ರದರ್ಶಿಸಿ, ನೆಟ್‌ವರ್ಕ್ ನಿರ್ಮಿಸಿ, ಕನಸುಗಳನ್ನು ಸಾಕಾರಗೊಳಿಸಿ.',
      'letsGo': 'ಶುರು ಮಾಡೋಣ',
      'welcomeToSkillioo': 'ಸ್ಕಿಲಿಯೋಗೆ ಸ್ವಾಗತ',
      'selectAppLanguage': 'ಅಪ್ಲಿಕೇಶನ್ ಭಾಷೆ ಆಯ್ಕೆ',
      'createProfile': 'ಪ್ರೊಫೈಲ್ ರಚಿಸಿ',
      'proceedToDashboard': 'ಡ್ಯಾಶ್‌ಬೋರ್ಡ್‌ಗೆ ಹೋಗಿ',
      'skip': 'ಬಿಟ್ಟುಬಿಡಿ',
      'next': 'ಮುಂದೆ',
      'back': 'ಹಿಂದೆ',
      'continueText': 'ಮುಂದುವರಿಸಿ',
      'enterPhoneNumber': 'ಫೋನ್ ಸಂಖ್ಯೆ ನಮೂದಿಸಿ',
      'phoneNumberHint': 'ಫೋನ್ ಸಂಖ್ಯೆ',
      'sendOtp': 'OTP ಕಳುಹಿಸಿ',
      'enterOtp': 'OTP ನಮೂದಿಸಿ',
      'verify': 'ಪರಿಶೀಲಿಸಿ',
      'verifying': 'ಪರಿಶೀಲಿಸಲಾಗುತ್ತಿದೆ...',
      'verified': 'ಪರಿಶೀಲಿಸಲಾಗಿದೆ',
      'confirm': 'ಖಚಿತಪಡಿಸಿ',
      'profileSection': 'ಪ್ರೊಫೈಲ್ ವಿಭಾಗ',
      'editProfile': 'ಪ್ರೊಫೈಲ್ ಸಂಪಾದಿಸಿ',
      'firstName': 'ಮೊದಲ ಹೆಸರು',
      'lastName': 'ಕೊನೆಯ ಹೆಸರು',
      'followers': 'ಅನುಯಾಯಿಗಳು',
      'following': 'ಅನುಸರಿಸುತ್ತಿದ್ದಾರೆ',
      'messages': 'ಸಂದೇಶಗಳು',
      'chatHistory': 'ಚಾಟ್ ಇತಿಹಾಸ',
      'call': 'ಕರೆ',
      'chat': 'ಚಾಟ್',
      'home': 'ಮನೆ',
      'aboutUs': 'ನಮ್ಮ ಬಗ್ಗೆ',
      'termsAndConditions': 'ನಿಯಮ ಮತ್ತು ಷರತ್ತುಗಳು',
      'settings': 'ಸೆಟ್ಟಿಂಗ್‌ಗಳು',
      'faqs': 'ಪ್ರಶ್ನೋತ್ತರ',
      'favourites': 'ಮೆಚ್ಚಿನವು',
      'languageSelection': 'ಭಾಷೆ ಆಯ್ಕೆ',
      'privacyPolicy': 'ಗೌಪ್ಯತಾ ನೀತಿ',
      'helpAndSupport': 'ಸಹಾಯ ಮತ್ತು ಬೆಂಬಲ',
      'deleteAccount': 'ಖಾತೆ ಅಳಿಸಿ',
      'areYouSure': 'ನಿಮಗೆ ಖಚಿತವಾಗಿದೆಯೇ?',
      'cancel': 'ರದ್ದುಮಾಡಿ',
      'logout': 'ಲಾಗ್‌ಔಟ್',
      'follow': 'ಫಾಲೋ ಮಾಡಿ',
      'unfollow': 'ಫಾಲೋ ಮಾಡುತ್ತಿದ್ದಾರೆ',
      'share': 'ಹಂಚಿಕೊಳ್ಳಿ',
      'search': 'ಹುಡುಕಿ',
      'reels': 'ರೀಲ್ಸ್',
      'explore': 'ಎಕ್ಸ್‌ಪ್ಲೋರ್',
      'selectYourLanguage': 'ನಿಮ್ಮ ಭಾಷೆ ಆಯ್ಕೆ ಮಾಡಿ',
      'languageSubtitle': 'ಅಪ್ಲಿಕೇಶನ್ ನಿಮ್ಮೊಂದಿಗೆ ಹೇಗೆ ಮಾತನಾಡಬೇಕೆಂದು ಹೇಳಿ.',
      'notifications': 'ಅಧಿಸೂಚನೆಗಳು',
      'subscription': 'ಚಂದಾ',
      'viewPlans': 'ಯೋಜನೆ ನೋಡಿ',
      'upgrade': 'ಅಪ್‌ಗ್ರೇಡ್',
      'loading': 'ಲೋಡ್ ಆಗುತ್ತಿದೆ...',
      'retry': 'ಮರುಪ್ರಯತ್ನ',
      'loadMore': 'ಇನ್ನಷ್ಟು ಲೋಡ್ ಮಾಡಿ',
      'viewCharges': 'ಶುಲ್ಕ ನೋಡಿ',
      'social': 'ಸೋಶಿಯಲ್',
      'general': 'ಸಾಮಾನ್ಯ',
      'privacy': 'ಗೌಪ್ಯತೆ',
      'comments': 'ಕಾಮೆಂಟ್‌ಗಳು',
      'likes': 'ಲೈಕ್‌ಗಳು',
    },

    // ════════════════════════════════════════
    // TELUGU
    // ════════════════════════════════════════
    AppLocale.te: {
      'appName': 'స్కిలియో',
      'tagline': 'భారతదేశపు మొదటి టాలెంట్ హబ్',
      'welcome': 'స్వాగతం!',
      'welcomeDescription':
          'అగ్ర ప్రతిభ కోసం సమాన ఆలోచనలు గల వ్యక్తులు మరియు కనెక్షన్ల సమాజాన్ని మేము ఏర్పాటు చేస్తాము. మీ నైపుణ్యాలను ప్రదర్శించండి, నెట్‌వర్క్ నిర్మించండి, కలలు సాకారం చేసుకోండి.',
      'letsGo': 'మొదలుపెడదాం',
      'welcomeToSkillioo': 'స్కిలియోకు స్వాగతం',
      'selectAppLanguage': 'యాప్ భాష ఎంచుకోండి',
      'createProfile': 'ప్రొఫైల్ సృష్టించండి',
      'proceedToDashboard': 'డాష్‌బోర్డ్‌కు వెళ్ళండి',
      'skip': 'దాటవేయండి',
      'next': 'తదుపరి',
      'back': 'వెనుకకు',
      'continueText': 'కొనసాగించండి',
      'enterPhoneNumber': 'ఫోన్ నంబర్ నమోదు చేయండి',
      'phoneNumberHint': 'ఫోన్ నంబర్',
      'sendOtp': 'OTP పంపండి',
      'enterOtp': 'OTP నమోదు చేయండి',
      'verify': 'ధృవీకరించండి',
      'verifying': 'ధృవీకరిస్తోంది...',
      'verified': 'ధృవీకరించబడింది',
      'confirm': 'నిర్ధారించండి',
      'profileSection': 'ప్రొఫైల్ విభాగం',
      'editProfile': 'ప్రొఫైల్ మార్చండి',
      'firstName': 'మొదటి పేరు',
      'lastName': 'చివరి పేరు',
      'followers': 'ఫాలోవర్లు',
      'following': 'ఫాలో అవుతోంది',
      'messages': 'సందేశాలు',
      'chatHistory': 'చాట్ చరిత్ర',
      'call': 'కాల్',
      'chat': 'చాట్',
      'home': 'హోమ్',
      'aboutUs': 'మా గురించి',
      'termsAndConditions': 'నిబంధనలు & షరతులు',
      'settings': 'సెట్టింగ్‌లు',
      'faqs': 'తరచుగా అడిగే ప్రశ్నలు',
      'favourites': 'ఇష్టమైనవి',
      'languageSelection': 'భాష ఎంపిక',
      'privacyPolicy': 'గోప్యతా విధానం',
      'helpAndSupport': 'సహాయం & మద్దతు',
      'deleteAccount': 'ఖాతా తొలగించండి',
      'areYouSure': 'మీకు ఖచ్చితంగా తెలుసా?',
      'cancel': 'రద్దు చేయండి',
      'logout': 'లాగ్‌ఔట్',
      'follow': 'ఫాలో చేయండి',
      'unfollow': 'ఫాలో అవుతోంది',
      'share': 'షేర్ చేయండి',
      'search': 'వెతకండి',
      'reels': 'రీల్స్',
      'explore': 'ఎక్స్‌ప్లోర్',
      'selectYourLanguage': 'మీ భాష ఎంచుకోండి',
      'languageSubtitle': 'యాప్ మీతో ఎలా మాట్లాడాలో చెప్పండి.',
      'notifications': 'నోటిఫికేషన్‌లు',
      'subscription': 'సబ్‌స్క్రిప్షన్',
      'viewPlans': 'ప్లాన్‌లు చూడండి',
      'upgrade': 'అప్‌గ్రేడ్',
      'loading': 'లోడ్ అవుతోంది...',
      'retry': 'మళ్ళీ ప్రయత్నించండి',
      'loadMore': 'మరిన్ని లోడ్ చేయండి',
      'viewCharges': 'ఛార్జీలు చూడండి',
      'social': 'సోషల్',
      'general': 'సాధారణ',
      'privacy': 'గోప్యత',
      'comments': 'వ్యాఖ్యలు',
      'likes': 'లైక్‌లు',
    },

    // ════════════════════════════════════════
    // MALAYALAM
    // ════════════════════════════════════════
    AppLocale.ml: {
      'appName': 'സ്കിലിയോ',
      'tagline': 'ഇന്ത്യയിലെ ആദ്യ ടാലന്റ് ഹബ്',
      'welcome': 'സ്വാഗതം!',
      'welcomeDescription':
          'മികച്ച പ്രതിഭകൾക്കായി സമാന ചിന്താഗതിയുള്ള വ്യക്തികളുടെ ഒരു സമൂഹം ഞങ്ങൾ ഒരുക്കുന്നു. നിങ്ങളുടെ കഴിവുകൾ പ്രദർശിപ്പിക്കുക, നെറ്റ്‌വർക്ക് നിർമ്മിക്കുക, സ്വപ്നങ്ങൾ സാക്ഷാത്കരിക്കുക.',
      'letsGo': 'നമുക്ക് തുടങ്ങാം',
      'welcomeToSkillioo': 'സ്കിലിയോയിലേക്ക് സ്വാഗതം',
      'selectAppLanguage': 'ആപ്പ് ഭാഷ തിരഞ്ഞെടുക്കുക',
      'createProfile': 'പ്രൊഫൈൽ സൃഷ്ടിക്കുക',
      'proceedToDashboard': 'ഡാഷ്‌ബോർഡിലേക്ക് പോകുക',
      'skip': 'ഒഴിവാക്കുക',
      'next': 'അടുത്തത്',
      'back': 'പിന്നിലേക്ക്',
      'continueText': 'തുടരുക',
      'enterPhoneNumber': 'ഫോൺ നമ്പർ നൽകുക',
      'phoneNumberHint': 'ഫോൺ നമ്പർ',
      'sendOtp': 'OTP അയയ്ക്കുക',
      'enterOtp': 'OTP നൽകുക',
      'verify': 'പരിശോധിക്കുക',
      'verifying': 'പരിശോധിക്കുന്നു...',
      'verified': 'പരിശോധിച്ചു',
      'confirm': 'സ്ഥിരീകരിക്കുക',
      'profileSection': 'പ്രൊഫൈൽ വിഭാഗം',
      'editProfile': 'പ്രൊഫൈൽ എഡിറ്റ് ചെയ്യുക',
      'firstName': 'ആദ്യ പേര്',
      'lastName': 'അവസാന പേര്',
      'followers': 'ഫോളോവേഴ്‌സ്',
      'following': 'ഫോളോ ചെയ്യുന്നു',
      'messages': 'സന്ദേശങ്ങൾ',
      'chatHistory': 'ചാറ്റ് ചരിത്രം',
      'call': 'കോൾ',
      'chat': 'ചാറ്റ്',
      'home': 'ഹോം',
      'aboutUs': 'ഞങ്ങളെക്കുറിച്ച്',
      'termsAndConditions': 'നിബന്ധനകളും വ്യവസ്ഥകളും',
      'settings': 'ക്രമീകരണങ്ങൾ',
      'faqs': 'പതിവ് ചോദ്യങ്ങൾ',
      'favourites': 'പ്രിയപ്പെട്ടവ',
      'languageSelection': 'ഭാഷ തിരഞ്ഞെടുക്കൽ',
      'privacyPolicy': 'സ്വകാര്യതാ നയം',
      'helpAndSupport': 'സഹായവും പിന്തുണയും',
      'deleteAccount': 'അക്കൗണ്ട് ഇല്ലാതാക്കുക',
      'areYouSure': 'നിങ്ങൾക്ക് ഉറപ്പാണോ?',
      'cancel': 'റദ്ദാക്കുക',
      'logout': 'ലോഗൗട്ട്',
      'follow': 'ഫോളോ ചെയ്യുക',
      'unfollow': 'ഫോളോ ചെയ്യുന്നു',
      'share': 'പങ്കിടുക',
      'search': 'തിരയുക',
      'reels': 'റീൽസ്',
      'explore': 'എക്സ്പ്ലോർ',
      'selectYourLanguage': 'നിങ്ങളുടെ ഭാഷ തിരഞ്ഞെടുക്കുക',
      'languageSubtitle': 'ആപ്പ് നിങ്ങളോട് എങ്ങനെ സംസാരിക്കണമെന്ന് പറയുക.',
      'notifications': 'അറിയിപ്പുകൾ',
      'subscription': 'സബ്‌സ്‌ക്രിപ്ഷൻ',
      'viewPlans': 'പ്ലാനുകൾ കാണുക',
      'upgrade': 'അപ്‌ഗ്രേഡ്',
      'loading': 'ലോഡ് ചെയ്യുന്നു...',
      'retry': 'വീണ്ടും ശ്രമിക്കുക',
      'loadMore': 'കൂടുതൽ ലോഡ് ചെയ്യുക',
      'viewCharges': 'ചാർജ്ജുകൾ കാണുക',
      'social': 'സോഷ്യൽ',
      'general': 'പൊതുവായ',
      'privacy': 'സ്വകാര്യത',
      'comments': 'കമന്റുകൾ',
      'likes': 'ലൈക്കുകൾ',
    },
  };
}

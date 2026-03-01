class ApiConfig {
  // ── Base URLs (3 microservices) ──
  static const String customerBaseUrl = 'https://skillioo.in/customer/api';
  static const String postBaseUrl = 'https://skillioo.in/post/api';
  static const String paymentBaseUrl = 'https://skillioo.in/payment/api';

  /// Legacy alias – existing services already reference this.
  static const String baseUrl = customerBaseUrl;

  // ── Customer MS: Verification ──
  static const String verificationRequest = '/v1/verificationRequest';
  static const String resendOtp = '/v1/verificationRequest/resendOtp';
  static const String verifyOtp = '/v1/verificationRequest/verifyOtp';

  // ── Customer MS: Document ──
  static const String document = '/v1/document';

  // ── Customer MS: Profile / Registration ──
  static const String profile = '/v1/profile';
  static const String profileHiringRate = '/v1/profile/hiringRate';
  static const String profileCounts = '/v1/profile/counts';

  // ── Customer MS: Chat ──
  static const String message = '/v1/message';
  static const String chat = '/v1/chat';
  static const String conversations = '/v1/message/conversations';

  // ── Customer MS: Call ──
  static const String call = '/v1/call';
  static const String callAccept = '/v1/call/accept';
  static const String callReject = '/v1/call/reject';
  static const String callEnd = '/v1/call/end';

  // ── Customer MS: Notification ──
  static const String notification = '/v1/notification';

  // ── Customer MS: Plan Master ──
  static const String planMaster = '/v1/plan-master';
  static const String planMasterPlans = '/v1/plan-master/plans';

  // ── Customer MS: User Subscription ──
  static const String userSubscription = '/v1/user-subscription';
  static const String userSubscriptionStatus = '/v1/user-subscription/status';

  // ── Post MS: Short User ──
  static const String shortUser = '/v1/shortUser';

  // ── Post MS: Media (posts / reels / stories) ──
  static const String media = '/v1/media';

  // ── Post MS: Comment ──
  static const String comment = '/v1/comment';

  // ── Post MS: Reaction ──
  static const String reaction = '/v1/reaction';

  // ── Post MS: Reach ──
  static const String reach = '/v1/reach';

  // ── Payment MS: Payment ──
  static const String payment = '/v1/payment';

  // ── Payment MS: User (payment user) ──
  static const String paymentUser = '/v1/user';
}

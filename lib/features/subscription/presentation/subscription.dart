import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/widgets/gradient_cta_button.dart';
import '../../../../core/widgets/custom_text.dart';
import '../../payment/presentation/payment_history_screen.dart';
import '../application/subscription_providers.dart';
import '../application/states/subscription_state.dart';
import '../domain/subscription_models.dart';

class SubscriptionScreen extends ConsumerStatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  ConsumerState<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends ConsumerState<SubscriptionScreen>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
  int _currentIndex = 0;
  bool _verifyingPayment = false;

  @override
  void initState() {
    super.initState();
    // Fetch plans from API
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(subscriptionNotifierProvider.notifier).fetchPlans();
    });
  }

  void _initTabController(int length) {
    if (_tabController?.length != length) {
      _tabController?.dispose();
      _tabController = TabController(length: length, vsync: this);
      _tabController!.addListener(() {
        if (_tabController!.indexIsChanging ||
            _tabController!.index != _currentIndex) {
          setState(() {
            _currentIndex = _tabController!.index;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  // Shared Gradients
  final Gradient _pinkBlueGradient = const LinearGradient(
    begin: Alignment.topRight,
    end: Alignment.bottomLeft, // Approx 225deg
    colors: [Color(0xFFC00F8B), Color(0xFF05DAF1)],
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF4A148C), // Deep Purple top
                  Color(0xFF14121A), // Dark middle
                  Color(0xFF000000), // Black bottom
                ],
                stops: [0.0, 0.5, 1.0],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // 1. Back Button & Header
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: Container(
                            width: 40.w,
                            height: 40.w,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(alpha: 0.1),
                            ),
                            child: Image.asset(
                              'assets/images/arrow-left.png',
                              color: Colors.white,
                              width: 20.sp,
                              height: 20.sp,
                            ),
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const PaymentHistoryScreen(),
                              ),
                            );
                          },
                          child: CustomText(
                            'View Payment History',
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 2. Titles
                  SizedBox(height: 10.h),
                  CustomText(
                    'Level Up Your Access.',
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8.h),
                  CustomText(
                    'Unlock everything. No limits.',
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                    color: Colors.white70,
                    textAlign: TextAlign.center,
                  ),

                  SizedBox(height: 24.h),

                  // 3. Custom Tab Toggle (Dynamic)
                  _buildDynamicTabBar(),

                  SizedBox(height: 24.h),

                  // 4. Cards Tab View
                  Expanded(child: _buildPlansTabView()),

                  // 5. Indicators (Dynamic)
                  _buildDynamicIndicators(),
                ],
              ),
            ),
          ),

          // Payment verification overlay
          if (_verifyingPayment)
            Container(
              color: Colors.black.withValues(alpha: 0.75),
              child: Center(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 36.h),
                  margin: EdgeInsets.symmetric(horizontal: 40.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A2E),
                    borderRadius: BorderRadius.circular(24.r),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(color: Color(0xFF05DAF1)),
                      SizedBox(height: 24.h),
                      CustomText(
                        'Verifying Payment...',
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 8.h),
                      CustomText(
                        'Please wait while we confirm your payment.',
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w400,
                        color: Colors.white70,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.visible,
                        height: 1.5,
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDynamicTabBar() {
    final subState = ref.watch(subscriptionNotifierProvider);
    final plans = subState.plans;

    if (plans.isEmpty) return const SizedBox.shrink();

    // Sort plans by priority
    final sortedPlans = List<PlanMasterResponse>.from(plans)
      ..sort((a, b) => (b.priority ?? 0).compareTo(a.priority ?? 0));

    _initTabController(sortedPlans.length);

    return Center(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 20.w),
        width: double.infinity,
        height: 44.h,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(22.r),
        ),
        child: TabBar(
          controller: _tabController,
          isScrollable: true,

          tabAlignment: TabAlignment.center,
          labelPadding: EdgeInsets.symmetric(horizontal: 14.w),
          indicator: BoxDecoration(
            borderRadius: BorderRadius.circular(20.r),
            gradient: _pinkBlueGradient,
          ),
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600),
          indicatorSize: TabBarIndicatorSize.tab,
          dividerColor: Colors.transparent,
          tabs: sortedPlans.map((plan) {
            final code = plan.code ?? 'Plan';
            final tabLabel =
                code.substring(0, 1).toUpperCase() +
                code.substring(1).toLowerCase();
            return Tab(
              child: CustomText(
                tabLabel,
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                overflow: TextOverflow.visible,
                softWrap: false,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildDynamicIndicators() {
    final subState = ref.watch(subscriptionNotifierProvider);
    final plans = subState.plans;

    if (plans.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.only(bottom: 20.h, top: 20.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(plans.length, (index) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: _buildIndicator(isActive: _currentIndex == index),
          );
        }),
      ),
    );
  }

  Widget _buildPlansTabView() {
    final subState = ref.watch(subscriptionNotifierProvider);
    final plans = subState.plans;
    final isLoading = subState.plansStatus == SubscriptionStatus.loading;

    if (isLoading && plans.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    if (plans.isEmpty) {
      return const Center(
        child: CustomText(
          'No plans available',
          fontSize: 16,
          color: Colors.white70,
        ),
      );
    }

    // Sort plans by priority (higher priority = more premium)
    final sortedPlans = List<PlanMasterResponse>.from(plans)
      ..sort((a, b) => (b.priority ?? 0).compareTo(a.priority ?? 0));

    _initTabController(sortedPlans.length);

    // Background images cycle
    final bgImages = ['assets/images/pro-bg.png', 'assets/images/elite-bg.png'];

    // Icons cycle
    final icons = [
      Icons.star_border,
      Icons.workspace_premium,
      Icons.diamond_outlined,
      Icons.auto_awesome,
      Icons.verified,
    ];

    return TabBarView(
      controller: _tabController,
      children: sortedPlans.asMap().entries.map((entry) {
        final index = entry.key;
        final plan = entry.value;

        final price = ((plan.priceInPaise ?? 0) / 100).toStringAsFixed(0);
        final validity = '${plan.validity ?? 1} days valid';
        final description = plan.description ?? 'Unlock premium features';
        final planName =
            '${(plan.code ?? 'Plan').substring(0, 1).toUpperCase()}${(plan.code ?? 'Plan').substring(1).toLowerCase()} Plan';

        return _buildSubscriptionCard(
          planName: planName,
          price: price,
          description: description,
          bgImage: bgImages[index % bgImages.length],
          icon: icons[index % icons.length],
          tags: ['Unlimited Chat & Calls', validity],
          benefits: [
            'Direct access to top talents.',
            'Connect anytime, explore professionals and groups.',
            'View unlimited profiles.',
          ],
          planId: plan.id,
          planCode: plan.code,
        );
      }).toList(),
    );
  }

  Widget _buildIndicator({required bool isActive}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: isActive ? 48.w : 12.w,
      height: isActive ? 24.h : 12.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24.r),
        color: isActive ? null : Colors.white,
        gradient: isActive ? _pinkBlueGradient : null,
      ),
    );
  }

  Widget _buildSubscriptionCard({
    required String planName,
    required String price,
    required String description,
    required String bgImage,
    required IconData icon,
    required List<String> tags,
    required List<String> benefits,
    String? planId,
    String? planCode,
  }) {
    final subscription = ref
        .watch(subscriptionNotifierProvider)
        .activeSubscription;
    final isActivePlan =
        subscription != null &&
        (subscription.status == 'ACTIVE' || subscription.status == 'SUCCESS') &&
        subscription.planCode?.toLowerCase() == planCode?.toLowerCase();

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      // The Gradient Border Wrapper
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24.r),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight, // 331 deg approx
          colors: [Color(0xFFB2B2B2), Color(0xFF000000)],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(1.0), // 1px border width
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(23.r),
            color: Colors.black, // Fallback
            image: DecorationImage(
              image: AssetImage(bgImage),
              fit: BoxFit.cover,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Plan Label with Icon
                Row(
                  children: [
                    Image.asset('assets/images/star.png'),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: CustomText(
                        planName,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                        overflow: TextOverflow.visible,
                        softWrap: true,
                        maxLines: 2,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),

                // Price
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '₹ ',
                        style: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          fontFamily: 'Inter', // Assuming Inter or similar
                        ),
                      ),
                      TextSpan(
                        text: price,
                        style: TextStyle(
                          fontSize: 36.sp,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 8.h),

                // Description
                CustomText(
                  description,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  color: Colors.white,
                ),
                SizedBox(height: 24.h),

                // Tags (Unlimited Chat, Validity)
                Row(
                  children: tags.map((tag) {
                    return Container(
                      margin: EdgeInsets.only(right: 12.w),
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 10.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: CustomText(
                        tag,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    );
                  }).toList(),
                ),
                SizedBox(height: 30.h),

                // Benefits Header
                CustomText(
                  'Benefits -',
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
                SizedBox(height: 16.h),

                // Benefits List
                ...benefits.map(
                  (benefit) => Padding(
                    padding: EdgeInsets.only(bottom: 12.h),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(top: 6.h),
                          child: Container(
                            width: 4.w,
                            height: 4.w,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: CustomText(
                            benefit,
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w400,
                            color: Colors.white.withValues(alpha: 0.9),
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const Spacer(),

                if (!isActivePlan) _buildUpgradeButton(planId),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUpgradeButton(String? planId) {
    final subState = ref.watch(subscriptionNotifierProvider);
    final isLoading = subState.initiateStatus == SubscriptionStatus.loading;

    return GradientCtaButton(
      label: isLoading ? 'Processing...' : 'Upgrade',
      width: double.infinity,
      height: 56,
      enabled: !isLoading,
      onPressed: isLoading
          ? null
          : () async {
              if (planId == null) return;
              await _handleSubscription(planId);
            },
    );
  }

  Future<void> _handleSubscription(String planId) async {
    final notifier = ref.read(subscriptionNotifierProvider.notifier);
    final success = await notifier.initiateSubscription(planId);

    if (!success || !mounted) return;

    final paymentLink = ref.read(subscriptionNotifierProvider).paymentLink;
    final subscriptionId = ref
        .read(subscriptionNotifierProvider)
        .activeSubscription
        ?.id;

    if (paymentLink.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment link not available')),
        );
      }
      return;
    }

    // Open payment URL in external browser
    final uri = Uri.parse(paymentLink);
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);

    if (!launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open payment link')),
      );
      return;
    }

    // Show 5-second loader then verify payment status
    if (subscriptionId != null && subscriptionId.isNotEmpty && mounted) {
      setState(() => _verifyingPayment = true);
      await Future.delayed(const Duration(seconds: 5));
      if (!mounted) return;

      final isActive = await notifier.syncSubscriptionStatus(subscriptionId);
      if (!mounted) return;

      setState(() => _verifyingPayment = false);

      if (isActive) {
        _showSubscriptionSuccessScreen();
      } else {
        _showPaymentPendingDialog();
      }
    }
  }

  void _showPaymentPendingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: EdgeInsets.all(28.w),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A2E),
            borderRadius: BorderRadius.circular(24.r),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72.w,
                height: 72.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.orange.withValues(alpha: 0.15),
                ),
                child: Icon(Icons.hourglass_top_rounded,
                    color: Colors.orange, size: 36.sp),
              ),
              SizedBox(height: 20.h),
              CustomText(
                'Payment Processing',
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
              SizedBox(height: 12.h),
              CustomText(
                'Your payment is being verified. Please come back in a few minutes.',
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
                color: Colors.white70,
                maxLines: 3,
                overflow: TextOverflow.visible,
                height: 1.5,
              ),
              SizedBox(height: 24.h),
              GradientCtaButton(
                label: 'OK',
                width: double.infinity,
                height: 48,
                onPressed: () => Navigator.of(ctx).pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSubscriptionSuccessScreen() {
    final subscription = ref
        .read(subscriptionNotifierProvider)
        .activeSubscription;
    final planName = subscription?.planCode ?? 'Member';
    final endDate = subscription?.planDetails?.validity != null
        ? DateTime.now().add(
            Duration(days: subscription!.planDetails!.validity!),
          )
        : null;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: EdgeInsets.all(32.w),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF4A148C), Color(0xFF14121A), Color(0xFF000000)],
            ),
            borderRadius: BorderRadius.circular(24.r),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Success Icon
              Container(
                width: 100.w,
                height: 100.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF05DAF1).withValues(alpha: 0.3),
                      const Color(0xFFC00F8B).withValues(alpha: 0.3),
                    ],
                  ),
                ),
                child: Icon(
                  Icons.check_circle,
                  size: 60.sp,
                  color: const Color(0xFF05DAF1),
                ),
              ),
              SizedBox(height: 24.h),

              // Title
              CustomText(
                'You\'re Now An $planName!',
                fontSize: 22.sp,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 12.h),

              // Subtitle
              CustomText(
                'Your subscription is active. Enjoy unlimited access.',
                fontSize: 14.sp,
                color: Colors.white70,
                textAlign: TextAlign.center,
              ),

              if (endDate != null) ...[
                SizedBox(height: 24.h),
                CustomText(
                  'Valid Until ${endDate.day} ${_getMonthName(endDate.month)} ${endDate.year}',
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ],

              SizedBox(height: 32.h),

              // Continue Button
              GestureDetector(
                onTap: () {
                  Navigator.of(ctx).pop();
                  Navigator.of(context).pop();
                },
                child: Container(
                  width: double.infinity,
                  height: 56.h,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28.r),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF05DAF1), Color(0xFFC00F8B)],
                    ),
                  ),
                  child: CustomText(
                    'Continue',
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month - 1];
  }
}

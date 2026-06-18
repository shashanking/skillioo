import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/gradient_cta_button.dart';
import '../../../core/services/session_state_provider.dart';
import '../../../core/widgets/common_background.dart';
import '../application/onboarding_data_provider.dart';
import '../application/professional_bio_provider.dart';
import '../application/registration_providers.dart';
import '../application/states/registration_state.dart';
import '../application/talent_category_provider.dart';
import '../application/talent_subcategory_provider.dart';
import '../application/talent_type_provider.dart';
import '../application/professional_events_provider.dart';

class ProfessionalBioScreen extends ConsumerStatefulWidget {
  const ProfessionalBioScreen({super.key});

  @override
  ConsumerState<ProfessionalBioScreen> createState() =>
      _ProfessionalBioScreenState();
}

class _ProfessionalBioScreenState extends ConsumerState<ProfessionalBioScreen> {
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _hourlyController = TextEditingController();
  final TextEditingController _dailyController = TextEditingController();
  final TextEditingController _weeklyController = TextEditingController();
  final TextEditingController _monthlyController = TextEditingController();

  bool _showContinue = false;
  String? _bioError;
  String? _hourlyError;
  String? _dailyError;
  String? _weeklyError;
  String? _monthlyError;

  @override
  void initState() {
    super.initState();
    _bioController.addListener(_onChanged);
    _hourlyController.addListener(_onChanged);
    _dailyController.addListener(_onChanged);
    _weeklyController.addListener(_onChanged);
    _monthlyController.addListener(_onChanged);
  }

  void _onChanged() {
    final bio = _bioController.text.trim();
    final hourly = _hourlyController.text.trim();
    final daily = _dailyController.text.trim();
    final weekly = _weeklyController.text.trim();
    final monthly = _monthlyController.text.trim();

    setState(() {
      _bioError = bio.isNotEmpty && bio.length < 10
          ? 'Bio must be at least 10 characters'
          : null;
      _hourlyError = hourly.isNotEmpty && (double.tryParse(hourly) ?? 0) <= 0
          ? 'Enter a valid amount'
          : null;
      _dailyError = daily.isNotEmpty && (double.tryParse(daily) ?? 0) <= 0
          ? 'Enter a valid amount'
          : null;
      _weeklyError = weekly.isNotEmpty && (double.tryParse(weekly) ?? 0) <= 0
          ? 'Enter a valid amount'
          : null;
      _monthlyError = monthly.isNotEmpty && (double.tryParse(monthly) ?? 0) <= 0
          ? 'Enter a valid amount'
          : null;

      _showContinue =
          bio.length >= 10 &&
          _bioError == null &&
          hourly.isNotEmpty &&
          _hourlyError == null &&
          daily.isNotEmpty &&
          _dailyError == null &&
          weekly.isNotEmpty &&
          _weeklyError == null &&
          monthly.isNotEmpty &&
          _monthlyError == null;
    });
  }

  @override
  void dispose() {
    _bioController.dispose();
    _hourlyController.dispose();
    _dailyController.dispose();
    _weeklyController.dispose();
    _monthlyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: CommonBackground(
        child: SafeArea(
          child: Stack(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(bottom: 110.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 16.h),
                      _buildTopBar(context),
                      SizedBox(height: 24.h),
                      _buildBioSection(),
                      SizedBox(height: 28.h),
                      _buildHiringRatesSection(),
                      SizedBox(height: 24.h),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 24.h,
                child: Visibility(
                  visible: _showContinue,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: SizedBox(
                      width: double.infinity,
                      height: 58.h,
                      child: Builder(
                        // The Builder rebuilds on every status change
                        // (because we ref.watch below). Its inner context
                        // becomes deactivated across rebuilds, so we
                        // capture messenger/router from the State's
                        // outer `context` (stable for the lifetime of
                        // this screen) instead of the Builder's.
                        builder: (_) {
                          final isRegistering =
                              ref.watch(registrationNotifierProvider).status ==
                              RegistrationStatus.loading;
                          return GradientCtaButton(
                            label: isRegistering ? 'Loading' : 'Continue',
                            width: double.infinity,
                            height: 58,
                            enabled: _showContinue && !isRegistering,
                            onPressed: (_showContinue && !isRegistering)
                                ? () async {
                                    // Capture before any await — using
                                    // a deactivated context after the
                                    // Builder rebuilds throws
                                    // "deactivated widget's ancestor
                                    // is unsafe".
                                    final messenger = ScaffoldMessenger.of(
                                      context,
                                    );
                                    final router = GoRouter.of(context);

                                    final bio = _bioController.text.trim();
                                    final hourly = _hourlyController.text
                                        .trim();
                                    final daily = _dailyController.text.trim();
                                    final weekly = _weeklyController.text
                                        .trim();
                                    final monthly = _monthlyController.text
                                        .trim();

                                    ref
                                        .read(professionalBioProvider.notifier)
                                        .state = ProfessionalBioData(
                                      bio: bio,
                                      hourly: hourly,
                                      daily: daily,
                                      weekly: weekly,
                                      monthly: monthly,
                                    );

                                    final talentType = ref.read(
                                      talentTypeProvider,
                                    );
                                    final proficiency =
                                        talentType == TalentType.professional
                                        ? 'PROFESSIONAL'
                                        : 'SKILLED';
                                    final eventsCount =
                                        int.tryParse(
                                          ref.read(
                                                professionalEventsCountProvider,
                                              ) ??
                                              '0',
                                        ) ??
                                        0;

                                    final regState = ref.read(
                                      registrationNotifierProvider,
                                    );

                                    final updatedData = ref
                                        .read(onboardingDataProvider)
                                        .copyWith(
                                          category:
                                              ref.read(
                                                talentCategoryProvider,
                                              ) ??
                                              '',
                                          subCategory:
                                              ref.read(
                                                talentSubcategoryProvider,
                                              ) ??
                                              '',
                                          proficiency: proficiency,
                                          bio: bio,
                                          totalEvents: eventsCount,
                                          hourlyPricing:
                                              double.tryParse(hourly) ?? 0,
                                          dailyPricing:
                                              double.tryParse(daily) ?? 0,
                                          weeklyPricing:
                                              double.tryParse(weekly) ?? 0,
                                          monthlyPricing:
                                              double.tryParse(monthly) ?? 0,
                                          profileDocumentId:
                                              regState.profileDocumentId,
                                          videoDocumentIds:
                                              regState.videoDocumentIds,
                                          imageDocumentIds:
                                              regState.imageDocumentIds,
                                          eventsDoneDocumentIds:
                                              regState.eventsDoneDocumentIds,
                                        );
                                    ref
                                            .read(
                                              onboardingDataProvider.notifier,
                                            )
                                            .state =
                                        updatedData;

                                    final missing = <String>[];
                                    if (updatedData.profileDocumentId.isEmpty) {
                                      missing.add('profile photo');
                                    }
                                    if (proficiency == 'PROFESSIONAL') {
                                      if (updatedData
                                          .imageDocumentIds
                                          .isEmpty) {
                                        missing.add('portfolio image');
                                      }
                                      if (updatedData
                                          .eventsDoneDocumentIds
                                          .isEmpty) {
                                        missing.add(
                                          'events/certificates document',
                                        );
                                      }
                                    }

                                    if (missing.isNotEmpty) {
                                      messenger.showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Please upload: ${missing.join(', ')} before continuing.',
                                          ),
                                          backgroundColor: Colors.red,
                                          duration: const Duration(seconds: 4),
                                        ),
                                      );
                                      return;
                                    }

                                    await ref
                                        .read(
                                          registrationNotifierProvider.notifier,
                                        )
                                        .registerProfile(updatedData);

                                    final finalState = ref.read(
                                      registrationNotifierProvider,
                                    );
                                    if (finalState.status ==
                                        RegistrationStatus.success) {
                                      // Pull the freshly-cached profile
                                      // (now isCreator: true) into the
                                      // reactive sessionState so the
                                      // dashboard renders the creator
                                      // top bar immediately — without
                                      // this the user sees the
                                      // Logout + Create Profile UI
                                      // until the next app reload.
                                      await ref
                                          .read(sessionStateProvider.notifier)
                                          .refresh();
                                      // User was already logged in from
                                      // OTP verify; PIN was set during
                                      // signup. Registration completes
                                      // creator status — drop them
                                      // straight on the dashboard via
                                      // the success splash.
                                      router.go('/registration-success');
                                    } else if (finalState.status ==
                                        RegistrationStatus.error) {
                                      messenger.showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            finalState.errorMessage.isNotEmpty
                                                ? finalState.errorMessage
                                                : 'Registration failed. Please try again.',
                                          ),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  }
                                : null,
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () {
            if (GoRouter.of(context).canPop()) {
              GoRouter.of(context).pop();
            } else {
              final talentType = ref.read(talentTypeProvider);
              final backRoute = talentType == TalentType.skilled
                  ? '/skilled-social-links'
                  : '/social-links';
              GoRouter.of(context).go(backRoute);
            }
          },
          child: Container(
            width: 48.w,
            height: 48.w,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(124.r),
            ),
            child: Center(
              child: Image.asset(
                'assets/images/arrow-left.png',
                color: const Color(0xFFF5F5F5),
                width: 20.sp,
                height: 20.sp,
              ),
            ),
          ),
        ),
        Text(
          'Step: 4 of 4',
          style: TextStyle(
            fontFamily: 'Outfit',
            fontSize: 16.sp,
            fontWeight: FontWeight.w400,
            color: const Color(0xFFF5F5F5),
          ),
        ),
      ],
    );
  }

  Widget _buildBioSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tell Us About You',
          style: TextStyle(
            fontFamily: 'Neue',
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFFF5F5F5),
          ),
        ),
        SizedBox(height: 6.h),
        Text(
          'Write a short bio that shows your vibe, skills, and what makes you unique.',
          style: TextStyle(
            fontFamily: 'Outfit',
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
            color: const Color(0xFFF5F5F5),
          ),
        ),
        SizedBox(height: 14.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 14.h),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(24.r),
          ),
          child: TextField(
            controller: _bioController,
            maxLines: 4,
            style: TextStyle(
              fontFamily: 'Outfit',
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
              color: const Color(0xFFF5F5F5),
            ),
            cursorColor: Colors.white,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText:
                  "Include about your skills and talent. Don't include personal info like mobile number, email address etc.",
              hintStyle: TextStyle(
                fontFamily: 'Outfit',
                fontSize: 13.sp,
                fontWeight: FontWeight.w400,
                color: Colors.white.withValues(alpha: 0.6),
              ),
              isCollapsed: true,
            ),
          ),
        ),
        if (_bioError != null) ...[
          SizedBox(height: 6.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Text(
              _bioError!,
              style: TextStyle(
                fontFamily: 'Outfit',
                fontSize: 12.sp,
                fontWeight: FontWeight.w400,
                color: Colors.redAccent,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildHiringRatesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Set Your Hiring Rates',
          style: TextStyle(
            fontFamily: 'Neue',
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFFF5F5F5),
          ),
        ),
        SizedBox(height: 6.h),
        Text(
          'Add your hiring charges so clients know what to expect.',
          style: TextStyle(
            fontFamily: 'Outfit',
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
            color: const Color(0xFFF5F5F5),
          ),
        ),
        SizedBox(height: 16.h),
        _buildRateField('Hourly Pricing', _hourlyController, _hourlyError),
        SizedBox(height: 12.h),
        _buildRateField('Daily Pricing', _dailyController, _dailyError),
        SizedBox(height: 12.h),
        _buildRateField('Weekly Pricing', _weeklyController, _weeklyError),
        SizedBox(height: 12.h),
        _buildRateField('Monthly Pricing', _monthlyController, _monthlyError),
      ],
    );
  }

  Widget _buildRateField(
    String label,
    TextEditingController controller,
    String? error,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Outfit',
            fontSize: 13.sp,
            fontWeight: FontWeight.w500,
            color: const Color(0xFFF5F5F5),
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          height: 56.h,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(24.r),
          ),
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.next,
            style: TextStyle(
              fontFamily: 'Outfit',
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              color: const Color(0xFFF5F5F5),
            ),
            cursorColor: Colors.white,
            decoration: InputDecoration(
              border: InputBorder.none,
              isCollapsed: true,
              prefixIcon: Padding(
                padding: EdgeInsets.only(right: 8.w),
                child: Text(
                  '₹',
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFFF5F5F5),
                  ),
                ),
              ),
              prefixIconConstraints: BoxConstraints(minWidth: 0, minHeight: 0),
            ),
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(7),
            ],
          ),
        ),
        if (error != null) ...[
          SizedBox(height: 4.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Text(
              error,
              style: TextStyle(
                fontFamily: 'Outfit',
                fontSize: 12.sp,
                fontWeight: FontWeight.w400,
                color: Colors.redAccent,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

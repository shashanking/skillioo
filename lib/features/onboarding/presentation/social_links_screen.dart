import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/gradient_cta_button.dart';
import '../../../core/widgets/common_background.dart';
import '../application/onboarding_data_provider.dart';

class SocialLinksScreen extends ConsumerStatefulWidget {
  const SocialLinksScreen({
    super.key,
    this.backFallbackRoute = '/professional-certificates',
    this.skipNextRoute = '/options',
    this.continueNextRoute = '/professional-bio',
    this.showStepIndicator = true,
  });

  final String backFallbackRoute;
  final String skipNextRoute;
  final String continueNextRoute;
  final bool showStepIndicator;

  @override
  ConsumerState<SocialLinksScreen> createState() => _SocialLinksScreenState();
}

class _SocialLinksScreenState extends ConsumerState<SocialLinksScreen> {
  final TextEditingController _instaLinkController = TextEditingController();
  final TextEditingController _instaFollowersController =
      TextEditingController();
  final TextEditingController _facebookLinkController = TextEditingController();
  final TextEditingController _facebookFollowersController =
      TextEditingController();
  String? _instaLinkError;
  String? _facebookLinkError;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _instaLinkController.dispose();
    _instaFollowersController.dispose();
    _facebookLinkController.dispose();
    _facebookFollowersController.dispose();
    super.dispose();
  }

  bool _isValidSocialUrl(String value) {
    final uri = Uri.tryParse(value.trim());
    if (uri == null || !uri.hasAbsolutePath) {
      return false;
    }

    final scheme = uri.scheme.toLowerCase();
    return (scheme == 'http' || scheme == 'https') && uri.host.isNotEmpty;
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
                child: ListView(
                  // crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 16.h),
                    _buildTopBar(context),
                    SizedBox(height: 24.h),
                    _buildHeader(),
                    SizedBox(height: 24.h),
                    _buildSocialSection(),
                    SizedBox(height: 200),
                  ],
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 24.h,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildContinueButton(context),
                      SizedBox(height: 8.h),
                      _buildSkipButton(context),
                    ],
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
              GoRouter.of(context).go(widget.backFallbackRoute);
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
        if (widget.showStepIndicator)
          Text(
            'Step: 3 of 4',
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

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Add Your Social Profile Links',
          style: TextStyle(
            fontFamily: 'Neue',
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFFF5F5F5),
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          'Add at least one social media link (Instagram or Facebook) with optional follower counts.',
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

  Widget _buildSocialSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Instagram',
          style: TextStyle(
            fontFamily: 'Outfit',
            fontSize: 15.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFFF5F5F5),
          ),
        ),
        SizedBox(height: 10.h),
        _buildSocialLinkField('Instagram Link', _instaLinkController),
        if (_instaLinkError != null) ...[
          SizedBox(height: 6.h),
          Text(
            _instaLinkError!,
            style: TextStyle(
              fontFamily: 'Outfit',
              fontSize: 12.sp,
              fontWeight: FontWeight.w400,
              color: Colors.redAccent,
            ),
          ),
        ],
        SizedBox(height: 10.h),
        _buildFollowField('Followers (Optional)', _instaFollowersController),
        SizedBox(height: 24.h),
        Text(
          'Facebook',
          style: TextStyle(
            fontFamily: 'Outfit',
            fontSize: 15.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFFF5F5F5),
          ),
        ),
        SizedBox(height: 10.h),
        _buildSocialLinkField('Facebook Link', _facebookLinkController),
        if (_facebookLinkError != null) ...[
          SizedBox(height: 6.h),
          Text(
            _facebookLinkError!,
            style: TextStyle(
              fontFamily: 'Outfit',
              fontSize: 12.sp,
              fontWeight: FontWeight.w400,
              color: Colors.redAccent,
            ),
          ),
        ],
        SizedBox(height: 10.h),
        _buildFollowField('Followers (Optional)', _facebookFollowersController),
      ],
    );
  }

  Widget _buildSocialLinkField(String label, TextEditingController controller) {
    return Container(
      height: 56.h,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(24.r),
      ),
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.url,
        style: TextStyle(
          fontFamily: 'Outfit',
          fontSize: 16.sp,
          fontWeight: FontWeight.w500,
          color: const Color(0xFFF5F5F5),
        ),
        cursorColor: Colors.white,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: label,
          hintStyle: TextStyle(
            fontFamily: 'Outfit',
            fontSize: 16.sp,
            fontWeight: FontWeight.w400,
            color: Colors.white.withValues(alpha: 0.6),
          ),
          isCollapsed: true,
        ),
      ),
    );
  }

  Widget _buildFollowField(String label, TextEditingController controller) {
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
          height: 48.h,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20.r),
          ),
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.next,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: TextStyle(
              fontFamily: 'Outfit',
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: const Color(0xFFF5F5F5),
            ),
            cursorColor: Colors.white,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: '0',
              hintStyle: TextStyle(
                fontFamily: 'Outfit',
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
                color: Colors.white.withValues(alpha: 0.4),
              ),
              isCollapsed: true,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContinueButton(BuildContext context) {
    return GradientCtaButton(
      label: 'Continue',
      width: double.infinity,
      height: 58,
      onPressed: () {
        final instaLink = _instaLinkController.text.trim();
        final facebookLink = _facebookLinkController.text.trim();

        final instaValid = instaLink.isEmpty || _isValidSocialUrl(instaLink);
        final facebookValid =
            facebookLink.isEmpty || _isValidSocialUrl(facebookLink);

        setState(() {
          _instaLinkError = instaLink.isNotEmpty && !instaValid
              ? 'Enter a valid Instagram URL'
              : null;
          _facebookLinkError = facebookLink.isNotEmpty && !facebookValid
              ? 'Enter a valid Facebook URL'
              : null;
        });

        if (!instaValid || !facebookValid) {
          return;
        }

        final socialMediaFollows = <Map<String, dynamic>>[];
        if (instaLink.isNotEmpty) {
          socialMediaFollows.add({
            'socialMedia': 'INSTAGRAM',
            'link': instaLink,
            'followers':
                int.tryParse(_instaFollowersController.text.trim()) ?? 0,
          });
        }
        if (facebookLink.isNotEmpty) {
          socialMediaFollows.add({
            'socialMedia': 'FACEBOOK',
            'link': facebookLink,
            'followers':
                int.tryParse(_facebookFollowersController.text.trim()) ?? 0,
          });
        }

        if (socialMediaFollows.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Please add at least one social media link to continue.',
              ),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        ref.read(onboardingDataProvider.notifier).state = ref
            .read(onboardingDataProvider)
            .copyWith(socialMediaFollows: socialMediaFollows);
        GoRouter.of(context).go(widget.continueNextRoute);
      },
    );
  }

  /// Skips the (optional) social media step — clears any links and
  /// proceeds with the rest of onboarding.
  Widget _buildSkipButton(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        ref.read(onboardingDataProvider.notifier).state = ref
            .read(onboardingDataProvider)
            .copyWith(socialMediaFollows: <Map<String, dynamic>>[]);
        GoRouter.of(context).go(widget.continueNextRoute);
      },
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 10.h),
        child: Text(
          'Skip for now',
          style: TextStyle(
            fontFamily: 'Outfit',
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: Colors.white.withValues(alpha: 0.7),
          ),
        ),
      ),
    );
  }
}

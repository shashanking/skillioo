import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../constants/app_constants.dart';
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
  final TextEditingController _instaFollowingController =
      TextEditingController();
  final TextEditingController _facebookLinkController = TextEditingController();
  final TextEditingController _facebookFollowersController =
      TextEditingController();
  final TextEditingController _facebookFollowingController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _instaLinkController.dispose();
    _instaFollowersController.dispose();
    _instaFollowingController.dispose();
    _facebookLinkController.dispose();
    _facebookFollowersController.dispose();
    _facebookFollowingController.dispose();
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
                  child: _buildContinueButton(context),
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
              child: Icon(
                Icons.arrow_back,
                color: const Color(0xFFF5F5F5),
                size: 20.sp,
              ),
            ),
          ),
        ),
        if (widget.showStepIndicator)
          Text(
            'Step: 1 of 3',
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
        SizedBox(height: 10.h),
        Row(
          children: [
            Expanded(
              child: _buildFollowField(
                'Followers (Optional)',
                _instaFollowersController,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _buildFollowField(
                'Following (Optional)',
                _instaFollowingController,
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),
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
        SizedBox(height: 10.h),
        Row(
          children: [
            Expanded(
              child: _buildFollowField(
                'Followers (Optional)',
                _facebookFollowersController,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _buildFollowField(
                'Following (Optional)',
                _facebookFollowingController,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSocialLinkField(String label, TextEditingController controller) {
    return Container(
      height: 56.h,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(48.r),
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
            borderRadius: BorderRadius.circular(24.r),
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
    return SizedBox(
      width: double.infinity,
      height: 58.h,
      child: TextButton(
        onPressed: () {
          final socialMediaFollows = <Map<String, dynamic>>[];

          final instaLink = _instaLinkController.text.trim();
          if (instaLink.isNotEmpty) {
            socialMediaFollows.add({
              'socialMedia': 'INSTAGRAM',
              'link': instaLink,
              'followers': int.tryParse(_instaFollowersController.text.trim()),
              'following': int.tryParse(_instaFollowingController.text.trim()),
            });
          }

          final facebookLink = _facebookLinkController.text.trim();
          if (facebookLink.isNotEmpty) {
            socialMediaFollows.add({
              'socialMedia': 'FACEBOOK',
              'link': facebookLink,
              'followers': int.tryParse(
                _facebookFollowersController.text.trim(),
              ),
              'following': int.tryParse(
                _facebookFollowingController.text.trim(),
              ),
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
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(48.r),
          ),
          backgroundColor: Colors.transparent,
        ),
        child: Ink(
          decoration: BoxDecoration(
            gradient: AppColors.ctaGradient,
            borderRadius: BorderRadius.circular(48.r),
          ),
          child: Center(
            child: Text(
              'Continue',
              style: TextStyle(
                fontFamily: 'Outfit',
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFFF5F5F5),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

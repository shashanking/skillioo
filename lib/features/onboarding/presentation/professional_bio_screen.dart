import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../constants/app_constants.dart';
import '../../../core/widgets/common_background.dart';
import '../application/professional_bio_provider.dart';

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
      _showContinue =
          bio.isNotEmpty &&
          hourly.isNotEmpty &&
          daily.isNotEmpty &&
          weekly.isNotEmpty &&
          monthly.isNotEmpty;
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
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: SizedBox(
                    width: double.infinity,
                    height: 58.h,
                    child: TextButton(
                      onPressed: _showContinue
                          ? () {
                              ref
                                  .read(professionalBioProvider.notifier)
                                  .state = ProfessionalBioData(
                                bio: _bioController.text.trim(),
                                hourly: _hourlyController.text.trim(),
                                daily: _dailyController.text.trim(),
                                weekly: _weeklyController.text.trim(),
                                monthly: _monthlyController.text.trim(),
                              );
                              GoRouter.of(context).go('/options');
                            }
                          : null,
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(48.r),
                        ),
                        backgroundColor: Colors.black,
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
              GoRouter.of(context).go('/social-links');
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
        _buildRateField('Hourly Pricing', _hourlyController),
        SizedBox(height: 12.h),
        _buildRateField('Daily Pricing', _dailyController),
        SizedBox(height: 12.h),
        _buildRateField('Weekly Pricing', _weeklyController),
        SizedBox(height: 12.h),
        _buildRateField('Monthly Pricing', _monthlyController),
      ],
    );
  }

  Widget _buildRateField(String label, TextEditingController controller) {
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
            borderRadius: BorderRadius.circular(48.r),
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
            decoration: const InputDecoration(
              border: InputBorder.none,
              isCollapsed: true,
            ),
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(7),
            ],
          ),
        ),
      ],
    );
  }
}

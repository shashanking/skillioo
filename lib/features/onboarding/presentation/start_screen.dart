import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../constants/app_constants.dart';

class StartScreen extends ConsumerWidget {
  const StartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
        child: SafeArea(
          child: Column(
            children: [
              // Logo section with Hero animation
              Expanded(
                flex: 2,
                child: Center(
                  child: Hero(
                    tag: 'logo',
                    child: Image.asset(
                      AppAssets.logoPng,
                      width: 200,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),

              // Content cards section
              Expanded(
                flex: 3,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 200.h,
                        child: Stack(
                          alignment: Alignment.center,
                          clipBehavior: Clip.none,
                          children: [
                            Positioned(
                              left: -80.w,
                              child: Opacity(
                                opacity: 0.75,
                                child: SizedBox(
                                  width: 104.w,
                                  height: 104.w,
                                  child: Image.asset(
                                    AppAssets.welcomeCardLeft,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              right: -80.w,
                              child: Opacity(
                                opacity: 0.75,
                                child: SizedBox(
                                  width: 104.w,
                                  height: 104.w,
                                  child: Image.asset(
                                    AppAssets.welcomeCardRight,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 170.w,
                              height: 170.w,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(48.r),
                                ),
                                padding: EdgeInsets.all(8.w),
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(40.r),
                                      child: Image.asset(
                                        AppAssets.welcomeCardCenter,
                                        fit: BoxFit.cover,
                                        width: 134.w,
                                      ),
                                    ),
                                    IgnorePointer(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            40.r,
                                          ),
                                          border: Border.all(
                                            color: Colors.white.withValues(
                                              alpha: 0.48,
                                            ),
                                            width: 1,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      bottom: -6.h,
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 13.w,
                                          vertical: 2.h,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(alpha: 0.06),
                                          borderRadius: BorderRadius.circular(
                                            24.r,
                                          ),
                                        ),
                                        child: Text(
                                          AppStrings.trendingTimer,
                                          style: TextStyle(
                                            color: const Color(0xFFF5F5F5),
                                            fontSize: 10.sp,
                                            fontWeight: FontWeight.w500,
                                            height: 1.4,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Welcome section
              Expanded(
                flex: 2,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        AppStrings.welcome,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        AppStrings.welcomeDescription,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16.sp,
                          height: 1.5,
                        ),
                      ),
                      SizedBox(height: 24.h),
                      _buildLetsGoButton(context),
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

  Widget _buildLetsGoButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56.h,
      child: ElevatedButton(
        onPressed: () {
          GoRouter.of(context).go('/loader?next=/phone');
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28.r),
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF8F39B2), Color(0xFF2F208E)],
            ),
            borderRadius: BorderRadius.circular(28.r),
          ),
          child: Center(
            child: Text(
              AppStrings.letsGo,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

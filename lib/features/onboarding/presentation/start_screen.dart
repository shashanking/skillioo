import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../constants/app_constants.dart';
import '../../dashboard/data/trending_talent_model.dart';
import '../../dashboard/presentation/widgets/custom_trending_carousel.dart';

class StartScreen extends ConsumerWidget {
  const StartScreen({super.key});

  static final _welcomeTalents = [
    TrendingTalent(
      name: 'Top Artist',
      views: '1.2M Views',
      likes: '8K Likes',
      timer: '1:25',
      imagePath: AppAssets.welcomeCardLeft,
      tintColor: const Color(0xFF8F39B2),
    ),
    TrendingTalent(
      name: 'Star Performer',
      views: '2.5M Views',
      likes: '12K Likes',
      timer: '2:10',
      imagePath: AppAssets.welcomeCardCenter,
      tintColor: const Color(0xFF1A7F8F),
    ),
    TrendingTalent(
      name: 'Rising Talent',
      views: '980K Views',
      likes: '5K Likes',
      timer: '0:55',
      imagePath: AppAssets.welcomeCardRight,
      tintColor: const Color(0xFF2F208E),
    ),
  ];

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
                flex: 1,
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

              // Content cards section — animated carousel (same as dashboard)
              Expanded(
                flex: 2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [CustomTrendingCarousel(talents: _welcomeTalents)],
                ),
              ),
              SizedBox(height: 40.h),
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

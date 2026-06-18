import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../constants/app_constants.dart';
import '../../../core/localization/locale_extension.dart';
import '../../../core/widgets/common_background.dart';
import '../../../core/widgets/custom_text.dart';

class OptionSelectionScreen extends ConsumerWidget {
  const OptionSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = ref.tr;

    return Scaffold(
      body: CommonBackground(
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 200.w,
                  child: Image.asset(AppAssets.logoPng, fit: BoxFit.contain),
                ),

                CustomText(
                  tr.welcomeToSkillioo,
                  fontFamily: 'Neue',
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
                SizedBox(height: 32.h),
                _OptionCard(
                  title: tr.selectAppLanguage,
                  assetPath: AppAssets.selectLanguagePng,
                  onTap: () {
                    GoRouter.of(context).go('/language');
                  },
                ),
                SizedBox(height: 16.h),
                _OptionCard(
                  title: tr.createProfile,
                  assetPath: AppAssets.createProfilePng,
                  onTap: () {
                    GoRouter.of(context).go('/profile-type');
                  },
                ),
                SizedBox(height: 16.h),
                _OptionCard(
                  title: tr.proceedToDashboard,
                  assetPath: AppAssets.proceedDashboardPng,
                  onTap: () {
                    GoRouter.of(context).go('/landing');
                  },
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OptionCard extends StatelessWidget {
  final String title;
  final String assetPath;
  final VoidCallback onTap;

  const _OptionCard({
    required this.title,
    required this.assetPath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(24.r);

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: double.infinity,
        child: Stack(
          children: [
            // Border gradient
            Positioned.fill(
              child: Container(decoration: BoxDecoration(borderRadius: radius)),
            ),
            // Black inset
            Positioned.fill(
              child: Padding(
                padding: EdgeInsets.all(1.2.w),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(48),
                  child: Container(color: Colors.white.withAlpha(22)),
                ),
              ),
            ),
            // Content
            Container(
              height: 68.h,
              margin: EdgeInsets.all(2.6.w),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 18.h),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(48),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    assetPath,
                    fit: BoxFit.contain,
                    width: 48.w,
                    height: 48.w,
                  ),

                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

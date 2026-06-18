import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/gradient_cta_button.dart';
import '../../../constants/app_constants.dart';
import '../../../core/widgets/common_background.dart';
import '../application/profile_type_provider.dart';

class ProfileTypeSelectionScreen extends ConsumerWidget {
  const ProfileTypeSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedType = ref.watch(profileTypeProvider);

    return Scaffold(
      body: CommonBackground(
        child: SafeArea(
          child: Stack(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 16.h),
                    _buildBackButton(context),
                    SizedBox(height: 24.h),
                    _buildHeader(),
                    SizedBox(height: 24.h),
                    _buildCardsRow(ref, selectedType, context),
                  ],
                ),
              ),
              _buildContinueButton(context, selectedType, ref),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (GoRouter.of(context).canPop()) {
          GoRouter.of(context).pop();
        } else {
          GoRouter.of(context).go('/options');
        }
      },
      child: Container(
        width: 48.w,
        height: 48.w,
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(12),
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
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Choose Your Profile Type.',
          style: TextStyle(
            fontFamily: 'Neue',
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFFF5F5F5),
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          'Going solo or rolling with a group? Pick your vibe.',
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

  Widget _buildCardsRow(
    WidgetRef ref,
    ProfileType? selectedType,
    BuildContext context,
  ) {
    return Row(
      children: [
        Expanded(
          child: _ProfileTypeCard(
            title: 'Individual',
            description: 'A platform for showcasing individual creativity',
            imagePath: AppAssets.individualProfileJpg,
            isSelected: selectedType == ProfileType.individual,
            onTap: () async {
              ref.read(profileTypeProvider.notifier).state =
                  ProfileType.individual;
              await Future.delayed(const Duration(milliseconds: 100));

              if (context.mounted) {
                context.go('/individual-name');
              }
            },
          ),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: _ProfileTypeCard(
            title: 'Group',
            description: 'Celebrating talent through teamwork \nand unity',
            imagePath: AppAssets.groupProfileJpg,
            isSelected: selectedType == ProfileType.group,
            onTap: () async {
              ref.read(profileTypeProvider.notifier).state = ProfileType.group;
              await Future.delayed(const Duration(milliseconds: 100));

              if (context.mounted) {
                context.go('/group-name');
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildContinueButton(
    BuildContext context,
    ProfileType? selectedType,
    WidgetRef ref,
  ) {
    final isEnabled = selectedType != null;
    if (!isEnabled) {
      return const SizedBox.shrink();
    }

    return Positioned(
      left: 0,
      right: 0,
      bottom: 24.h,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: GradientCtaButton(
          label: 'Continue',
          width: double.infinity,
          height: 58,
          onPressed: () {
            final type = ref.read(profileTypeProvider);
            if (type == null) return;
            GoRouter.of(context).go('/individual-name');
          },
        ),
      ),
    );
  }
}

class _ProfileTypeCard extends StatelessWidget {
  final String title;
  final String description;
  final String imagePath;
  final bool isSelected;
  final VoidCallback onTap;

  const _ProfileTypeCard({
    required this.title,
    required this.description,
    required this.imagePath,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(26.r),
          gradient: isSelected
              ? const LinearGradient(
                  colors: [Color(0xFFC00F8B), Color(0xFF05DAF1)],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                )
              : const LinearGradient(
                  colors: [Color(0xFF000000), Color(0xFFB2B2B2)],
                  begin: Alignment.bottomRight,
                  end: Alignment.topLeft,
                ),
        ),
        padding: EdgeInsets.all(2),
        child: Container(
          height: 248.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24.r),
            image: DecorationImage(
              image: AssetImage(imagePath),
              fit: BoxFit.cover,
            ),
          ),
          child: Container(
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24.r),
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black],
                stops: [0.0, 0.64],
              ),
            ),
            alignment: Alignment.bottomLeft,
            child: SizedBox(
              width: 134.w,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'Neue',
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFF5F5F5),
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    description,
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFFF5F5F5),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

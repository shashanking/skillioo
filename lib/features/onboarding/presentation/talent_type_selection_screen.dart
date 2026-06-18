import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../constants/app_constants.dart';
import '../../../core/widgets/common_background.dart';
import '../application/talent_type_provider.dart';

class TalentTypeSelectionScreen extends ConsumerWidget {
  const TalentTypeSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedType = ref.watch(talentTypeProvider);
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
                    _buildTopBar(context),
                    SizedBox(height: 24.h),
                    _buildHeader(),
                    SizedBox(height: 24.h),
                    _buildCardsRow(ref, selectedType, context),
                    const Spacer(),
                    // The note is a Professional-only requirement
                    // (certifications / proof of events). Hide it when the
                    // Skilled type is selected.
                    if (selectedType != TalentType.skilled) ...[
                      _buildNote(),
                      SizedBox(height: 10.h),
                    ],
                  ],
                ),
              ),
              // _buildContinueButton(context, selectedType),
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
              GoRouter.of(context).go('/individual-address');
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
          'Select Talent Type',
          style: TextStyle(
            fontFamily: 'Neue',
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFFF5F5F5),
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          "Pick whether you're a pro or bringing skilled vibes.",
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
    TalentType? selectedType,
    BuildContext context,
  ) {
    return Row(
      children: [
        Expanded(
          child: _TalentCard(
            title: 'Professional',
            imagePath: AppAssets.professionalJpg,
            isSelected: selectedType == TalentType.professional,
            onTap: () async {
              ref.read(talentTypeProvider.notifier).state =
                  TalentType.professional;
              await Future.delayed(const Duration(milliseconds: 100));
              if (context.mounted) {
                context.go('/talent-category');
              }
            },
          ),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: _TalentCard(
            title: 'Skilled',
            imagePath: AppAssets.individualProfileJpg,
            isSelected: selectedType == TalentType.skilled,
            onTap: () async {
              ref.read(talentTypeProvider.notifier).state = TalentType.skilled;
              await Future.delayed(const Duration(milliseconds: 100));
              if (context.mounted) {
                context.go('/talent-category');
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildNote() {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: 'Note: ',
            style: TextStyle(
              fontFamily: 'Outfit',
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          TextSpan(
            text:
                'Upload valid certifications and proof of events for each skill you add. This helps keep profiles authentic and builds trust with clients.',
            style: TextStyle(
              fontFamily: 'Outfit',
              fontSize: 16.sp,
              fontWeight: FontWeight.w400,
              color: const Color.fromARGB(166, 245, 245, 245),
            ),
          ),
        ],
      ),
    );
  }
}

class _TalentCard extends StatelessWidget {
  final String title;
  final String imagePath;
  final bool isSelected;
  final VoidCallback onTap;

  const _TalentCard({
    required this.title,
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
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(24)),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black],
                stops: [0.0, 0.8286],
              ),
            ),
            alignment: Alignment.bottomLeft,
            child: Text(
              title,
              style: TextStyle(
                fontFamily: 'Neue',
                fontSize: 17.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFFF5F5F5),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

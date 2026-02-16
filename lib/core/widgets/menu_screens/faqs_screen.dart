import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../constants/app_constants.dart';
import '../common_background.dart';
import '../custom_text.dart';
import '../icon_button.dart';

class FaqsScreen extends StatefulWidget {
  const FaqsScreen({super.key});

  @override
  State<FaqsScreen> createState() => _FaqsScreenState();
}

class _FaqsScreenState extends State<FaqsScreen> {
  int? _expandedIndex;

  final List<_FaqItem> _faqItems = const [
    _FaqItem(
      question: AppStrings.faqQ1,
      answer:
          'Skillioo is India\'s first talent hub — a platform to discover, showcase, and hire skilled individuals across dance, music, acting, animation, and more.',
    ),
    _FaqItem(
      question: AppStrings.faqQ2,
      answer:
          'Download the app, sign up with your phone number, choose your profile type (Professional or Skilled), and upload your best work to get started.',
    ),
    _FaqItem(
      question: AppStrings.faqQ3,
      answer:
          'Yes! Creating a profile and showcasing your talent is completely free. Some premium features may require a subscription.',
    ),
    _FaqItem(
      question: AppStrings.faqQ4,
      answer:
          'Hirers can browse talent by category, watch your videos, view your certificates, and directly connect with you through the app.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CommonBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Container(
                padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 24.h),
                decoration: BoxDecoration(
                  color: AppColors.glassWhite12,
                ),
                child: Row(
                  children: [
                    IconCircleButton(
                      icon: Icons.arrow_back,
                      onTap: () => Navigator.of(context).maybePop(),
                    ),
                    SizedBox(width: 24.w),
                    CustomText(
                      AppStrings.faqs,
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Neue',
                      color: AppColors.foundationBlack20,
                    ),
                  ],
                ),
              ),
              // Content
              Expanded(
                child: ListView.separated(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 24.h,
                  ),
                  itemCount: _faqItems.length,
                  separatorBuilder: (_, __) => SizedBox(height: 12.h),
                  itemBuilder: (context, index) {
                    final item = _faqItems[index];
                    final isExpanded = _expandedIndex == index;
                    return _buildFaqTile(item, index, isExpanded);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFaqTile(_FaqItem item, int index, bool isExpanded) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _expandedIndex = isExpanded ? null : index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: AppColors.glassWhite12,
          borderRadius: BorderRadius.circular(24.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: CustomText(
                    item.question,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Neue',
                    color: AppColors.foundationBlack20,
                  ),
                ),
                Icon(
                  isExpanded ? Icons.remove : Icons.add,
                  color: AppColors.foundationBlack20,
                  size: 24.sp,
                ),
              ],
            ),
            if (isExpanded) ...[
              SizedBox(height: 12.h),
              CustomText(
                item.answer,
                fontSize: 16.sp,
                fontWeight: FontWeight.w400,
                color: AppColors.foundationBlack20,
                height: 1.5,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _FaqItem {
  final String question;
  final String answer;

  const _FaqItem({required this.question, required this.answer});
}

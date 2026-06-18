import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../constants/app_constants.dart';
import '../../localization/locale_extension.dart';
import '../common_background.dart';
import '../custom_text.dart';
import '../icon_button.dart';

class FaqsScreen extends ConsumerStatefulWidget {
  const FaqsScreen({super.key});

  @override
  ConsumerState<FaqsScreen> createState() => _FaqsScreenState();
}

class _FaqsScreenState extends ConsumerState<FaqsScreen> {
  int? _expandedIndex;

  List<_FaqItem> _buildFaqItems() {
    final tr = ref.tr;
    return [
      _FaqItem(question: tr.faqQ1, answer: tr.aboutSkilliooBody),
      _FaqItem(question: tr.faqQ2, answer: tr.howItWorksBody),
      _FaqItem(question: tr.faqQ3, answer: tr.get('faqA3')),
      _FaqItem(question: tr.faqQ4, answer: tr.get('faqA4')),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final tr = ref.tr;
    final faqItems = _buildFaqItems();
    return Scaffold(
      body: CommonBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Container(
                padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 24.h),
                decoration: BoxDecoration(color: AppColors.glassWhite12),
                child: Row(
                  children: [
                    IconCircleButton(
                      assetPath: 'assets/images/arrow-left.png',
                      onTap: () => Navigator.of(context).maybePop(),
                    ),
                    SizedBox(width: 24.w),
                    CustomText(
                      tr.faqs,
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
                  itemCount: faqItems.length,
                  separatorBuilder: (_, __) => SizedBox(height: 12.h),
                  itemBuilder: (context, index) {
                    final item = faqItems[index];
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

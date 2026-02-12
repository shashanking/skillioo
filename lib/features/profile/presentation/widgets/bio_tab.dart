import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/widgets/custom_text.dart';

class BioTab extends StatelessWidget {
  const BioTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            "Include about your skills and talent. Don't include personal info like mobile number, email address etc.",
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
            color: Colors.white.withValues(alpha: 0.9),
            height: 1.5,
          ),
          SizedBox(height: 32.h),

          CustomText(
            "Hiring Rates",
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
          SizedBox(height: 24.h),

          _buildRateRow("Hourly", "₹ 50/-"),
          _buildRateRow("Daily", "₹ 500/-"),
          _buildRateRow("Weekly", "₹ 5,000/-"),
          _buildRateRow("Monthly", "₹ 2,00,000/-", isLast: true),
        ],
      ),
    );
  }

  Widget _buildRateRow(String label, String price, {bool isLast = false}) {
    return Container(
      margin: EdgeInsets.only(bottom: 20.h),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomText(
                label,
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
              CustomText(
                price,
                fontSize: 16.sp,
                fontWeight: FontWeight.w400,
                color: Colors.white,
              ),
            ],
          ),
          SizedBox(height: 16.h),
          if (!isLast)
            Divider(color: Colors.white.withValues(alpha: 0.2), thickness: 0.5),
        ],
      ),
    );
  }
}

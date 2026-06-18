import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/widgets/custom_text.dart';
import '../../../dashboard/application/states/profile_list_state.dart';
import '../../application/hiring_rate_providers.dart';

class BioTab extends ConsumerWidget {
  final ProfileItem profile;
  final bool isOwnProfile;
  final String? bioOverride;

  const BioTab({
    super.key,
    required this.profile,
    this.isOwnProfile = true,
    this.bioOverride,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resolvedBio = bioOverride ?? profile.bio;
    final bioText = resolvedBio.isNotEmpty ? resolvedBio : "No bio provided";

    final hiringRatesAsync = profile.portfolioId.isNotEmpty
        ? ref.watch(hiringRateProvider(profile.portfolioId))
        : null;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            bioText,
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
            color: Colors.white.withValues(alpha: 0.9),
            height: 1.5,
            maxLines: 5,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 32.h),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomText(
                "Hiring Rates",
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ],
          ),
          SizedBox(height: 24.h),

          if (hiringRatesAsync == null)
            CustomText(
              'Hiring rates not available',
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
              color: Colors.white.withValues(alpha: 0.7),
            )
          else
            hiringRatesAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
              error: (err, _) => CustomText(
                'Failed to load hiring rates',
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
                color: Colors.white.withValues(alpha: 0.7),
              ),
              data: (data) {
                final hourly = (data['hourlyPricing'] ?? '').toString();
                final daily = (data['dailyPricing'] ?? '').toString();
                final weekly = (data['weeklyPricing'] ?? '').toString();
                final monthly = (data['monthlyPricing'] ?? '').toString();

                String fmt(String raw) {
                  final v = raw.trim();
                  if (v.isEmpty) return '-';
                  final num = int.tryParse(v.replaceAll(',', ''));
                  if (num == null) return '₹ $v/-';
                  return '₹ ${_formatIndian(num)}/-';
                }

                return Column(
                  children: [
                    _buildRateRow('Hourly', fmt(hourly)),
                    _buildRateRow('Daily', fmt(daily)),
                    _buildRateRow('Weekly', fmt(weekly)),
                    _buildRateRow('Monthly', fmt(monthly), isLast: true),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }

  static String _formatIndian(int number) {
    final s = number.toString();
    if (s.length <= 3) return s;
    final last3 = s.substring(s.length - 3);
    var rest = s.substring(0, s.length - 3);
    final buf = StringBuffer();
    while (rest.length > 2) {
      buf.write('${rest.substring(0, rest.length - 2)},');
      rest = rest.substring(rest.length - 2);
    }
    return '${buf.toString()}$rest,$last3';
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
          Divider(color: Colors.white.withValues(alpha: 0.2), thickness: 0.5),
        ],
      ),
    );
  }
}

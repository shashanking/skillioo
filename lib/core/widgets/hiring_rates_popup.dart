import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../features/profile/application/hiring_rate_providers.dart';
import '../../features/profile/application/profile_detail_provider.dart';
import '../widgets/custom_text.dart';

/// Shows a bottom sheet with the hiring rates for the given [profileId].
void showHiringRatesPopup(
  BuildContext context,
  WidgetRef ref,
  String profileId,
) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => _HiringRatesSheet(profileId: profileId),
  );
}

/// Shows a bottom sheet with the profile's full bio AND hiring rates.
void showBioAndRatesPopup(
  BuildContext context,
  WidgetRef ref,
  String profileId,
) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => _BioAndRatesSheet(profileId: profileId),
  );
}

/// Hiring-rates-only sheet. Fetches the full profile to resolve the
/// portfolioId (the profile-list payload no longer carries it).
class _HiringRatesSheet extends ConsumerWidget {
  const _HiringRatesSheet({required this.profileId});

  final String profileId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(profileDetailProvider(profileId));
    return _SheetShell(
      children: [
        _sectionTitle('Hiring Rates', center: true),
        SizedBox(height: 24.h),
        detail.when(
          loading: () => _loader(),
          error: (_, __) => const _RatesList(portfolioId: ''),
          data: (data) => _RatesList(
            portfolioId: (data['portfolioId'] as String? ?? '').trim(),
          ),
        ),
      ],
    );
  }
}

/// Bio + hiring rates sheet. Both come from the full profile fetch — the
/// profile-list payload carries neither `bio` nor `portfolioId`.
class _BioAndRatesSheet extends ConsumerWidget {
  const _BioAndRatesSheet({required this.profileId});

  final String profileId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(profileDetailProvider(profileId));
    return _SheetShell(
      children: [
        detail.when(
          loading: () => _loader(),
          error: (_, __) => _content(bio: '', portfolioId: ''),
          data: (data) => _content(
            bio: (data['bio'] as String? ?? '').trim(),
            portfolioId: (data['portfolioId'] as String? ?? '').trim(),
          ),
        ),
      ],
    );
  }

  Widget _content({required String bio, required String portfolioId}) {
    final hasBio = bio.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Bio'),
        SizedBox(height: 12.h),
        CustomText(
          hasBio ? bio : 'No bio added yet.',
          fontSize: 14.sp,
          fontWeight: FontWeight.w400,
          color: hasBio
              ? Colors.white.withValues(alpha: 0.9)
              : Colors.white.withValues(alpha: 0.4),
          height: 1.5,
        ),
        SizedBox(height: 20.h),
        Divider(color: Colors.white.withValues(alpha: 0.2), thickness: 0.5),
        SizedBox(height: 16.h),
        _sectionTitle('Hiring Rates'),
        SizedBox(height: 16.h),
        _RatesList(portfolioId: portfolioId),
      ],
    );
  }
}

Widget _loader() {
  return Padding(
    padding: EdgeInsets.symmetric(vertical: 32.h),
    child: const Center(
      child: CircularProgressIndicator(color: Colors.white),
    ),
  );
}

/// Shared bottom-sheet container: dark rounded-top surface, drag handle,
/// and a scrollable body (so a long bio doesn't overflow the screen).
class _SheetShell extends StatelessWidget {
  const _SheetShell({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.of(context).size.height * 0.8;
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      padding: EdgeInsets.fromLTRB(24.w, 12.h, 24.w, 32.h),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(height: 20.h),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: children,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _sectionTitle(String text, {bool center = false}) {
  return SizedBox(
    width: double.infinity,
    child: CustomText(
      text,
      fontSize: 20.sp,
      fontWeight: FontWeight.w700,
      fontFamily: 'Neue',
      color: Colors.white,
      textAlign: center ? TextAlign.center : TextAlign.start,
    ),
  );
}

/// Fetches and renders the four hiring-rate rows for a portfolio.
class _RatesList extends ConsumerWidget {
  const _RatesList({required this.portfolioId});

  final String portfolioId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (portfolioId.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 16.h),
        child: CustomText(
          'Hiring rates not available',
          fontSize: 14.sp,
          fontWeight: FontWeight.w400,
          color: Colors.white38,
        ),
      );
    }

    final ratesAsync = ref.watch(hiringRateProvider(portfolioId));
    return ratesAsync.when(
      loading: () => Padding(
        padding: EdgeInsets.symmetric(vertical: 24.h),
        child: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      ),
      error: (_, __) => Padding(
        padding: EdgeInsets.symmetric(vertical: 24.h),
        child: CustomText(
          'Failed to load hiring rates',
          fontSize: 14.sp,
          fontWeight: FontWeight.w400,
          color: Colors.white70,
        ),
      ),
      data: (data) {
        return Column(
          children: [
            _RateRow(label: 'Hourly', price: _formatPrice(data['hourlyPricing'])),
            _RateRow(label: 'Daily', price: _formatPrice(data['dailyPricing'])),
            _RateRow(label: 'Weekly', price: _formatPrice(data['weeklyPricing'])),
            _RateRow(
              label: 'Monthly',
              price: _formatPrice(data['monthlyPricing']),
              isLast: true,
            ),
          ],
        );
      },
    );
  }
}

String _formatPrice(dynamic raw) {
  final v = (raw ?? '').toString().trim();
  if (v.isEmpty || v == '0' || v == '0.0') return '-';
  final num = int.tryParse(v.replaceAll(',', '').split('.').first);
  if (num == null) return '₹ $v/-';
  return '₹ ${_formatIndian(num)}/-';
}

String _formatIndian(int number) {
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

class _RateRow extends StatelessWidget {
  const _RateRow({
    required this.label,
    required this.price,
    this.isLast = false,
  });

  final String label;
  final String price;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 12.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomText(
                label,
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              CustomText(
                price,
                fontSize: 16.sp,
                fontWeight: FontWeight.w400,
                color: price == '-'
                    ? Colors.white.withValues(alpha: 0.4)
                    : Colors.white,
              ),
            ],
          ),
        ),
        if (!isLast)
          Divider(color: Colors.white.withValues(alpha: 0.2), thickness: 0.5),
      ],
    );
  }
}

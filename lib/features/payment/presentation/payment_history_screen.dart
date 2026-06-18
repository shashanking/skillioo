

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/services/session_prefs.dart';
import '../../../core/widgets/custom_text.dart';
import '../application/payment_providers.dart';
import '../domain/payment_models.dart';

class PaymentHistoryScreen extends ConsumerStatefulWidget {
  const PaymentHistoryScreen({super.key});

  @override
  ConsumerState<PaymentHistoryScreen> createState() =>
      _PaymentHistoryScreenState();
}

class _PaymentHistoryScreenState extends ConsumerState<PaymentHistoryScreen> {
  bool _isLoading = true;
  String _error = '';
  List<PaymentResponse> _payments = const [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPayments();
    });
  }

  Future<void> _loadPayments() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      final profileId = await SessionPrefs.instance.getProfileId();
      if (profileId.isEmpty) {
        setState(() {
          _error = 'Profile not found';
          _isLoading = false;
        });
        return;
      }

      final service = ref.read(paymentServiceProvider);
      final token = await SessionPrefs.instance.getAccessToken();
      if (token.isNotEmpty) {
        service.setAuthToken(token);
      }

      final response = await service.fetchPayments(
        userReferenceIdSet: profileId,
      );
      final status = response['status'] as int? ?? 0;
      final data = response['data'];

      if (status == 200 && data is Map) {
        final list = PaymentListResponse.fromJson(
          Map<String, dynamic>.from(data),
        );
        setState(() {
          _payments = list.items ?? const [];
          _isLoading = false;
        });
        return;
      }

      setState(() {
        _error = response['message'] as String? ?? 'Failed to load payments';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Map<String, List<PaymentResponse>> _groupByDate(
    List<PaymentResponse> payments,
  ) {
    final grouped = <String, List<PaymentResponse>>{};
    for (final payment in payments) {
      final date = _parseDate(payment.createdAt);
      final key = date == null
          ? 'Unknown Date'
          : '${date.day} ${_monthName(date.month)} ${date.year}';
      grouped.putIfAbsent(key, () => []).add(payment);
    }
    return grouped;
  }

  DateTime? _parseDate(String? value) {
    if (value == null || value.isEmpty) return null;
    try {
      return DateTime.parse(value).toLocal();
    } catch (_) {
      try {
        final parts = value.split(' ');
        if (parts.length != 2) return null;
        final dateParts = parts.first.split('-');
        final timeParts = parts.last.split(':');
        if (dateParts.length != 3 || timeParts.length != 3) return null;
        return DateTime(
          int.parse(dateParts[2]),
          int.parse(dateParts[1]),
          int.parse(dateParts[0]),
          int.parse(timeParts[0]),
          int.parse(timeParts[1]),
          int.parse(timeParts[2]),
        );
      } catch (_) {
        return null;
      }
    }
  }

  String _monthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month - 1];
  }

  String _titleFromPayment(PaymentResponse payment) {
    if (payment.service == 1.toString()) return 'Subscription Payment';
    return 'Payment';
  }

  /// Returns a status pill for non-paid Razorpay PaymentLink statuses.
  /// Paid payments don't get a chip (they're the default expected state).
  Widget? _statusChip(String rawStatus) {
    final status = rawStatus.toLowerCase();
    if (status.isEmpty || status == 'paid') return null;

    late final String label;
    late final Color color;
    switch (status) {
      case 'cancelled':
        label = 'Cancelled';
        color = const Color(0xFFFF6B6B);
        break;
      case 'expired':
        label = 'Expired';
        color = const Color(0xFFB0B0B0);
        break;
      case 'created':
      case 'issued':
        label = 'Pending';
        color = const Color(0xFFFFC857);
        break;
      default:
        label = rawStatus;
        color = const Color(0xFFB0B0B0);
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: color.withValues(alpha: 0.5), width: 1),
      ),
      child: CustomText(
        label,
        fontSize: 11.sp,
        fontWeight: FontWeight.w600,
        color: color,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final grouped = _groupByDate(_payments);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF7B2FF7), Color(0xFF14121A), Color(0xFF0C0B10)],
            stops: [0.0, 0.45, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        width: 36.w,
                        height: 36.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.12),
                        ),
                        child: Image.asset(
                          'assets/images/arrow-left.png',
                          color: Colors.white,
                          width: 18.sp,
                          height: 18.sp,
                        ),
                      ),
                    ),
                    SizedBox(width: 16.w),
                    CustomText(
                      'Payment History',
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      )
                    : _error.isNotEmpty
                    ? Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 24.w),
                          child: CustomText(
                            "Something went wrong.",
                            fontSize: 14.sp,
                            color: Colors.white70,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    : _payments.isEmpty
                    ? const Center(
                        child: CustomText(
                          'No payment history found',
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      )
                    : ListView(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 8.h,
                        ),
                        children: grouped.entries.map((entry) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 12.h),
                              CustomText(
                                entry.key,
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                              SizedBox(height: 16.h),
                              ...entry.value.map(_buildPaymentCard),
                            ],
                          );
                        }).toList(),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentCard(PaymentResponse payment) {
    final amount = payment.amount ?? '0';
    final statusChip = _statusChip(payment.paymentStatus);

    return Container(
      margin: EdgeInsets.only(bottom: 14.h),
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24.r),
        color: Colors.white.withValues(alpha: 0.12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.workspace_premium_outlined,
                color: Colors.white,
                size: 18.sp,
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: CustomText(
                  _titleFromPayment(payment),
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              if (statusChip != null) statusChip,
            ],
          ),
          SizedBox(height: 12.h),
          // this is in paise not rupees , hav to divide with 100
          CustomText(
            '₹ ${(double.parse(amount) / 100).toStringAsFixed(2)}',
            fontSize: 26.sp,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
          SizedBox(height: 14.h),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(
                      'Payment Method',
                      fontSize: 12.sp,
                      color: Colors.white70,
                    ),
                    SizedBox(height: 6.h),
                    CustomText(
                      payment.paymentMethodLabel,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(
                      'Transaction ID',
                      fontSize: 12.sp,
                      color: Colors.white70,
                    ),
                    SizedBox(height: 6.h),
                    CustomText(
                      payment.transactionId.isEmpty
                          ? '-'
                          : payment.transactionId,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

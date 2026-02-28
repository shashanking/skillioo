import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../constants/app_constants.dart';
import '../../../core/widgets/common_background.dart';
import '../application/onboarding_data_provider.dart';

class IndividualAddressScreen extends ConsumerStatefulWidget {
  const IndividualAddressScreen({super.key});

  @override
  ConsumerState<IndividualAddressScreen> createState() =>
      _IndividualAddressScreenState();
}

class _IndividualAddressScreenState
    extends ConsumerState<IndividualAddressScreen> {
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _pincodeController = TextEditingController();

  final FocusNode _addressFocus = FocusNode();
  final FocusNode _cityFocus = FocusNode();
  final FocusNode _stateFocus = FocusNode();
  final FocusNode _countryFocus = FocusNode();
  final FocusNode _pincodeFocus = FocusNode();

  bool _showContinue = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _addressFocus.requestFocus();
    });
    _addressController.addListener(_onFieldsChanged);
    _cityController.addListener(_onFieldsChanged);
    _stateController.addListener(_onFieldsChanged);
    _countryController.addListener(_onFieldsChanged);
    _pincodeController.addListener(_onFieldsChanged);
  }

  void _onFieldsChanged() {
    final allFilled =
        _addressController.text.trim().isNotEmpty &&
        _cityController.text.trim().isNotEmpty &&
        _stateController.text.trim().isNotEmpty &&
        _countryController.text.trim().isNotEmpty &&
        _pincodeController.text.trim().isNotEmpty;
    if (allFilled != _showContinue) {
      setState(() {
        _showContinue = allFilled;
      });
    }
  }

  @override
  void dispose() {
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _countryController.dispose();
    _pincodeController.dispose();
    _addressFocus.dispose();
    _cityFocus.dispose();
    _stateFocus.dispose();
    _countryFocus.dispose();
    _pincodeFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: CommonBackground(
        child: SafeArea(
          child: Stack(
            children: [
              Container(
                height: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(bottom: 120.h),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 16.h),
                      _buildTopBar(context),
                      SizedBox(height: 24.h),
                      _buildHeader(),
                      SizedBox(height: 24.h),
                      _buildAddressField(),
                      SizedBox(height: 16.h),
                      _buildCityStateRow(),
                      SizedBox(height: 16.h),
                      _buildCountryPincodeRow(),
                    ],
                  ),
                ),
              ),
              if (_showContinue) _buildContinueButton(context),
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
          onTap: () => GoRouter.of(context).pop(),
          child: Container(
            width: 48.w,
            height: 48.w,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(124.r),
            ),
            child: Center(
              child: Icon(
                Icons.arrow_back,
                color: const Color(0xFFF5F5F5),
                size: 20.sp,
              ),
            ),
          ),
        ),
        Text(
          'Step: 3 of 3',
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
          'Enter Your Address',
          style: TextStyle(
            fontFamily: 'Neue',
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFFF5F5F5),
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          'Helps us personalize things for you.',
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

  Widget _buildAddressField() {
    return Container(
      height: 140.h,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(24.r),
      ),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: TextField(
        controller: _addressController,
        focusNode: _addressFocus,
        maxLines: null,
        keyboardType: TextInputType.streetAddress,
        style: TextStyle(
          fontFamily: 'Outfit',
          fontSize: 14.sp,
          fontWeight: FontWeight.w400,
          color: const Color(0xFFF5F5F5),
        ),
        cursorColor: Colors.white,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: 'Address',
          hintStyle: TextStyle(
            fontFamily: 'Outfit',
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
            color: Colors.white.withValues(alpha: 0.6),
          ),
          isCollapsed: true,
        ),
        inputFormatters: [LengthLimitingTextInputFormatter(200)],
      ),
    );
  }

  Widget _buildCityStateRow() {
    return Row(
      children: [
        Expanded(
          child: _pillField(
            label: 'City',
            controller: _cityController,
            focusNode: _cityFocus,
            textInputAction: TextInputAction.next,
          ),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: _pillField(
            label: 'State',
            controller: _stateController,
            focusNode: _stateFocus,
            textInputAction: TextInputAction.next,
          ),
        ),
      ],
    );
  }

  Widget _buildCountryPincodeRow() {
    return Row(
      children: [
        Expanded(
          child: _pillField(
            label: 'Country',
            controller: _countryController,
            focusNode: _countryFocus,
            textInputAction: TextInputAction.next,
          ),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: _pillField(
            label: 'Pincode',
            controller: _pincodeController,
            focusNode: _pincodeFocus,
            textInputAction: TextInputAction.done,
            keyboardType: TextInputType.number,
          ),
        ),
      ],
    );
  }

  Widget _pillField({
    required String label,
    required TextEditingController controller,
    required FocusNode focusNode,
    required TextInputAction textInputAction,
    TextInputType? keyboardType,
  }) {
    return Container(
      height: 56.h,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(24.r),
      ),
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      alignment: Alignment.centerLeft,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        textInputAction: textInputAction,
        keyboardType: keyboardType,
        style: TextStyle(
          fontFamily: 'Outfit',
          fontSize: 14.sp,
          fontWeight: FontWeight.w400,
          color: const Color(0xFFF5F5F5),
        ),
        cursorColor: Colors.white,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: label,
          hintStyle: TextStyle(
            fontFamily: 'Outfit',
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
            color: Colors.white.withValues(alpha: 0.6),
          ),
          isCollapsed: true,
        ),
      ),
    );
  }

  Widget _buildContinueButton(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 24.h,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: SizedBox(
          width: double.infinity,
          height: 58.h,
          child: TextButton(
            onPressed: () {
              final pinCodeText = _pincodeController.text.trim();
              ref.read(onboardingDataProvider.notifier).state = ref
                  .read(onboardingDataProvider)
                  .copyWith(
                    streetAddress: _addressController.text.trim(),
                    city: _cityController.text.trim(),
                    state: _stateController.text.trim(),
                    country: _countryController.text.trim(),
                    pinCode: int.tryParse(pinCodeText) ?? 0,
                  );
              GoRouter.of(context).go('/talent-type');
            },
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(48.r),
              ),
              backgroundColor: Colors.transparent,
            ),
            child: Ink(
              decoration: BoxDecoration(
                gradient: AppColors.ctaGradient,
                borderRadius: BorderRadius.circular(48.r),
              ),
              child: Center(
                child: Text(
                  'Continue',
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFF5F5F5),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:geolocator/geolocator.dart';
import 'package:country_state_city/country_state_city.dart' as csc;

import '../../../core/widgets/common_background.dart';
import '../../../core/widgets/gradient_cta_button.dart';
import '../../../core/widgets/searchable_dropdown.dart';
import '../application/onboarding_data_provider.dart';
import '../application/profile_type_provider.dart';

class IndividualAddressScreen extends ConsumerStatefulWidget {
  const IndividualAddressScreen({super.key});

  @override
  ConsumerState<IndividualAddressScreen> createState() =>
      _IndividualAddressScreenState();
}

class _IndividualAddressScreenState
    extends ConsumerState<IndividualAddressScreen> {
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _pincodeController = TextEditingController();

  final FocusNode _addressFocus = FocusNode();
  final FocusNode _countryFocus = FocusNode();
  final FocusNode _pincodeFocus = FocusNode();

  List<csc.State> _indianStates = [];
  List<csc.City> _stateCities = [];
  csc.State? _selectedState;
  csc.City? _selectedCity;

  bool _showContinue = false;
  bool _isLoadingStates = true;
  bool _isFetchingLocation = false;
  double _latitude = 0.0;
  double _longitude = 0.0;

  String? _addressError;
  String? _pincodeError;

  // Indian PIN codes are 6 digits and never start with 0 (the leading
  // digit 1-9 maps to a postal region). This rejects non-Indian formats.
  static final _indianPinRegex = RegExp(r'^[1-9][0-9]{5}$');

  @override
  void initState() {
    super.initState();
    _countryController.text = 'India';
    _loadIndianStates();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _addressFocus.requestFocus();
    });
    _addressController.addListener(_onFieldsChanged);
    _countryController.addListener(_onFieldsChanged);
    _pincodeController.addListener(_onFieldsChanged);
  }

  Future<void> _loadIndianStates() async {
    try {
      final states = await csc.getStatesOfCountry('IN'); // India ISO code
      setState(() {
        _indianStates = states;
        _isLoadingStates = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingStates = false;
      });
    }
  }

  Future<void> _loadCitiesForState(String stateCode) async {
    try {
      final cities = await csc.getStateCities('IN', stateCode);
      setState(() {
        _stateCities = cities;
        _selectedCity = null; // Reset city when state changes
      });
      _onFieldsChanged();
    } catch (e) {
      setState(() {
        _stateCities = [];
        _selectedCity = null;
      });
    }
  }

  void _onFieldsChanged() {
    final addressText = _addressController.text.trim();
    final pincodeText = _pincodeController.text.trim();
    final countryText = _countryController.text.trim();

    final isAddressValid = addressText.length >= 10;
    final isPincodeValid = _indianPinRegex.hasMatch(pincodeText);
    final isStateValid = _selectedState != null;
    // Union territories may have no cities — treat as valid if state is selected
    final isCityValid = _selectedCity != null ||
        (_selectedState != null && _stateCities.isEmpty);
    final isCountryValid = countryText.isNotEmpty;

    final allFilled =
        isAddressValid &&
        isPincodeValid &&
        isStateValid &&
        isCityValid &&
        isCountryValid;

    setState(() {
      // Show address error only after user has started typing
      if (addressText.isNotEmpty && !isAddressValid) {
        _addressError = 'Address must be at least 10 characters';
      } else {
        _addressError = null;
      }

      // Show pincode error only after user has started typing
      if (pincodeText.isNotEmpty && !isPincodeValid) {
        _pincodeError = pincodeText.length < 6
            ? 'Pincode must be 6 digits'
            : 'Enter a valid Indian pincode';
      } else {
        _pincodeError = null;
      }

      _showContinue = allFilled;
    });
  }

  @override
  void dispose() {
    _addressController.dispose();
    _countryController.dispose();
    _pincodeController.dispose();
    _addressFocus.dispose();
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
                      if (_addressError != null) ...[
                        SizedBox(height: 6.h),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          child: Text(
                            _addressError!,
                            style: TextStyle(
                              fontFamily: 'Outfit',
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w400,
                              color: Colors.redAccent,
                            ),
                          ),
                        ),
                      ],
                      SizedBox(height: 16.h),
                      _buildStateCityRow(),
                      SizedBox(height: 16.h),
                      _buildCountryPincodeRow(),
                      if (_pincodeError != null) ...[
                        SizedBox(height: 6.h),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          child: Text(
                            _pincodeError!,
                            style: TextStyle(
                              fontFamily: 'Outfit',
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w400,
                              color: Colors.redAccent,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              if (_showContinue) _buildFetchLocationButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    ref.watch(profileTypeProvider);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () {
            if (context.canPop()) {
              GoRouter.of(context).pop();
            } else {
              context.go('/individual-email');
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

  Widget _buildStateCityRow() {
    return Row(
      children: [
        Expanded(
          child: SearchableDropdown<csc.State>(
            items: _indianStates,
            hint: _isLoadingStates ? 'Loading...' : 'State',
            enabled: !_isLoadingStates,
            labelOf: (state) => state.name,
            onSelected: (state) {
              setState(() => _selectedState = state);
              _loadCitiesForState(state.isoCode);
            },
          ),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: SearchableDropdown<csc.City>(
            // Rebuild fresh when the state changes so any stale typed
            // text (and the prior city) is cleared.
            key: ValueKey(_selectedState?.isoCode ?? ''),
            items: _stateCities,
            hint: 'City',
            enabled: _selectedState != null,
            labelOf: (city) => city.name,
            onSelected: (city) {
              setState(() => _selectedCity = city);
              _onFieldsChanged();
            },
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
            readOnly: true,
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
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(6),
            ],
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
    List<TextInputFormatter>? inputFormatters,
    bool readOnly = false,
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
        inputFormatters: inputFormatters,
        readOnly: readOnly,
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

  Future<void> _captureLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );

      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
      });
    } catch (e) {
      // Silently fail - location is optional
    }
  }

  Widget _buildFetchLocationButton(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 24.h,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: GradientCtaButton(
          label: _isFetchingLocation ? 'Fetching...' : 'Fetch my location',
          leading: _isFetchingLocation
              ? SizedBox(
                  width: 20.sp,
                  height: 20.sp,
                  child: const CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Image.asset('assets/location.png', width: 20.sp, height: 20.sp, color: Colors.white),
          width: double.infinity,
          height: 58,
          onPressed: _isFetchingLocation
              ? null
              : () async {
                  setState(() => _isFetchingLocation = true);

                  await _captureLocation();

                  final pinCodeText = _pincodeController.text.trim();
                  ref.read(onboardingDataProvider.notifier).state = ref
                      .read(onboardingDataProvider)
                      .copyWith(
                        streetAddress: _addressController.text.trim(),
                        city: _selectedCity?.name ??
                            _selectedState?.name ??
                            '',
                        state: _selectedState?.name ?? '',
                        country: 'India',
                        pinCode: int.tryParse(pinCodeText) ?? 0,
                        latitude: _latitude,
                        longitude: _longitude,
                      );

                  if (mounted) {
                    setState(() => _isFetchingLocation = false);
                    GoRouter.of(context).go('/talent-type');
                  }
                },
        ),
      ),
    );
  }
}

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:country_state_city/country_state_city.dart' as csc;
import 'package:geocoding/geocoding.dart';

import '../../../core/services/session_prefs.dart';
import '../../../core/services/session_state_provider.dart';
import '../../../core/widgets/common_background.dart';
import '../../../core/widgets/gradient_cta_button.dart';
import '../../../core/widgets/searchable_dropdown.dart';
import '../../subscription/presentation/subscription.dart';
import '../application/registration_providers.dart';
import '../domain/registration_models.dart';

/// Lightweight profile creation for users who want to call/chat without
/// going through the full creator onboarding. UI text stays generic — the
/// "hirer" concept is never surfaced to the user.
class HirerOnboardingScreen extends ConsumerStatefulWidget {
  const HirerOnboardingScreen({super.key});

  @override
  ConsumerState<HirerOnboardingScreen> createState() =>
      _HirerOnboardingScreenState();
}

class _HirerOnboardingScreenState extends ConsumerState<HirerOnboardingScreen> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();

  Map<String, dynamic>? _permanentAddress;
  Map<String, dynamic>? _venueAddress;
  bool _venueSameAsAddress = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _firstNameController.addListener(_onChanged);
    _lastNameController.addListener(_onChanged);
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  void _onChanged() => setState(() {});

  bool get _canSubmit {
    final firstOk = _firstNameController.text.trim().isNotEmpty;
    final lastOk = _lastNameController.text.trim().isNotEmpty;
    final permanentOk = _permanentAddress != null;
    final venueOk = _venueSameAsAddress || _venueAddress != null;
    return firstOk && lastOk && permanentOk && venueOk;
  }

  /// Builds the POST /v1/profile/details request body. Verified against
  /// the backend on 2026-05-19 (HTTP 201 "Resource created successfully").
  Future<Map<String, dynamic>> _buildRequestBody(String profileId) async {
    final first = _firstNameController.text.trim();
    final last = _lastNameController.text.trim();
    final nickName =
        '${first.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '')}'
        '${Random().nextInt(9000) + 1000}';

    final permanent = await _addressWithLocation(
      _permanentAddress!,
      AddressType.permanent,
    );
    final venueSource =
        _venueSameAsAddress ? _permanentAddress! : _venueAddress!;
    final venue = await _addressWithLocation(venueSource, AddressType.venue);

    return {
      'firstName': first,
      'lastName': last,
      'nickName': nickName,
      'profileType': ProfileType.hirer,
      'profileId': profileId,
      'address': [permanent, venue],
    };
  }

  /// Tags a structured address with its [type] and a geocoded location.
  Future<Map<String, dynamic>> _addressWithLocation(
    Map<String, dynamic> address,
    String type,
  ) async {
    return {
      ...address,
      'type': type,
      'location': await _geocode(address),
    };
  }

  /// Resolves a structured address to {latitude, longitude}. Falls back to
  /// {0,0} if the platform geocoder returns nothing or is unavailable.
  Future<Map<String, double>> _geocode(Map<String, dynamic> address) async {
    try {
      final query = [
        address['streetAddress'],
        address['city'],
        address['state'],
        address['country'],
      ]
          .map((e) => (e ?? '').toString().trim())
          .where((e) => e.isNotEmpty)
          .join(', ');
      final results = await locationFromAddress(query);
      if (results.isNotEmpty) {
        return {
          'latitude': results.first.latitude,
          'longitude': results.first.longitude,
        };
      }
    } catch (_) {
      // Geocoder unavailable / no match — fall through to the default.
    }
    return {'latitude': 0.0, 'longitude': 0.0};
  }

  Future<void> _submit() async {
    if (!_canSubmit || _isSubmitting) return;
    setState(() => _isSubmitting = true);
    final messenger = ScaffoldMessenger.of(context);

    try {
      final accessToken = await SessionPrefs.instance.getAccessToken();
      final profileId = await SessionPrefs.instance.getProfileId();
      debugPrint(
        'HirerOnboarding: submit profileId=$profileId '
        'tokenEmpty=${accessToken.isEmpty} tokenLen=${accessToken.length}',
      );
      if (accessToken.isEmpty || profileId.isEmpty) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Session expired. Please sign in again.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final body = await _buildRequestBody(profileId);
      debugPrint('HirerOnboarding: request body = $body');
      final response = await ref
          .read(registrationServiceProvider)
          .createProfileDetails(body, accessToken: accessToken);
      debugPrint('HirerOnboarding: response = $response');

      final status = response['status'] as int?;
      final message = (response['message'] as String? ?? '');
      final success = response['success'] as bool? ??
          (status == 200 || status == 201);

      // A duplicate-key error means a profile already exists on the
      // backend for this account — the user just needs a subscription,
      // so treat it like success and move on rather than blocking them.
      final alreadyExists =
          !success && message.toLowerCase().contains('duplicate');

      if (!success && !alreadyExists) {
        debugPrint(
          'HirerOnboarding: create FAILED — status=$status message=$message',
        );
        messenger.showSnackBar(
          const SnackBar(
            content: Text(
              "We couldn't create your profile. Please try again.",
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (alreadyExists) {
        debugPrint(
          'HirerOnboarding: profile already exists — proceeding to '
          'subscription',
        );
      }

      // Persist locally so the dashboard renders the profile section and
      // call/chat skips the form on subsequent attempts.
      await SessionPrefs.instance.mergeProfile({
        'firstName': body['firstName'],
        'lastName': body['lastName'],
        'nickName': body['nickName'],
        'profileType': ProfileType.hirer,
      });
      await ref.read(sessionStateProvider.notifier).refresh();

      if (!mounted) return;
      // Profile created — send straight to subscription purchase.
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const SubscriptionScreen()),
      );
    } catch (e, st) {
      debugPrint('HirerOnboarding: submit threw — $e');
      debugPrint('$st');
      messenger.showSnackBar(
        const SnackBar(
          content: Text(
            "We couldn't create your profile. Please try again.",
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: CommonBackground(
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 16.h),
                _buildTopBar(context),
                SizedBox(height: 24.h),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.only(bottom: 24.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _header(
                          'Create Your Profile',
                          'A few details so you can connect with talent.',
                        ),
                        SizedBox(height: 24.h),
                        _pillField('First name', _firstNameController),
                        SizedBox(height: 16.h),
                        _pillField('Last name', _lastNameController),
                        SizedBox(height: 24.h),
                        _sectionLabel('Address'),
                        SizedBox(height: 12.h),
                        _AddressSection(
                          onChanged: (data) =>
                              setState(() => _permanentAddress = data),
                        ),
                        SizedBox(height: 16.h),
                        _sameAsAddressCheckbox(),
                        if (!_venueSameAsAddress) ...[
                          SizedBox(height: 16.h),
                          _sectionLabel('Venue address'),
                          SizedBox(height: 12.h),
                          _AddressSection(
                            onChanged: (data) =>
                                setState(() => _venueAddress = data),
                          ),
                        ],
                        SizedBox(height: 24.h),
                        GradientCtaButton(
                          label: _isSubmitting ? 'Submitting...' : 'Submit',
                          width: double.infinity,
                          height: 58,
                          enabled: _canSubmit && !_isSubmitting,
                          onPressed:
                              (_canSubmit && !_isSubmitting) ? _submit : null,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (context.canPop()) {
          GoRouter.of(context).pop();
        } else {
          context.go('/landing');
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
    );
  }

  Widget _header(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontFamily: 'Neue',
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFFF5F5F5),
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          subtitle,
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

  Widget _sectionLabel(String label) {
    return Text(
      label,
      style: TextStyle(
        fontFamily: 'Neue',
        fontSize: 16.sp,
        fontWeight: FontWeight.w700,
        color: const Color(0xFFF5F5F5),
      ),
    );
  }

  Widget _pillField(
    String hint,
    TextEditingController controller, {
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
          isCollapsed: true,
          hintText: hint,
          hintStyle: TextStyle(
            fontFamily: 'Outfit',
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
            color: Colors.white.withValues(alpha: 0.6),
          ),
        ),
      ),
    );
  }

  Widget _sameAsAddressCheckbox() {
    return GestureDetector(
      onTap: () => setState(() {
        _venueSameAsAddress = !_venueSameAsAddress;
        if (_venueSameAsAddress) _venueAddress = null;
      }),
      child: Row(
        children: [
          Container(
            width: 22.w,
            height: 22.w,
            decoration: BoxDecoration(
              color: _venueSameAsAddress
                  ? const Color(0xFF8F39B2)
                  : Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(6.r),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.4),
              ),
            ),
            child: _venueSameAsAddress
                ? Icon(Icons.check, size: 16.sp, color: Colors.white)
                : null,
          ),
          SizedBox(width: 10.w),
          Text(
            'Venue address is same as address',
            style: TextStyle(
              fontFamily: 'Outfit',
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
              color: const Color(0xFFF5F5F5),
            ),
          ),
        ],
      ),
    );
  }
}

/// A structured address block (street + state + city + country + pincode).
/// Reports a complete address map via [onChanged], or null while incomplete.
class _AddressSection extends StatefulWidget {
  const _AddressSection({required this.onChanged});

  final void Function(Map<String, dynamic>? address) onChanged;

  @override
  State<_AddressSection> createState() => _AddressSectionState();
}

class _AddressSectionState extends State<_AddressSection> {
  final _streetController = TextEditingController();
  final _pincodeController = TextEditingController();

  List<csc.State> _states = [];
  List<csc.City> _cities = [];
  csc.State? _selectedState;
  csc.City? _selectedCity;
  bool _loadingStates = true;

  // Indian PIN codes are 6 digits and never start with 0 (the leading
  // digit 1-9 maps to a postal region). This rejects non-Indian formats.
  static final _indianPinRegex = RegExp(r'^[1-9][0-9]{5}$');

  @override
  void initState() {
    super.initState();
    _streetController.addListener(_report);
    _pincodeController.addListener(_report);
    _loadStates();
  }

  @override
  void dispose() {
    _streetController.dispose();
    _pincodeController.dispose();
    super.dispose();
  }

  Future<void> _loadStates() async {
    try {
      final states = await csc.getStatesOfCountry('IN');
      if (!mounted) return;
      setState(() {
        _states = states;
        _loadingStates = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loadingStates = false);
    }
  }

  Future<void> _loadCities(String stateCode) async {
    try {
      final cities = await csc.getStateCities('IN', stateCode);
      if (!mounted) return;
      setState(() {
        _cities = cities;
        _selectedCity = null;
      });
      _report();
    } catch (_) {
      if (mounted) {
        setState(() {
          _cities = [];
          _selectedCity = null;
        });
      }
    }
  }

  void _report() {
    final street = _streetController.text.trim();
    final pincode = _pincodeController.text.trim();
    final pinValid = _indianPinRegex.hasMatch(pincode);
    final stateValid = _selectedState != null;
    // Union territories may have no cities — valid once state is chosen.
    final cityValid =
        _selectedCity != null || (stateValid && _cities.isEmpty);

    if (street.length >= 5 && pinValid && stateValid && cityValid) {
      widget.onChanged({
        'streetAddress': street,
        'city': _selectedCity?.name ?? _selectedState?.name ?? '',
        'state': _selectedState?.name ?? '',
        'pinCode': int.parse(pincode),
        'country': 'India',
      });
    } else {
      widget.onChanged(null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _streetField(),
        SizedBox(height: 12.h),
        Row(
          children: [
            Expanded(child: _stateDropdown()),
            SizedBox(width: 12.w),
            Expanded(child: _cityDropdown()),
          ],
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            Expanded(child: _countryField()),
            SizedBox(width: 12.w),
            Expanded(child: _pincodeField()),
          ],
        ),
      ],
    );
  }

  BoxDecoration get _pillDecoration => BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(24.r),
      );

  TextStyle get _valueStyle => TextStyle(
        fontFamily: 'Outfit',
        fontSize: 14.sp,
        fontWeight: FontWeight.w400,
        color: const Color(0xFFF5F5F5),
      );

  TextStyle get _hintStyle => TextStyle(
        fontFamily: 'Outfit',
        fontSize: 14.sp,
        fontWeight: FontWeight.w400,
        color: Colors.white.withValues(alpha: 0.6),
      );

  Widget _streetField() {
    return Container(
      decoration: _pillDecoration,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: TextField(
        controller: _streetController,
        maxLines: null,
        minLines: 2,
        keyboardType: TextInputType.streetAddress,
        style: _valueStyle,
        cursorColor: Colors.white,
        inputFormatters: [LengthLimitingTextInputFormatter(200)],
        decoration: InputDecoration(
          border: InputBorder.none,
          isCollapsed: true,
          hintText: 'Street address',
          hintStyle: _hintStyle,
        ),
      ),
    );
  }

  Widget _stateDropdown() {
    return SearchableDropdown<csc.State>(
      items: _states,
      hint: _loadingStates ? 'Loading...' : 'State',
      enabled: !_loadingStates,
      labelOf: (s) => s.name,
      onSelected: (s) {
        setState(() => _selectedState = s);
        _loadCities(s.isoCode);
      },
    );
  }

  Widget _cityDropdown() {
    return SearchableDropdown<csc.City>(
      // Rebuild fresh when the state changes so any stale typed text
      // (and the prior city) is cleared.
      key: ValueKey(_selectedState?.isoCode ?? ''),
      items: _cities,
      hint: 'City',
      enabled: _selectedState != null,
      labelOf: (c) => c.name,
      onSelected: (c) {
        setState(() => _selectedCity = c);
        _report();
      },
    );
  }

  Widget _countryField() {
    return Container(
      height: 56.h,
      decoration: _pillDecoration,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      alignment: Alignment.centerLeft,
      child: Text('India', style: _valueStyle),
    );
  }

  Widget _pincodeField() {
    return Container(
      height: 56.h,
      decoration: _pillDecoration,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      alignment: Alignment.centerLeft,
      child: TextField(
        controller: _pincodeController,
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(6),
        ],
        style: _valueStyle,
        cursorColor: Colors.white,
        decoration: InputDecoration(
          border: InputBorder.none,
          isCollapsed: true,
          hintText: 'Pincode',
          hintStyle: _hintStyle,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:country_state_city/country_state_city.dart' as csc;

import '../../../../core/widgets/custom_text.dart';
import '../../../../core/widgets/gradient_cta_button.dart';
import '../../../../core/widgets/voice_search_mic_button.dart';
import '../../../../core/services/session_prefs.dart';

class SelectLocationScreen extends StatefulWidget {
  const SelectLocationScreen({super.key});

  @override
  State<SelectLocationScreen> createState() => _SelectLocationScreenState();
}

class _SelectLocationScreenState extends State<SelectLocationScreen> {
  final TextEditingController _searchController = TextEditingController();
  final List<csc.State> _indianStates = [];
  final List<csc.City> _stateCities = [];
  final List<String> _recentSearches = [];
  csc.State? _selectedState;
  String _searchQuery = '';
  bool _isLoadingStates = true;
  bool _isLoadingCities = false;
  String? _loadingStateName;
  bool _isDetectingLocation = false;

  @override
  void initState() {
    super.initState();
    _loadIndianStates();
    _loadRecentSearches();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadIndianStates() async {
    try {
      final states = await csc.getStatesOfCountry('IN');
      if (!mounted) return;
      setState(() {
        _indianStates
          ..clear()
          ..addAll(states);
        _isLoadingStates = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoadingStates = false;
      });
    }
  }

  Future<void> _loadCitiesForState(csc.State state) async {
    setState(() {
      _loadingStateName = state.name;
      _isLoadingCities = true;
      _searchController.clear();
      _searchQuery = '';
    });

    try {
      final cities = await csc.getStateCities('IN', state.isoCode);
      if (!mounted) return;
      setState(() {
        _selectedState = state;
        _stateCities
          ..clear()
          ..addAll(cities);
        _isLoadingCities = false;
        _loadingStateName = null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _selectedState = state;
        _stateCities.clear();
        _isLoadingCities = false;
        _loadingStateName = null;
      });
    }
  }

  Future<void> _loadRecentSearches() async {
    final recent = await SessionPrefs.instance.getDashboardRecentLocations();
    if (!mounted) return;
    setState(() {
      _recentSearches
        ..clear()
        ..addAll(recent);
    });
  }

  Future<void> _saveRecentSearch(String city) async {
    await SessionPrefs.instance.addDashboardRecentLocation(city);
    if (!mounted) return;
    await _loadRecentSearches();
  }

  void _clearSelection() {
    setState(() {
      _selectedState = null;
      _stateCities.clear();
      _searchController.clear();
      _searchQuery = '';
    });
  }

  void _filterStates(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  /// Build a grouped alphabetic list of items (states or cities).
  List<Widget> _buildGroupedList(
    List<String> names,
    void Function(String) onTap,
  ) {
    // Sort and group by first letter
    names.sort((a, b) => a.compareTo(b));
    final Map<String, List<String>> grouped = {};
    for (final name in names) {
      final letter = name[0].toUpperCase();
      grouped.putIfAbsent(letter, () => []).add(name);
    }

    final widgets = <Widget>[];
    for (final entry in grouped.entries) {
      // Letter header
      widgets.add(
        Padding(
          padding: EdgeInsets.only(top: 16.h, bottom: 8.h),
          child: CustomText(
            entry.key,
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            fontFamily: 'Neue',
            color: Colors.white,
          ),
        ),
      );
      // All items under this letter in a single container
      widgets.add(
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (int i = 0; i < entry.value.length; i++) ...[
                GestureDetector(
                  onTap: _loadingStateName != null
                      ? null
                      : () => onTap(entry.value[i]),
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 20.w,
                      vertical: 16.h,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: CustomText(
                            entry.value[i],
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w400,
                            fontFamily: 'Outfit',
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                        if (_loadingStateName == entry.value[i])
                          SizedBox(
                            width: 16.w,
                            height: 16.w,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    }
    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    // Prefix match (not contains) so the search is alphabetical: typing
    // "U" surfaces names that START with "U" — the "U list" — instead of
    // every name containing a "u" somewhere, scattered across groups.
    final query = _searchQuery.toLowerCase().trim();
    final filteredStates = _indianStates
        .where((state) => state.name.toLowerCase().startsWith(query))
        .toList();
    final filteredCities = _stateCities
        .where((city) => city.name.toLowerCase().startsWith(query))
        .toList();

    // Build the grouped list items
    final List<String> displayNames = _selectedState == null
        ? filteredStates.map((s) => s.name).toList()
        : filteredCities.map((c) => c.name).toList();

    final groupedWidgets = _buildGroupedList(displayNames, (name) {
      if (_selectedState == null) {
        // Tapped a state — load cities
        final state = _indianStates.firstWhere((s) => s.name == name);
        _loadCitiesForState(state);
      } else {
        // Tapped a city — save & return
        _saveRecentSearch(name);
        Navigator.pop(context, name);
      }
    });

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF4A148C), Color(0xFF121212), Color(0xFF000000)],
            stops: [0.0, 0.3, 1.0],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  // 1. Glassy top section (Header + Search)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                    child: Column(
                      children: [
                        _buildHeader(),
                        _buildSearchBar(),
                        SizedBox(height: 8.h),
                      ],
                    ),
                  ),

                  if (_selectedState == null && _recentSearches.isNotEmpty) ...[
                    SizedBox(height: 12.h),
                    _buildRecentSearchesSection(),
                  ],

                  // 3. Grouped Alphabetic List
                  Expanded(
                    child: (_isLoadingStates || _isLoadingCities)
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          )
                        : ListView(
                            padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 100.h),
                            children: groupedWidgets,
                          ),
                  ),
                ],
              ),

              // 4. Floating "Detect Live Location" Button
              Positioned(
                bottom: 30.h,
                left: 20.w,
                right: 20.w,
                child: _buildDetectLocationButton(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentSearchesSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomText(
                'Recent Searches',
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
              const Spacer(),
              TextButton(
                onPressed: () async {
                  await SessionPrefs.instance.clearDashboardRecentLocations();
                  if (!mounted) return;
                  setState(() => _recentSearches.clear());
                },
                child: Text(
                  'Clear All',
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.75),
                  ),
                ),
              ),
            ],
          ),

          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: _recentSearches.map((city) {
              return GestureDetector(
                onTap: () async {
                  await _saveRecentSearch(city);
                  if (!mounted) return;
                  Navigator.pop(context, city);
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 10.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(22.r),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.16),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.history,
                        size: 14.sp,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                      SizedBox(width: 6.w),
                      CustomText(
                        city,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          SizedBox(height: 10.h),
        ],
      ),
    );
  }

  // --- Widgets ---

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 12.h),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              if (_selectedState != null) {
                _clearSelection();
                return;
              }
              Navigator.pop(context);
            },
            child: Container(
              width: 44.w,
              height: 44.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.15),
              ),
              child: Center(
                child: Image.asset(
                  'assets/images/arrow-left.png',
                  color: Colors.white,
                  width: 20.sp,
                  height: 20.sp,
                ),
              ),
            ),
          ),
          SizedBox(width: 16.w),
          CustomText(
            'Select Location',
            fontSize: 22.sp,
            fontWeight: FontWeight.w700,
            fontFamily: 'Neue',
            color: Colors.white,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      child: Container(
        height: 50.h,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(25.r),
        ),
        child: TextField(
          controller: _searchController,
          onChanged: _filterStates,
          style: TextStyle(
            color: Colors.white,
            fontSize: 14.sp,
            fontFamily: 'Outfit',
          ),
          decoration: InputDecoration(
            prefixIcon: Padding(
              padding: EdgeInsets.all(14.w),
              child: Image.asset(
                'assets/search.png',
                width: 20.sp,
                height: 20.sp,
                color: Colors.white70,
              ),
            ),
            suffixIcon: Padding(
              padding: EdgeInsets.only(right: 14.w),
              child: VoiceSearchMicButton(
                controller: _searchController,
                iconColor: Colors.white70,
                size: 22,
                onFinalResult: _filterStates,
              ),
            ),
            suffixIconConstraints: BoxConstraints(
              minWidth: 36.w,
              minHeight: 36.w,
            ),
            hintText: _selectedState == null
                ? 'Search your state....'
                : 'Search city....',
            hintStyle: TextStyle(color: Colors.white54, fontSize: 14.sp),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 14.h),
          ),
        ),
      ),
    );
  }

  Widget _buildDetectLocationButton() {
    return GradientCtaButton(
      label: _isDetectingLocation ? 'Detecting...' : 'Detect Live Location',
      width: double.infinity,
      height: 56,
      borderRadius: BorderRadius.circular(48.r),
      enabled: !_isDetectingLocation,
      onPressed: _isDetectingLocation
          ? null
          : () async {
              setState(() => _isDetectingLocation = true);

              final city = await _detectLiveCity();
              if (!mounted) return;

              setState(() => _isDetectingLocation = false);

              if (city.isNotEmpty) {
                Navigator.pop(context, city);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Could not detect your live city'),
                  ),
                );
              }
            },
    );
  }

  Future<String> _detectLiveCity() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return '';

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return '';
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );

      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (placemarks.isEmpty) return '';

      final placemark = placemarks.first;
      return placemark.locality?.trim() ??
          placemark.subLocality?.trim() ??
          placemark.administrativeArea?.trim() ??
          '';
    } catch (_) {
      return '';
    }
  }
}

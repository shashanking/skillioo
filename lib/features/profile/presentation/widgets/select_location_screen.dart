import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/widgets/custom_text.dart';

class SelectLocationScreen extends StatefulWidget {
  const SelectLocationScreen({super.key});

  @override
  State<SelectLocationScreen> createState() => _SelectLocationScreenState();
}

class _SelectLocationScreenState extends State<SelectLocationScreen> {
  final TextEditingController _searchController = TextEditingController();

  // Full list of Indian States and UTs
  final List<String> _allStates = [
    'Andhra Pradesh',
    'Arunachal Pradesh',
    'Assam',
    'Andaman and Nicobar Islands',
    'Bihar',
    'Chhattisgarh',
    'Chandigarh',
    'Delhi',
    'Dadra and Nagar Haveli and Daman and Diu',
    'Goa',
    'Gujarat',
    'Haryana',
    'Himachal Pradesh',
    'Jammu and Kashmir',
    'Jharkhand',
    'Karnataka',
    'Kerala',
    'Ladakh',
    'Lakshadweep',
    'Madhya Pradesh',
    'Maharashtra',
    'Manipur',
    'Meghalaya',
    'Mizoram',
    'Nagaland',
    'Odisha',
    'Punjab',
    'Puducherry',
    'Rajasthan',
    'Sikkim',
    'Tamil Nadu',
    'Telangana',
    'Tripura',
    'Uttar Pradesh',
    'Uttarakhand',
    'West Bengal',
  ];

  List<String> _filteredStates = [];

  @override
  void initState() {
    super.initState();
    _filteredStates = List.from(_allStates);
  }

  void _filterStates(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredStates = List.from(_allStates);
      } else {
        _filteredStates = _allStates
            .where((state) => state.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  // Helper to Group States by First Letter
  Map<String, List<String>> _groupStates(List<String> states) {
    states.sort(); // Ensure alphabetical order
    Map<String, List<String>> grouped = {};
    for (var state in states) {
      String firstLetter = state[0].toUpperCase();
      if (!grouped.containsKey(firstLetter)) {
        grouped[firstLetter] = [];
      }
      grouped[firstLetter]!.add(state);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final groupedStates = _groupStates(_filteredStates);

    return Scaffold(
      resizeToAvoidBottomInset: false, // Prevent floating button overlap
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF4A148C), // Deep Purple Top
              Color(0xFF121212), // Dark Middle
              Color(0xFF000000), // Black Bottom
            ],
            stops: [0.0, 0.3, 1.0],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  // 1. Header
                  _buildHeader(),

                  // 2. Search Bar
                  _buildSearchBar(),

                  // 3. Grouped List
                  Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 100.h),
                      itemCount: groupedStates.keys.length,
                      itemBuilder: (context, index) {
                        String letter = groupedStates.keys.elementAt(index);
                        List<String> statesInGroup = groupedStates[letter]!;
                        return _buildGroupSection(letter, statesInGroup);
                      },
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

  // --- Widgets ---

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 44.w,
              height: 44.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.15),
              ),
              child: Icon(Icons.arrow_back, color: Colors.white, size: 20.sp),
            ),
          ),
          SizedBox(width: 16.w),
          CustomText(
            'Select Location',
            fontSize: 22.sp,
            fontWeight: FontWeight.w700,
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
            fontFamily: 'Inter', // Ensure your font matches
          ),
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.search, color: Colors.white70, size: 22.sp),
            suffixIcon: Icon(
              Icons.mic_none,
              color: Colors.white70,
              size: 22.sp,
            ),
            hintText: 'Search your state....',
            hintStyle: TextStyle(color: Colors.white54, fontSize: 14.sp),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 14.h),
          ),
        ),
      ),
    );
  }

  Widget _buildGroupSection(String letter, List<String> states) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // The Letter Header (A, B, C...)
        Padding(
          padding: EdgeInsets.only(top: 20.h, bottom: 10.h, left: 4.w),
          child: CustomText(
            letter,
            fontSize: 20.sp,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),

        // The Container holding the list of states for this letter
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(
              0xFF1E1E2C,
            ).withValues(alpha: 0.6), // Dark glassy bg
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Column(
            children: List.generate(states.length, (index) {
              return _buildStateItem(
                states[index],
                isLast: index == states.length - 1,
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildStateItem(String stateName, {bool isLast = false}) {
    return InkWell(
      onTap: () {
        // Handle Selection
        debugPrint("Selected: $stateName");
        Navigator.pop(context, stateName);
      },
      borderRadius: BorderRadius.circular(20.r), // Match container radius
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        child: Row(
          children: [
            Expanded(
              child: CustomText(
                stateName,
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: Colors.white.withValues(alpha: 0.9),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetectLocationButton() {
    return Container(
      height: 56.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28.r),
        // Dark gradient similar to the image button
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF2C3E50), // Dark Blue-ish top
            Color(0xFF4A148C), // Purple bottom
          ],
        ),
        border: Border.all(
          color: const Color(0xFF05DAF1).withValues(alpha: 0.3), // Cyan glow
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF05DAF1).withValues(alpha: 0.1),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // Logic to get live location would go here
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Detecting Live Location...")),
            );
          },
          borderRadius: BorderRadius.circular(28.r),
          child: Center(
            child: CustomText(
              'Detect Live Location',
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

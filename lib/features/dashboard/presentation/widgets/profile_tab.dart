import 'package:flutter/material.dart';

import 'profile_cards.dart';
import 'profile_dropdown.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  ProfileTabState createState() => ProfileTabState();
}

class ProfileTabState extends State<ProfileTab> {
  ProfileType? _selectedProfileType;

  void updateProfileType(ProfileType? type) {
    setState(() {
      _selectedProfileType = type;
    });
  }

  List<ProfileCardData> get _allCards => [
    ProfileCardData(
      name: 'Alex Johnson',
      role: 'UI/UX Designer',
      imagePath: 'assets/images/professional-profile.jpg',
      followers: '12.5K',
      posts: '48',
      isProfessional: true,
      following: '23K',
      views: '2M',
      socialFollowers: '312K',
      isOnline: true,
    ),
    ProfileCardData(
      name: 'Sarah Williams',
      role: 'Photographer',
      imagePath: 'assets/images/skilled-profile.jpg',
      followers: '8.2K',
      posts: '126',
      isProfessional: false,
      following: '23K',
      views: '2M',
      socialFollowers: '312K',
      isOnline: true,
    ),
    ProfileCardData(
      name: 'Mike Chen',
      role: 'Video Editor',
      imagePath: 'assets/images/profile-img-1.jpg',
      followers: '15.7K',
      posts: '89',
      isProfessional: true,
      following: '23K',
      views: '2M',
      socialFollowers: '312K',
    ),
    ProfileCardData(
      name: 'Emma Davis',
      role: 'Content Creator',
      imagePath: 'assets/images/profile-img-1.jpg',
      followers: '6.8K',
      posts: '234',
      isProfessional: false,
      following: '23K',
      views: '2M',
      socialFollowers: '312K',
    ),
    ProfileCardData(
      name: 'James Wilson',
      role: 'Brand Designer',
      imagePath: 'assets/professional.jpg',
      followers: '9.3K',
      posts: '67',
      isProfessional: true,
      following: '23K',
      views: '2M',
      socialFollowers: '312K',
    ),
  ];

  List<ProfileCardData> get _filteredCards {
    if (_selectedProfileType == null) {
      return _allCards; // Show all when "Profile" is selected
    }

    return _allCards.where((card) {
      switch (_selectedProfileType) {
        case ProfileType.professional:
          return card.isProfessional;
        case ProfileType.skilled:
          return !card.isProfessional;
        case null:
          return true; // Show all cards
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return ProfileCardGrid(cards: _filteredCards);
  }
}

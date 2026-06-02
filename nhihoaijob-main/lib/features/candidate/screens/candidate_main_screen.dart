import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';
import 'package:easy_localization/easy_localization.dart'; // Đã thêm
import 'package:tuanhoai01/features/candidate/screens/candidate_home_screen.dart';
import 'package:tuanhoai01/features/candidate/screens/job_search_screen.dart';
import 'package:tuanhoai01/features/notification/screens/notification_screen.dart';
import 'package:tuanhoai01/features/candidate/screens/candidate_profile_screen.dart';

class CandidateMainScreen extends StatefulWidget {
  const CandidateMainScreen({super.key});

  @override
  State<CandidateMainScreen> createState() => _CandidateMainScreenState();
}

class _CandidateMainScreenState extends State<CandidateMainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const CandidateHomeScreen(),
    const JobSearchScreen(),
    const NotificationScreen(),
    const CandidateProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    const Color zaloBlue = Color(0xFFE24C33);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FA),
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            currentIndex: _selectedIndex,
            selectedItemColor: zaloBlue,
            unselectedItemColor: Colors.grey.shade400,
            selectedFontSize: 12,
            unselectedFontSize: 12,
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
            onTap: _onItemTapped,
            items: [
              BottomNavigationBarItem(
                icon: const Padding(padding: EdgeInsets.only(bottom: 4.0), child: Icon(Remix.home_smile_line, size: 24)),
                activeIcon: const Padding(padding: EdgeInsets.only(bottom: 4.0), child: Icon(Remix.home_smile_fill, size: 24)),
                label: 'nav.home'.tr(),
              ),
              BottomNavigationBarItem(
                icon: const Padding(padding: EdgeInsets.only(bottom: 4.0), child: Icon(Remix.search_eye_line, size: 24)),
                activeIcon: const Padding(padding: EdgeInsets.only(bottom: 4.0), child: Icon(Remix.search_eye_fill, size: 24)),
                label: 'nav.jobs'.tr(),
              ),
              BottomNavigationBarItem(
                icon: const Padding(padding: EdgeInsets.only(bottom: 4.0), child: Icon(Remix.notification_3_line, size: 24)),
                activeIcon: const Padding(padding: EdgeInsets.only(bottom: 4.0), child: Icon(Remix.notification_3_fill, size: 24)),
                label: 'nav.notifications'.tr(),
              ),
              BottomNavigationBarItem(
                icon: const Padding(padding: EdgeInsets.only(bottom: 4.0), child: Icon(Remix.user_3_line, size: 24)),
                activeIcon: const Padding(padding: EdgeInsets.only(bottom: 4.0), child: Icon(Remix.user_3_fill, size: 24)),
                label: 'nav.profile'.tr(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
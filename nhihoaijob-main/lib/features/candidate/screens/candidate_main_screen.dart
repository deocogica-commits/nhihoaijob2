

import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';

// Import toàn bộ 4 màn hình của thanh điều hướng
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
  // Biến lưu trữ chỉ mục (index) của tab đang được chọn. Mặc định là 0 (Trang chủ)
  int _selectedIndex = 0;

  // Danh sách các màn hình con tương ứng với từng tab (Đã được liên kết file thật 100%)
  final List<Widget> _pages = [
    const CandidateHomeScreen(),        // Tab 0: Trang chủ Candidate
    const JobSearchScreen(),            // Tab 1: Tìm kiếm việc làm
    const NotificationScreen(),         // Tab 2: Thông báo
    const CandidateProfileScreen(),     // Tab 3: Hồ sơ cá nhân
  ];

  // Hàm xử lý khi người dùng chạm vào một tab ở dưới cùng
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    const Color zaloBlue = Color(0xFFE24C33);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FA), // Màu nền tổng thể hơi xám xanh nhạt

      // Nội dung chính hiển thị dựa theo tab được chọn
      body: _pages[_selectedIndex],

      // Thanh điều hướng bên dưới
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05), // Đổ bóng nhẹ lên trên để tạo chiều sâu
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        // ClipRRect giúp bo góc cho BottomNavigationBar tạo cảm giác hiện đại
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed, // Cố định các tab, không bị hiệu ứng trượt đẩy nhau
            backgroundColor: Colors.white,
            currentIndex: _selectedIndex,
            selectedItemColor: zaloBlue, // Màu khi tab được chọn
            unselectedItemColor: Colors.grey.shade400, // Màu khi tab không được chọn
            selectedFontSize: 12,
            unselectedFontSize: 12,
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
            onTap: _onItemTapped, // Gọi hàm chuyển tab

            // Danh sách các icon của tab
            items: const [
              BottomNavigationBarItem(
                icon: Padding(
                  padding: EdgeInsets.only(bottom: 4.0),
                  child: Icon(Remix.home_smile_line, size: 24),
                ),
                activeIcon: Padding(
                  padding: EdgeInsets.only(bottom: 4.0),
                  child: Icon(Remix.home_smile_fill, size: 24),
                ),
                label: 'Trang chủ',
              ),
              BottomNavigationBarItem(
                icon: Padding(
                  padding: EdgeInsets.only(bottom: 4.0),
                  child: Icon(Remix.search_eye_line, size: 24),
                ),
                activeIcon: Padding(
                  padding: EdgeInsets.only(bottom: 4.0),
                  child: Icon(Remix.search_eye_fill, size: 24),
                ),
                label: 'Việc làm',
              ),
              BottomNavigationBarItem(
                icon: Padding(
                  padding: EdgeInsets.only(bottom: 4.0),
                  child: Icon(Remix.notification_3_line, size: 24),
                ),
                activeIcon: Padding(
                  padding: EdgeInsets.only(bottom: 4.0),
                  child: Icon(Remix.notification_3_fill, size: 24),
                ),
                label: 'Thông báo',
              ),
              BottomNavigationBarItem(
                icon: Padding(
                  padding: EdgeInsets.only(bottom: 4.0),
                  child: Icon(Remix.user_3_line, size: 24),
                ),
                activeIcon: Padding(
                  padding: EdgeInsets.only(bottom: 4.0),
                  child: Icon(Remix.user_3_fill, size: 24),
                ),
                label: 'Hồ sơ',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
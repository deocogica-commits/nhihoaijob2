

import 'package:flutter/material.dart';
import 'package:tuanhoai01/features/auth/screens/register_screen.dart';
import 'package:remixicon/remixicon.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _pages = [
    {
      'icon': Remix.briefcase_line, // Đổi icon briefcase cho trang đầu (job search)
      'title': " NH.JOB TÌM VIỆC TAIWAN",
      'description': "ỨNG DỤNG VIỆT DÀNH CHO NGƯỜI VIỆT.",
    },
    {
      'icon': Remix.rocket_2_line, // Giữ nguyên icon rocket (career boost)
      'title': "TÌM VIỆC CHO SINH VIÊN ",
      'description': "ĐÃ TỐT NGHIỆP VÀ CHƯA TỐT NGHIỆP.",
    },
    {
      'icon': Remix.community_line, // Giữ nguyên icon community (network)
      'title': "TÌM ĐƠN HÀNG XKLD VÀ CHUYỂN CHỦ",
      'description': "NHIỀU ĐƠN HÀNG TỐT ĐANG ĐỢI BẠN.",
    },
  ];

  @override
  Widget build(BuildContext context) {
    const Color zaloBlue = Color(0xFFE24C33);
    const Color ultraFadedShapeColor = Color(0x0D0068FF);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            // --- BACKGROUND SHAPES ---
            Positioned(
              top: -120,
              left: -100,
              child: Container(
                width: 350,
                height: 350,
                decoration: const BoxDecoration(
                  color: ultraFadedShapeColor,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              bottom: -80,
              right: -60,
              child: Transform.rotate(
                angle: 0.15,
                child: Container(
                  width: 280,
                  height: 280,
                  decoration: BoxDecoration(
                    color: ultraFadedShapeColor,
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 120,
              right: 180,
              child: Container(
                width: 120,
                height: 120,
                decoration: const BoxDecoration(
                  color: ultraFadedShapeColor,
                  shape: BoxShape.circle,
                ),
              ),
            ),

            // --- NỘI DUNG CHÍNH (SLIDER) ---
            PageView.builder(
              controller: _controller,
              itemCount: _pages.length,
              onPageChanged: (int page) {
                setState(() => _currentPage = page);
              },
              itemBuilder: (context, index) {
                return _buildPage(
                  icon: _pages[index]['icon'],
                  title: _pages[index]['title'],
                  description: _pages[index]['description'],
                );
              },
            ),

            // --- DẤU CHẤM CHỈ BÁO (PAGE INDICATORS) ---
            Positioned(
              bottom: 120, // Đẩy lên để chừa không gian thoáng cho nút
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _pages.length,
                      (index) => _buildIndicator(index, zaloBlue),
                ),
              ),
            ),

            // --- CỤM NÚT ĐIỀU HƯỚNG BÊN DƯỚI CÙNG ---
            Positioned(
              bottom: 40, // Căn lề dưới 40px
              left: 24,   // Căn lề trái/phải 24px chuẩn mobile
              right: 24,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _currentPage == 0
                // TRANG 1: Một nút tràn viền
                    ? SizedBox(
                  key: const ValueKey('button_full'),
                  width: double.infinity,
                  height: 48, // Hạ chiều cao xuống 48 cho thanh thoát
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: zaloBlue,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)), // Bo góc theo chiều cao mới
                      elevation: 0,
                    ),
                    onPressed: () {
                      _controller.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text(
                          'TIẾP THEO',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        SizedBox(width: 4),
                        Icon(Remix.arrow_right_s_line, size: 20, color: Colors.white),
                      ],
                    ),
                  ),
                )
                // TRANG 2 & 3: Chia đôi 2 nút đều nhau
                    : Row(
                  key: const ValueKey('button_split'),
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 48, // Hạ chiều cao xuống 48
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: zaloBlue, width: 1.2), // Viền mỏng lại nhìn cho sang
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                            backgroundColor: Colors.white,
                          ),
                          onPressed: () {
                            _controller.previousPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          },
                          child: const Text(
                            'QUAY LẠI',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: zaloBlue),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16), // Khoảng cách giữa 2 nút chuẩn 16px
                    Expanded(
                      child: SizedBox(
                        height: 48, // Hạ chiều cao xuống 48
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: zaloBlue,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                            elevation: 0,
                          ),
                          onPressed: () {
                            if (_currentPage == _pages.length - 1) {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => const RegisterScreen()),
                              );
                            } else {
                              _controller.nextPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            }
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _currentPage == _pages.length - 1 ? 'BẮT ĐẦU NGAY' : 'TIẾP THEO',
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                              if (_currentPage != _pages.length - 1)
                                const Padding(
                                  padding: EdgeInsets.only(left: 4.0),
                                  child: Icon(Remix.arrow_right_s_line, size: 20, color: Colors.white),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Căn chỉnh lại padding cho text để chữ thở hơn, không bị dồn ứ
  Widget _buildPage({required IconData icon, required String title, required String description}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0), // Nới lỏng lề trái phải cho đoạn text
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 90, color: const Color(0xFFE24C33)),
          const SizedBox(height: 45),
          Text(
            title,
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.black87),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 18),
          Text(
            description,
            style: const TextStyle(fontSize: 16, color: Color(0xFF666666), height: 1.5),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 60), // Đẩy phần nội dung nhích lên một chút cho cách xa cụm nút
        ],
      ),
    );
  }

  Widget _buildIndicator(int index, Color color) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.symmetric(horizontal: 6),
      height: 10, // Chỉnh gọn lại một chút cho thanh thoát
      width: _currentPage == index ? 26 : 10,
      decoration: BoxDecoration(
        color: _currentPage == index ? color : const Color(0xFFE0E0E0), // Làm màu xám nhạt đi chút cho tinh tế
        borderRadius: BorderRadius.circular(5),
      ),
    );
  }
}
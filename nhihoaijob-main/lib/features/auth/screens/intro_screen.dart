import 'package:flutter/material.dart';
import 'package:tuanhoai01/features/auth/screens/register_screen.dart';
import 'package:remixicon/remixicon.dart';
import 'package:easy_localization/easy_localization.dart';

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
      'icon': Remix.briefcase_line,
      'title': "intro.title1",
      'description': "intro.desc1",
    },
    {
      'icon': Remix.rocket_2_line,
      'title': "intro.title2",
      'description': "intro.desc2",
    },
    {
      'icon': Remix.community_line,
      'title': "intro.title3",
      'description': "intro.desc3",
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
                  title: _pages[index]['title'].toString().tr(),
                  description: _pages[index]['description'].toString().tr(),
                );
              },
            ),

            // --- DẤU CHẤM CHỈ BÁO ---
            Positioned(
              bottom: 120,
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

            // --- CỤM NÚT ĐIỀU HƯỚNG ---
            Positioned(
              bottom: 40,
              left: 24,
              right: 24,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _currentPage == 0
                    ? SizedBox(
                        key: const ValueKey('button_full'),
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: zaloBlue,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
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
                            children: [
                              Text(
                                'intro.next'.tr(),
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Remix.arrow_right_s_line, size: 20, color: Colors.white),
                            ],
                          ),
                        ),
                      )
                    : Row(
                        key: const ValueKey('button_split'),
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 48,
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: zaloBlue, width: 1.2),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                                  backgroundColor: Colors.white,
                                ),
                                onPressed: () {
                                  _controller.previousPage(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                  );
                                },
                                child: Text(
                                  'intro.back'.tr(),
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: zaloBlue),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: SizedBox(
                              height: 48,
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
                                      _currentPage == _pages.length - 1 ? 'intro.start'.tr() : 'intro.next'.tr(),
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

            // --- NÚT CHUYỂN NGÔN NGỮ (ĐÃ ĐƯA XUỐNG DƯỚI ĐỂ NẰM LỚP TRÊN CÙNG) ---
           // --- NÚT CHUYỂN NGÔN NGỮ ---
Positioned(
  top: 10,
  right: 10,
  child: IconButton(
    icon: const Icon(Icons.language, color: Color(0xFFE24C33), size: 28), // Đảm bảo dùng màu đúng
    onPressed: () {
      Locale currentLocale = context.locale;
      if (currentLocale == const Locale('vi', 'VN')) {
        context.setLocale(const Locale('zh', 'TW'));
      } else if (currentLocale == const Locale('zh', 'TW')) {
        context.setLocale(const Locale('en', 'US'));
      } else {
        context.setLocale(const Locale('vi', 'VN'));
      }
    },
  ),
),
          ],
        ),
      ),
    );
  }

  Widget _buildPage({required IconData icon, required String title, required String description}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
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
          const SizedBox(height: 60),
        ],
      ),
    );
  }

  Widget _buildIndicator(int index, Color color) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.symmetric(horizontal: 6),
      height: 10,
      width: _currentPage == index ? 26 : 10,
      decoration: BoxDecoration(
        color: _currentPage == index ? color : const Color(0xFFE0E0E0),
        borderRadius: BorderRadius.circular(5),
      ),
    );
  }
}
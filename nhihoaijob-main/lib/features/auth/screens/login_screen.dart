import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';
import 'package:http/http.dart' as http; // Thêm thư viện http để kết nối server
import 'dart:convert'; // Thêm để giải mã chuỗi dữ liệu JSON
import 'package:shared_preferences/shared_preferences.dart'; // ĐÃ THÊM: Để lưu quyền vào máy
import 'package:tuanhoai01/features/candidate/screens/candidate_main_screen.dart'; // Màn hình chính (Home) của bạn
import 'package:tuanhoai01/features/auth/screens/register_screen.dart'; // Import màn hình đăng ký

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // ĐƯỜNG LINK API ĐĂNG NHẬP CHUẨN TRÊN SERVER THẬT
  final String _loginApiUrl = "http://nhjob.online/api/auth/login.php";
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // HÀM XỬ LÝ ĐĂNG NHẬP XÁC THỰC VỚI DATABASE TRÊN HOST (ĐÃ SỬA PHÂN QUYỀN ĐỘNG)
  Future<void> _onLoginPressed() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    // 1. Kiểm tra nhanh dữ liệu trống tại Client
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập đầy đủ thông tin.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 2. Gửi yêu cầu đăng nhập dạng POST lên file login.php trên server
      final response = await http.post(
        Uri.parse(_loginApiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          'username': email, // File PHP của bạn nhận tham số là 'username' (hỗ trợ nhập cả email/username)
          'password': password,
        }),
      );

      setState(() => _isLoading = false);

      if (response.statusCode == 200) {
        // 3. Giải mã dữ liệu JSON trả về từ máy chủ
        final result = jsonDecode(response.body);

        // ĐIỀU KIỆN QUYẾT ĐỊNH: Server xác nhận đúng tài khoản mật khẩu (status == 'success')
        if (result['status'] == 'success') {
          if (!mounted) return;

          // 🌟 ĐÃ SỬA TẠI ĐÂY: Lấy quyền thực tế từ server trả về thay vì ép cứng chữ 'admin'
          // Nếu server trả về key 'role' trực tiếp thì result['role'] sẽ hoạt động chuẩn xác.
          // Trong trường hợp quyền bị rỗng hoặc null, app sẽ mặc định gán là 'user' để bảo mật.
          String userRole = result['role'] ?? 'user';

          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('role', userRole); // Lưu quyền động của tài khoản này vào máy

          // In log ra debug console để kiểm tra quyền thực tế khi đăng nhập
          debugPrint("🔥 ĐĂNG NHẬP THÀNH CÔNG! QUYỀN TÀI KHOẢN HIỆN TẠI LÀ: $userRole");

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result['message'] ?? 'Đăng nhập thành công!')),
          );

          // Điều hướng vào thẳng màn hình Home (CandidateMainScreen) và xóa sạch lịch sử chuyển trang trước đó
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const CandidateMainScreen()),
            (route) => false,
          );
        } else {
          // Trường hợp Server báo sai tài khoản hoặc sai mật khẩu
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result['message'] ?? 'Đăng nhập thất bại.')),
          );
        }
      } else {
        // Trường hợp lỗi kết nối hệ thống máy chủ (Lỗi 500, lỗi 502,...)
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi hệ thống máy chủ (${response.statusCode})')),
        );
      }
    } catch (e) {
      // Trường hợp lỗi kết nối mạng internet hoặc thiết bị không có mạng
      setState(() => _isLoading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã xảy ra lỗi kết nối: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color zaloBlue = const Color(0xFFE24C33);
    final Color ultraFadedShapeColor = zaloBlue.withValues(alpha: 0.05);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            _buildBackgroundShapes(ultraFadedShapeColor),
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  const SizedBox(height: 80),
                  Image.asset(
                    'assets/images/logo.png',
                    height: 120,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.image_not_supported, size: 100),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Đăng Nhập',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 32),
                  _buildInputField(
                    controller: _emailController,
                    label: 'Email hoặc Tên tài khoản',
                    icon: Remix.mail_line,
                    color: zaloBlue,
                  ),
                  const SizedBox(height: 18),
                  _buildInputField(
                    controller: _passwordController,
                    label: 'Mật khẩu',
                    icon: Remix.lock_password_line,
                    color: zaloBlue,
                    isPassword: true,
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: zaloBlue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: _isLoading ? null : _onLoginPressed,
                      child: _isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text('ĐĂNG NHẬP',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Chưa có tài khoản? ',
                          style: TextStyle(color: Colors.grey)),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const RegisterScreen()),
                          );
                        },
                        child: Text(
                          'Đăng ký ngay',
                          style: TextStyle(
                              color: zaloBlue, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required Color color,
    bool isPassword = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: color, size: 20),
        enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.black12)),
        focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: color, width: 1.5)),
      ),
    );
  }

  Widget _buildBackgroundShapes(Color color) {
    return Stack(
      children: [
        Positioned(
          top: -80,
          left: -80,
          child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        ),
        Positioned(
          bottom: -50,
          right: -50,
          child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                  color: color, borderRadius: BorderRadius.circular(40))),
        ),
      ],
    );
  }
}
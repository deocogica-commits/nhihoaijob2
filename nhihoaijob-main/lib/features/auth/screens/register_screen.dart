import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:remixicon/remixicon.dart';
import 'package:http/http.dart' as http; // Thêm thư viện http để gọi API trực tiếp nếu cần
import 'dart:convert'; // Thêm để giải mã chuỗi JSON từ Server
import 'package:tuanhoai01/features/candidate/screens/candidate_main_screen.dart';
import 'package:tuanhoai01/features/auth/screens/login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // 1. Khai báo các Controller để lấy dữ liệu từ TextField
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  // ĐƯỜNG LINK API CHUẨN ĐÃ ĐƯỢC FIX LỖI SERVER
  final String _registerApiUrl = "https://nhjob.online/api/auth/register.php";
  bool _isLoading = false;

  // 2. Hàm xử lý đăng ký gửi trực tiếp lên Host thật
  Future<void> _handleRegister() async {
    final username = _usernameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    // Kiểm tra dữ liệu đầu vào cơ bản tại Client
    if (username.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập đầy đủ thông tin')),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mật khẩu xác nhận không khớp')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Thực hiện gửi dữ liệu đăng ký dạng POST lên Host nhjob.online
      final response = await http.post(
        Uri.parse(_registerApiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          'username': username,
          'email': email,
          'password': password,
        }),
      );

      debugPrint('REGISTER API URL: $_registerApiUrl');
      debugPrint('REGISTER STATUS: ${response.statusCode}');
      debugPrint('REGISTER HEADERS: ${response.headers}');
      debugPrint('REGISTER BODY: ${response.body}');

      setState(() => _isLoading = false);

      if (response.statusCode == 200) {
        // Giải mã dữ liệu JSON trả về từ file register.php của server
        final result = jsonDecode(response.body);

        // ĐIỀU KIỆN QUYẾT ĐỊNH: Chỉ khi Server trả về status thành công mới cho vào trang Home
        if (result['status'] == 'success') {
          if (!mounted) return;
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('user_name', username);
          await prefs.setString('role', 'worker');
          await prefs.setString('auth_token', 'logged_in');
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đăng ký thành công! Đang vào hệ thống...')),
          );

          // Xóa toàn bộ lịch sử chuyển trang cũ và đưa người dùng vào thẳng trang Home (Main)
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const CandidateMainScreen()),
            (route) => false,
          );
        } else {
          // Trường hợp server phản hồi lỗi (Ví dụ trùng Email, trùng Tên tài khoản)
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result['message'] ?? 'Đăng ký thất bại từ máy chủ')),
          );
        }
      } else {
        // Trường hợp sập lỗi kết nối HTTP không mong muốn (Lỗi 500, lỗi 404)
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi kết nối Server thật (${response.statusCode})')),
        );
      }
    } catch (e) {
      debugPrint('REGISTER EXCEPTION: $e');
      // Trường hợp mất mạng hoặc không thể gửi request đi được
      setState(() => _isLoading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã xảy ra lỗi kết nối mạng: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color zaloBlue = Color(0xFFE24C33);
    const Color ultraFadedShapeColor = Color(0x0D0068FF);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            _buildBackgroundShapes(ultraFadedShapeColor),
            LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: IntrinsicHeight(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 30),
                          Image.asset('assets/images/logo.png', height: 120, fit: BoxFit.contain),
                          const SizedBox(height: 16),
                          const Text('Tạo tài khoản mới',
                              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87)),
                          const SizedBox(height: 32),

                          // Form nhập dữ liệu của bạn
                          _buildInputField(label: 'Tên tài khoản', icon: Remix.user_3_line, color: zaloBlue, controller: _usernameController),
                          const SizedBox(height: 18),
                          _buildInputField(label: 'Email', icon: Remix.mail_line, color: zaloBlue, controller: _emailController),
                          const SizedBox(height: 18),
                          _buildInputField(label: 'Mật khẩu', icon: Remix.lock_password_line, color: zaloBlue, isPassword: true, controller: _passwordController),
                          const SizedBox(height: 18),
                          _buildInputField(label: 'Xác nhận mật khẩu', icon: Remix.checkbox_circle_line, color: zaloBlue, isPassword: true, controller: _confirmPasswordController),
                          
                          const SizedBox(height: 36),

                          // Nút đăng ký tương tác
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: zaloBlue,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                                elevation: 0,
                              ),
                              onPressed: _isLoading ? null : _handleRegister,
                              child: _isLoading 
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                  )
                                : const Text('ĐĂNG KÝ', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                            ),
                          ),

                          const SizedBox(height: 40),
                          const Text('Hoặc đăng ký nhanh bằng', style: TextStyle(color: Colors.grey, fontSize: 13)),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _socialButton(Remix.google_fill, Colors.red),
                              const SizedBox(width: 20),
                              _socialButton(Remix.apple_fill, Colors.black),
                              const SizedBox(width: 20),
                              _socialButton(Remix.facebook_circle_fill, const Color(0xFF1877F2)), // Sửa sang màu xanh Facebook thương hiệu
                            ],
                          ),
                          const SizedBox(height: 32),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('Đã có tài khoản?', style: TextStyle(color: Colors.grey, fontSize: 14)),
                              TextButton(
                                onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen())),
                                child: const Text('Đăng nhập', style: TextStyle(color: zaloBlue, fontWeight: FontWeight.bold, fontSize: 14)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({required String label, required IconData icon, required Color color, bool isPassword = false, required TextEditingController controller}) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey, fontSize: 14),
        prefixIcon: Icon(icon, color: color, size: 20),
        enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.black12)),
        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: color, width: 1.5)),
      ),
    );
  }

  Widget _socialButton(IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.black12, width: 1)),
      child: IconButton(icon: Icon(icon, size: 24, color: color), onPressed: () {}),
    );
  }

  Widget _buildBackgroundShapes(Color color) {
    return Stack(
      children: [
        Positioned(top: -80, left: -80, child: Container(width: 250, height: 250, decoration: BoxDecoration(color: color, shape: BoxShape.circle))),
        Positioned(bottom: -50, right: -50, child: Container(width: 200, height: 200, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(40)))),
      ],
    );
  }
}

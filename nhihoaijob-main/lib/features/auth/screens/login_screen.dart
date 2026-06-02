import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:tuanhoai01/features/candidate/screens/candidate_main_screen.dart';
import 'package:tuanhoai01/features/auth/screens/register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final String _loginApiUrl = "https://nhjob.online/api/auth/login.php";
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _onLoginPressed() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('auth.msg_required_info'.tr())),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse(_loginApiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          'username': email,
          'password': password,
        }),
      );

      setState(() => _isLoading = false);

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);

        if (result['status'] == 'success') {
          if (!mounted) return;

          String userRole = result['role'] ?? 'user';
          final Map<String, dynamic>? user =
              result['user'] is Map<String, dynamic>
                  ? result['user'] as Map<String, dynamic>
                  : null;
          final String userName =
              (user?['name'] ?? user?['username'] ?? email).toString();
          final String userId = (user?['id'] ?? '').toString();

          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('user_name', userName);
          if (userId.isNotEmpty) {
            await prefs.setString('user_id', userId);
            await prefs.setString('id', userId);
          }
          await prefs.setString('auth_token', 'logged_in');
          await prefs.setString('role', userRole);
          
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result['message'] ?? 'auth.login_success'.tr())),
          );

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const CandidateMainScreen()),
            (route) => false,
          );
        } else {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result['message'] ?? 'auth.login_failed'.tr())),
          );
        }
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('auth.server_error'.tr())),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('auth.error_connection'.tr())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color zaloBlue = const Color(0xFFE24C33);
    final Color ultraFadedShapeColor = zaloBlue.withValues(alpha: 0.05);

    return Scaffold(
      backgroundColor: Colors.white,
      // Đã loại bỏ AppBar chứa nút chuyển ngôn ngữ
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
                  Text(
                    'auth.login_title'.tr(),
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 32),
                  _buildInputField(
                    controller: _emailController,
                    label: 'auth.email_label'.tr(),
                    icon: Remix.mail_line,
                    color: zaloBlue,
                  ),
                  const SizedBox(height: 18),
                  _buildInputField(
                    controller: _passwordController,
                    label: 'auth.password_label'.tr(),
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
                          : Text('auth.login_button'.tr(),
                              style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('auth.no_account'.tr(),
                          style: const TextStyle(color: Colors.grey)),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const RegisterScreen()),
                          );
                        },
                        child: Text(
                          'auth.register_now'.tr(),
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
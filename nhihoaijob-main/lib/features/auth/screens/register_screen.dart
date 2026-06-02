import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:remixicon/remixicon.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:easy_localization/easy_localization.dart'; // Đã thêm
import 'package:tuanhoai01/features/candidate/screens/candidate_main_screen.dart';
import 'package:tuanhoai01/features/auth/screens/login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  final String _registerApiUrl = "https://nhjob.online/api/auth/register.php";
  bool _isLoading = false;

  Future<void> _handleRegister() async {
    final username = _usernameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (username.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('register.msg_empty'.tr())));
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('register.msg_wrong_pass'.tr())));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse(_registerApiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({'username': username, 'email': email, 'password': password}),
      );

      setState(() => _isLoading = false);

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        if (result['status'] == 'success') {
          if (!mounted) return;
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('user_name', username);
          await prefs.setString('role', 'worker');
          await prefs.setString('auth_token', 'logged_in');
          
          if (result['user'] is Map<String, dynamic>) {
            final user = result['user'] as Map<String, dynamic>;
            final userId = user['id']?.toString() ?? '';
            if (userId.isNotEmpty) {
              await prefs.setString('user_id', userId);
              await prefs.setString('id', userId);
            }
            await prefs.setString('user_name', (user['name'] ?? user['username'] ?? username).toString());
            await prefs.setString('role', (user['role'] ?? 'worker').toString());
          }
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('register.msg_success'.tr())));
          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const CandidateMainScreen()), (route) => false);
        } else {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result['message'] ?? 'register.msg_fail'.tr())));
        }
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${'register.msg_server_error'.tr()} (${response.statusCode})')));
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${'register.msg_network_error'.tr()}: $e')));
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
                          Text('register.title'.tr(), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87)),
                          const SizedBox(height: 32),

                          _buildInputField(label: 'register.username'.tr(), icon: Remix.user_3_line, color: zaloBlue, controller: _usernameController),
                          const SizedBox(height: 18),
                          _buildInputField(label: 'register.email'.tr(), icon: Remix.mail_line, color: zaloBlue, controller: _emailController),
                          const SizedBox(height: 18),
                          _buildInputField(label: 'register.password'.tr(), icon: Remix.lock_password_line, color: zaloBlue, isPassword: true, controller: _passwordController),
                          const SizedBox(height: 18),
                          _buildInputField(label: 'register.confirm_password'.tr(), icon: Remix.checkbox_circle_line, color: zaloBlue, isPassword: true, controller: _confirmPasswordController),
                          
                          const SizedBox(height: 36),

                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: zaloBlue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)), elevation: 0),
                              onPressed: _isLoading ? null : _handleRegister,
                              child: _isLoading 
                                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                : Text('register.button'.tr(), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                            ),
                          ),

                          const SizedBox(height: 40),
                          Text('register.social_text'.tr(), style: const TextStyle(color: Colors.grey, fontSize: 13)),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _socialButton(Remix.google_fill, Colors.red),
                              const SizedBox(width: 20),
                              _socialButton(Remix.apple_fill, Colors.black),
                              const SizedBox(width: 20),
                              _socialButton(Remix.facebook_circle_fill, const Color(0xFF1877F2)),
                            ],
                          ),
                          const SizedBox(height: 32),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('register.has_account'.tr(), style: const TextStyle(color: Colors.grey, fontSize: 14)),
                              TextButton(
                                onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen())),
                                child: Text('register.login'.tr(), style: const TextStyle(color: zaloBlue, fontWeight: FontWeight.bold, fontSize: 14)),
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
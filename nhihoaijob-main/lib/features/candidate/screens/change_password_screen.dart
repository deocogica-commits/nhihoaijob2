import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:remixicon/remixicon.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _obscureOld = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;

  // Controllers để lấy giá trị text
  final _oldPassController = TextEditingController();
  final _newPassController = TextEditingController();
  final _confirmPassController = TextEditingController();

  @override
  void dispose() {
    _oldPassController.dispose();
    _newPassController.dispose();
    _confirmPassController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFFE24C33); // Màu chủ đạo từ màn hình cũ

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Remix.arrow_left_line, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Đổi mật khẩu',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Mật khẩu mới của bạn phải có ít nhất 6 ký tự, bao gồm cả chữ và số.',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 32),
              
              // Mật khẩu hiện tại
              _buildPasswordField(
                label: 'Mật khẩu hiện tại',
                controller: _oldPassController,
                obscure: _obscureOld,
                onToggle: () => setState(() => _obscureOld = !_obscureOld),
              ),
              const SizedBox(height: 20),

              // Mật khẩu mới
              _buildPasswordField(
                label: 'Mật khẩu mới',
                controller: _newPassController,
                obscure: _obscureNew,
                onToggle: () => setState(() => _obscureNew = !_obscureNew),
              ),
              const SizedBox(height: 20),

              // Xác nhận mật khẩu
              _buildPasswordField(
                label: 'Xác nhận mật khẩu mới',
                controller: _confirmPassController,
                obscure: _obscureConfirm,
                onToggle: () => setState(() => _obscureConfirm = !_obscureConfirm),
                validator: (value) {
                  if (value != _newPassController.text) {
                    return 'Mật khẩu xác nhận không khớp';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 40),

              // Nút Cập nhật
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Cập nhật mật khẩu',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required bool obscure,
    required VoidCallback onToggle,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscure,
          validator: validator ?? (value) {
            if (value == null || value.isEmpty) return 'Vui lòng nhập thông tin';
            if (value.length < 6) return 'Mật khẩu phải từ 6 ký tự';
            return null;
          },
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            hintText: '••••••••',
            hintStyle: TextStyle(color: Colors.grey.shade400),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            suffixIcon: IconButton(
              icon: Icon(obscure ? Remix.eye_off_line : Remix.eye_line, size: 20),
              onPressed: onToggle,
              color: Colors.grey,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id') ?? prefs.getString('id') ?? '';

    if (userId.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không tìm thấy thông tin tài khoản. Vui lòng đăng nhập lại.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('https://nhjob.online/api/auth/change_password.php'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "user_id": userId,
          "current_password": _oldPassController.text,
          "new_password": _newPassController.text,
        }),
      ).timeout(const Duration(seconds: 10));

      final result = jsonDecode(utf8.decode(response.bodyBytes));

      if (!mounted) return;
      if (result is Map && result['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']?.toString() ?? 'Đổi mật khẩu thành công'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message']?.toString() ?? 'Đổi mật khẩu thất bại')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không thể kết nối server: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}

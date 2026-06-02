import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:remixicon/remixicon.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:easy_localization/easy_localization.dart'; // Đã thêm

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
    const Color primaryColor = Color(0xFFE24C33);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: const Icon(Remix.arrow_left_line, color: Colors.black87), onPressed: () => Navigator.pop(context)),
        title: Text('change_password.title'.tr(), style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('change_password.desc'.tr(), style: const TextStyle(color: Colors.grey, fontSize: 14)),
              const SizedBox(height: 32),
              _buildPasswordField(label: 'change_password.old_pass'.tr(), controller: _oldPassController, obscure: _obscureOld, onToggle: () => setState(() => _obscureOld = !_obscureOld)),
              const SizedBox(height: 20),
              _buildPasswordField(label: 'change_password.new_pass'.tr(), controller: _newPassController, obscure: _obscureNew, onToggle: () => setState(() => _obscureNew = !_obscureNew)),
              const SizedBox(height: 20),
              _buildPasswordField(
                label: 'change_password.confirm_pass'.tr(),
                controller: _confirmPassController,
                obscure: _obscureConfirm,
                onToggle: () => setState(() => _obscureConfirm = !_obscureConfirm),
                validator: (value) => value != _newPassController.text ? 'change_password.pass_mismatch'.tr() : null,
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitForm,
                  style: ElevatedButton.styleFrom(backgroundColor: primaryColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation: 0),
                  child: _isLoading
                      ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text('change_password.btn_update'.tr(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField({required String label, required TextEditingController controller, required bool obscure, required VoidCallback onToggle, String? Function(String?)? validator}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscure,
          validator: validator ?? (value) {
            if (value == null || value.isEmpty) return 'change_password.err_required'.tr();
            if (value.length < 6) return 'change_password.err_length'.tr();
            return null;
          },
          decoration: InputDecoration(
            filled: true, fillColor: Colors.white, hintText: '••••••••', hintStyle: TextStyle(color: Colors.grey.shade400),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            suffixIcon: IconButton(icon: Icon(obscure ? Remix.eye_off_line : Remix.eye_line, size: 20), onPressed: onToggle, color: Colors.grey),
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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('change_password.err_no_user'.tr())));
      return;
    }
    setState(() => _isLoading = true);
    try {
      final response = await http.post(
        Uri.parse('https://nhjob.online/api/auth/change_password.php'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"user_id": userId, "current_password": _oldPassController.text, "new_password": _newPassController.text}),
      ).timeout(const Duration(seconds: 10));
      final result = jsonDecode(utf8.decode(response.bodyBytes));
      if (!mounted) return;
      if (result is Map && result['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result['message']?.toString() ?? 'change_password.success'.tr()), backgroundColor: Colors.green));
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result['message']?.toString() ?? 'change_password.fail'.tr())));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${'change_password.server_error'.tr()}: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart'; // Import thư viện này

class FormDangTinScreen extends StatefulWidget {
  final String title;
  final String category;
  final Map<dynamic, dynamic>? existingJob;

  const FormDangTinScreen({
    super.key, 
    required this.title, 
    required this.category, 
    this.existingJob,
  });

  @override
  State<FormDangTinScreen> createState() => _FormDangTinScreenState();
}

class _FormDangTinScreenState extends State<FormDangTinScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _salaryController = TextEditingController(); 
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _detailAddressController = TextEditingController();
  
  String? _selectedRegion;
  bool _isLoading = false;

  final List<Map<String, String>> _regions = [
    {'value': 'Đài Bắc', 'label': 'Đài Bắc'},
    {'value': 'Đài Trung', 'label': 'Đài Trung'},
    {'value': 'Đài Nam', 'label': 'Đài Nam'},
    {'value': 'Cao Hùng', 'label': 'Cao Hùng'}, 
  ];

  bool get _isEditMode => widget.existingJob != null;

  @override
  void initState() {
    super.initState();
    final job = widget.existingJob;
    if (job == null) return;

    _titleController.text = job['title']?.toString() ?? '';
    _descriptionController.text = job['description']?.toString() ?? '';
    _salaryController.text = job['salary']?.toString() ?? '';
    _phoneController.text = job['contact_phone']?.toString() ?? '';

    final regionText = job['region']?.toString() ?? '';
    for (final region in _regions) {
      final value = region['value']!;
      if (regionText.startsWith(value)) {
        _selectedRegion = value;
        _detailAddressController.text = regionText.substring(value.length).trim();
        break;
      }
    }
  }

  Future<void> _submitPost() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // 1. Lấy ID người dùng đang đăng nhập từ SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final String myId = (prefs.getString('user_id') ?? prefs.getString('id') ?? prefs.getInt('id')?.toString()) ?? '0';
    final String role = prefs.getString('role') ?? 'worker';

    final url = Uri.parse(_isEditMode
        ? 'https://nhjob.online/api/posts/update_job.php'
        : 'https://nhjob.online/api/posts/create_post.php');

    String fullAddress = "$_selectedRegion ${_detailAddressController.text.trim()}";

    final Map<String, dynamic> postData = {
      'title': _titleController.text.trim(),
      'category': widget.category,
      'region': fullAddress,
      'salary': _salaryController.text.trim(), 
      'description': _descriptionController.text.trim(),
      'contact_phone': _phoneController.text.trim(),
      'user_id': myId, // 2. Gửi ID thực tế lên server thay vì số 1 cố định
      'role': role,
    };

    if (_isEditMode) {
      postData['id'] = widget.existingJob?['id']?.toString() ?? '';
    }

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode(postData),
      );

      if (!mounted) return;

      final responseBodyString = utf8.decode(response.bodyBytes);
      final responseData = jsonDecode(responseBodyString);

      if (responseData is Map<String, dynamic> && responseData['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditMode ? 'Cập nhật bài thành công!' : 'Đăng bài thành công!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      } else {
        _showErrorDialog(responseData['message'] ?? 'Đã xảy ra lỗi hệ thống.');
      }
    } catch (e) {
      if (mounted) _showErrorDialog('Không thể kết nối đến máy chủ.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Thông báo'),
        content: Text(message),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Đóng'))],
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _salaryController.dispose();
    _phoneController.dispose();
    _detailAddressController.dispose();
    super.dispose();
  }

  // --- Các hàm UI giữ nguyên ---
  Widget _buildInputLabel(String label) => Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)));
  
  InputDecoration _getInputDecoration() => InputDecoration(
    filled: true, 
    fillColor: Colors.white, 
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)
  );

  Widget _buildTextField(String hint, TextEditingController controller, {int maxLines = 1, TextInputType keyboardType = TextInputType.text, String? Function(String?)? validator}) => TextFormField(
    controller: controller, 
    maxLines: maxLines, 
    keyboardType: keyboardType, 
    validator: validator, 
    decoration: _getInputDecoration().copyWith(hintText: hint)
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FA),
      appBar: AppBar(
        title: Text(widget.title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFFE24C33),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFE24C33)))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInputLabel("Tiêu đề tin đăng (*)"),
                    _buildTextField("Ví dụ: Tuyển nhân viên...", _titleController, validator: (v) => v!.isEmpty ? 'Vui lòng nhập' : null),
                    const SizedBox(height: 20),
                    _buildInputLabel("Thành phố làm việc (*)"),
                    DropdownButtonFormField<String>(
                      value: _selectedRegion,
                      hint: const Text("Chọn thành phố..."),
                      decoration: _getInputDecoration(),
                      items: _regions.map((r) => DropdownMenuItem(value: r['value'], child: Text(r['label']!))).toList(),
                      onChanged: (v) => setState(() => _selectedRegion = v),
                      validator: (v) => v == null ? 'Vui lòng chọn' : null,
                    ),
                    const SizedBox(height: 16),
                    _buildInputLabel("Địa chỉ cụ thể"),
                    _buildTextField("Ví dụ: Số 12, đường...", _detailAddressController),
                    const SizedBox(height: 20),
                    _buildInputLabel("Mức lương (*)"),
                    _buildTextField("Ví dụ: 28.000 NTD", _salaryController, validator: (v) => v!.isEmpty ? 'Vui lòng nhập' : null),
                    const SizedBox(height: 20),
                    _buildInputLabel("Số điện thoại"),
                    _buildTextField("Nhập số điện thoại...", _phoneController, keyboardType: TextInputType.phone),
                    const SizedBox(height: 20),
                    _buildInputLabel("Mô tả chi tiết (*)"),
                    _buildTextField("Mô tả cụ thể...", _descriptionController, maxLines: 5, validator: (v) => v!.isEmpty ? 'Vui lòng nhập' : null),
                    const SizedBox(height: 40),
                    SizedBox(
                      width: double.infinity, height: 50,
                      child: ElevatedButton(
                        onPressed: _submitPost,
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE24C33)),
                        child: Text(_isEditMode ? "CẬP NHẬT BÀI" : "ĐĂNG TIN NGAY", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    )
                  ],
                ),
              ),
            ),
    );
  }
}

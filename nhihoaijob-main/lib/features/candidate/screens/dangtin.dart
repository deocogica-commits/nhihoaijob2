import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Giữ nguyên - Thêm thư viện để chặn ký tự chữ
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy_localization/easy_localization.dart';

class FormDangTinScreen extends StatefulWidget {
  final String title;
  final String category;
  final Map<dynamic, dynamic>? existingJob;

  const FormDangTinScreen({super.key, required this.title, required this.category, this.existingJob});

  @override
  State<FormDangTinScreen> createState() => _FormDangTinScreenState();
}

class _FormDangTinScreenState extends State<FormDangTinScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _companyController = TextEditingController(); // 1. THÊM MỚI: Controller cho tên công ty
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _salaryController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _detailAddressController = TextEditingController();

  String? _selectedRegion;
  bool _isLoading = false;

  final List<Map<String, String>> _regions = [
    {'value': 'Đài Bắc', 'label': '台北'},
    {'value': 'Đài Trung', 'label': '台中'},
    {'value': 'Đài Nam', 'label': '台南'},
    {'value': 'Cao Hùng', 'label': '高雄'},
  ];

  bool get _isEditMode => widget.existingJob != null;

  @override
  void initState() {
    super.initState();
    final job = widget.existingJob;
    if (job == null) return;
    _titleController.text = job['title']?.toString() ?? '';
    _companyController.text = job['company_name']?.toString() ?? ''; // 1. THÊM MỚI: Đổ dữ liệu công ty cũ khi sửa tin
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
    final prefs = await SharedPreferences.getInstance();
    final String myId = (prefs.getString('user_id') ?? prefs.getString('id') ?? prefs.getInt('id')?.toString()) ?? '0';
    final String role = prefs.getString('role') ?? 'worker';
    final url = Uri.parse(_isEditMode ? 'https://nhjob.online/api/posts/update_job.php' : 'https://nhjob.online/api/posts/create_post.php');
    String fullAddress = "$_selectedRegion ${_detailAddressController.text.trim()}";
    final Map<String, dynamic> postData = {
      'title': _titleController.text.trim(),
      'company_name': _companyController.text.trim(), // 1. THÊM MỚI: Gửi kèm tên công ty lên API của bạn
      'category': widget.category,
      'region': fullAddress,
      'salary': _salaryController.text.trim(),
      'description': _descriptionController.text.trim(),
      'contact_phone': _phoneController.text.trim(),
      'user_id': myId,
      'role': role,
    };
    if (_isEditMode) postData['id'] = widget.existingJob?['id']?.toString() ?? '';
    try {
      final response = await http.post(url, headers: {'Content-Type': 'application/json; charset=UTF-8'}, body: jsonEncode(postData));
      if (!mounted) return;
      final responseData = jsonDecode(utf8.decode(response.bodyBytes));
      if (responseData is Map<String, dynamic> && responseData['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_isEditMode ? 'post_job.msg_success_update'.tr() : 'post_job.msg_success_create'.tr()), backgroundColor: Colors.green));
        Navigator.pop(context, true);
      } else {
        _showErrorDialog(responseData['message'] ?? 'post_job.msg_error_system'.tr());
      }
    } catch (e) {
      if (mounted) _showErrorDialog('post_job.msg_error_server'.tr());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('post_job.dialog_title'.tr()),
        content: Text(message),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: Text('post_job.dialog_close'.tr()))],
      ),
    );
  }

  Widget _buildInputLabel(String label) => Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)));
  InputDecoration _getInputDecoration() => InputDecoration(filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none));
  
  // SỬA NHẸ HÀM CHUNG: Thêm tham số inputFormatters để dùng riêng cho ô Lương và SĐT
  Widget _buildTextField(
    String hint, 
    TextEditingController controller, {
    int maxLines = 1, 
    TextInputType keyboardType = TextInputType.text, 
    List<TextInputFormatter>? inputFormatters, // Thêm dòng này để truyền bộ lọc ký tự
    String? Function(String?)? validator
  }) => TextFormField(
    controller: controller, 
    maxLines: maxLines, 
    keyboardType: keyboardType, 
    inputFormatters: inputFormatters, // Gán bộ lọc vào TextFormField
    validator: validator, 
    decoration: _getInputDecoration().copyWith(hintText: hint)
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FA),
      appBar: AppBar(title: Text(widget.title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)), backgroundColor: const Color(0xFFE24C33)),
      body: _isLoading ? const Center(child: CircularProgressIndicator(color: Color(0xFFE24C33))) : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInputLabel("post_job.title_label".tr()),
              _buildTextField("post_job.title_hint".tr(), _titleController, validator: (v) => v!.isEmpty ? 'post_job.err_required'.tr() : null),
              const SizedBox(height: 20),
              
              // 1. THÊM MỚI: Ô nhập Tên công ty (Đặt ngay sau ô Tiêu đề)
              _buildInputLabel("post_job.company_label".tr()),
              _buildTextField("post_job.company_hint".tr(), _companyController),
              const SizedBox(height: 20),
              
              _buildInputLabel("post_job.city_label".tr()),
              DropdownButtonFormField<String>(
                value: _selectedRegion, hint: Text("post_job.city_hint".tr()), decoration: _getInputDecoration(),
                items: _regions.map((r) => DropdownMenuItem(value: r['value'], child: Text(r['label']!))).toList(),
                onChanged: (v) => setState(() => _selectedRegion = v),
                validator: (v) => v == null ? 'post_job.err_select'.tr() : null,
              ),
              const SizedBox(height: 16),
              _buildInputLabel("post_job.address_label".tr()),
              _buildTextField("post_job.address_hint".tr(), _detailAddressController),
              const SizedBox(height: 20),
              
              // 2. ĐÃ SỬA: Ô điền mức lương chỉ cho phép bấm SỐ
              _buildInputLabel("post_job.salary_label".tr()),
              _buildTextField(
                "post_job.salary_hint".tr(), 
                _salaryController, 
                keyboardType: TextInputType.number, // Hiển thị bàn phím số
                inputFormatters: [FilteringTextInputFormatter.digitsOnly], // Chặn hoàn toàn chữ và ký tự đặc biệt
                validator: (v) => v!.isEmpty ? 'post_job.err_required'.tr() : null
              ),
              const SizedBox(height: 20),
              
              // 2. ĐÃ SỬA: Ô điền số điện thoại chỉ cho phép bấm SỐ
              _buildInputLabel("post_job.phone_label".tr()),
              _buildTextField(
                "post_job.phone_hint".tr(), 
                _phoneController, 
                keyboardType: TextInputType.phone, // Hiển thị bàn phím cuộc gọi
                inputFormatters: [FilteringTextInputFormatter.digitsOnly], // Chặn hoàn toàn chữ và ký tự đặc biệt
              ),
              const SizedBox(height: 20),
              
              _buildInputLabel("post_job.desc_label".tr()),
              _buildTextField("post_job.desc_hint".tr(), _descriptionController, maxLines: 5, validator: (v) => v!.isEmpty ? 'post_job.err_required'.tr() : null),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity, height: 50,
                child: ElevatedButton(
                  onPressed: _submitPost, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE24C33)),
                  child: Text(_isEditMode ? "post_job.btn_update".tr() : "post_job.btn_create".tr(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:remixicon/remixicon.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tuanhoai01/features/auth/screens/login_screen.dart';
import 'package:tuanhoai01/features/auth/services/auth_service.dart';
import 'package:tuanhoai01/features/auth/services/avatar_service.dart';
import 'change_password_screen.dart';

class CandidateProfileScreen extends StatefulWidget {
  const CandidateProfileScreen({super.key});

  @override
  State<CandidateProfileScreen> createState() => _CandidateProfileScreenState();
}

class _CandidateProfileScreenState extends State<CandidateProfileScreen> {
  final AvatarService _avatarService = AvatarService();
  XFile? _pickedImage;
  String? _avatarUrl;
  String _userName = 'Người dùng'; // Biến lưu tên
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData(); // Đổi thành load dữ liệu tổng hợp
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    if (mounted) {
      setState(() {
        _avatarUrl = prefs.getString('avatar_url');
        _userName = prefs.getString('user_name') ?? 'Người dùng'; // Lấy tên từ bộ nhớ
      });
    }
  }

  Future<void> _pickAndUploadImage() async {
    if (_isUploading) return;

    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _isUploading = true;
        _pickedImage = image;
      });

      final prefs = await SharedPreferences.getInstance();
      final String? userId = prefs.getString('user_id'); // Lấy ID động

      final String? newUrl = await _avatarService.uploadAvatar(image, userId ?? '123');

      if (newUrl != null) {
        final String timestampedUrl = "$newUrl?t=${DateTime.now().millisecondsSinceEpoch}";
        await prefs.setString('avatar_url', timestampedUrl);
        
        await _loadUserData();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Đã cập nhật ảnh đại diện!")));
          Navigator.pop(context, true);
        }
      } else {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Upload thất bại, thử lại sau!")));
      }
      
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color mainColor = Color(0xFFE24C33);
    const Color backgroundColor = Color(0xFFF4F7FA);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context, false),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: _pickAndUploadImage,
                      child: Stack(
                        children: [
                          Container(
                            width: 75,
                            height: 75,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 3),
                              image: DecorationImage(
                                fit: BoxFit.cover,
                                image: _pickedImage != null 
                                    ? (kIsWeb ? NetworkImage(_pickedImage!.path) : FileImage(File(_pickedImage!.path))) as ImageProvider
                                    : (_avatarUrl != null && _avatarUrl!.isNotEmpty 
                                        ? NetworkImage(_avatarUrl!) 
                                        : const NetworkImage('https://ui-avatars.com/api/?name=User&background=E24C33&color=fff&size=200')),
                              ),
                            ),
                          ),
                          Positioned(right: 0, bottom: 0, child: Icon(_isUploading ? Icons.hourglass_top : Icons.camera_alt, size: 20, color: mainColor)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // HIỂN THỊ TÊN ĐỘNG Ở ĐÂY
                          Text(_userName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                          const Text('Người tìm việc', style: TextStyle(fontSize: 14, color: Colors.grey)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              _buildMenuSection([
                _buildMenuItem(mainColor, Remix.file_list_3_line, 'CV của tôi', 'Quản lý các CV đã tạo'),
                _buildMenuItem(mainColor, Remix.history_line, 'Lịch sử ứng tuyển', 'Theo dõi trạng thái'),
              ]),
              const SizedBox(height: 24),
              _buildMenuSection([
                _buildMenuItem(mainColor, Remix.lock_password_line, 'Đổi mật khẩu', '', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ChangePasswordScreen()))),
                _buildMenuItem(mainColor, Remix.customer_service_2_line, 'Trung tâm trợ giúp', ''),
                _buildMenuItem(mainColor, Remix.logout_box_r_line, 'Đăng xuất', '', isDestructive: true, onTap: () async {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.clear(); // Xóa sạch dữ liệu khi đăng xuất
                  if (!context.mounted) return;
                  Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const LoginScreen()), (route) => false);
                }),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuSection(List<Widget> children) => Container(margin: const EdgeInsets.symmetric(horizontal: 24.0), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8)]), child: Column(children: children));
  Widget _buildMenuItem(Color themeColor, IconData icon, String title, String subtitle, {bool isDestructive = false, VoidCallback? onTap}) => ListTile(leading: Icon(icon, color: isDestructive ? Colors.red : themeColor), title: Text(title, style: TextStyle(color: isDestructive ? Colors.red : Colors.black87, fontWeight: FontWeight.w600)), subtitle: subtitle.isNotEmpty ? Text(subtitle) : null, trailing: const Icon(Remix.arrow_right_s_line, size: 20), onTap: onTap);
}
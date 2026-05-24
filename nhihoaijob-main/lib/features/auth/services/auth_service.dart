import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
// Đảm bảo file api_endpoints.dart đã được sửa thành nhjob.online
import '../../../core/constants/api_endpoints.dart'; 

class AuthService {
  // Hàm xử lý Đăng ký
  Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiEndpoints.authRegister),
        // Thêm header và mã hóa JSON cho đồng bộ với file PHP trên host
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          'username': username,
          'email': email,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          "status": "error", 
          "message": "Server báo lỗi: ${response.statusCode}"
        };
      }
    } catch (e) {
      return {"status": "error", "message": "Không thể kết nối đến server: $e"};
    }
  }

  // Hàm xử lý Đăng nhập
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiEndpoints.authLogin),
        // Thêm header và mã hóa JSON cho đồng bộ với file PHP trên host
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          // Backend PHP của bạn dùng key 'username' để nhận dữ liệu đầu vào (hỗ trợ cả email/username)
          'username': email, 
          'password': password,
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        
        // ĐÃ ĐỒNG BỘ KEY: Đổi từ 'user_role' thành 'role' để khớp với màn hình chính
        if (responseData['status'] == 'success' && responseData['user'] != null) {
          final prefs = await SharedPreferences.getInstance();
          // Lấy role từ PHP (nếu không có thì mặc định gán là 'user')
          String role = responseData['user']['role'] ?? 'user'; 
          
          // ✨ ĐỔI TẠI ĐÂY: Lưu bằng key 'role' để đồng bộ hóa mã nguồn
          await prefs.setString('role', role);
          print("🔑 Đã lưu quyền thành công vào máy: $role");
        }

        return responseData;
      } else {
        return {
          "status": "error", 
          "message": "Tài khoản hoặc mật khẩu không chính xác (${response.statusCode})"
        };
      }
    } catch (e) {
      return {"status": "error", "message": "Lỗi kết nối mạng: $e"};
    }
  }

  // --- Xử lý Đăng xuất ---
  Future<void> logout() async {
    try {
      // 1. Khởi tạo SharedPreferences để xóa session cục bộ
      final prefs = await SharedPreferences.getInstance();
      
      // 2. Xóa sạch dữ liệu đăng nhập đã lưu trong máy (bao gồm cả role)
      await prefs.clear(); 

      print("Đã đăng xuất và xóa dữ liệu thành công trên domain nhjob.online.");
    } catch (e) {
      print("Lỗi khi xử lý đăng xuất: $e");
      rethrow;
    }
  }
}
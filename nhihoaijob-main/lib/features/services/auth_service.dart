import '../../../core/service/http_service.dart';

class AuthService {
  // 🔥 Biến static toàn cục dùng để lưu quyền hạn tài khoản sau khi login thành công
  static String currentUserRole = ''; 

  // Khởi tạo HttpService để sử dụng
  final HttpService _httpService = HttpService();

  // Hàm xử lý Đăng ký
  Future<Map<String, dynamic>> register(String username, String email, String password) async {
    final response = await _httpService.post("register.php", body: {
      "username": username,
      "email": email,
      "password": password,
    });
    return response;
  }

  // Hàm xử lý Đăng nhập
  Future<Map<String, dynamic>> login(String username, String password) async {
    final response = await _httpService.post("login.php", body: {
      "username": username,
      "password": password,
    });

    // Tự động gán quyền hạn khi đăng nhập thành công
    try {
      if (response['status'] == 'success' && response['role'] != null) {
        currentUserRole = response['role'].toString();
      }
    } catch (e) {
      print("Lỗi gán quyền user: $e");
    }

    return response;
  }
}
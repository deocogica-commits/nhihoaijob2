import 'package:tuanhoai01/core/constants/api_endpoints.dart';
import 'package:tuanhoai01/core/error/exceptions.dart';
import 'package:tuanhoai01/core/service/http_service.dart';
import 'package:tuanhoai01/features/auth/data/models/auth_response.dart';

/// Gọi API auth thông qua [HttpService] để kết nối với Hosting PHP.
class AuthRepository {
  // SỬA TẠI ĐÂY: Thêm dấu ngoặc nhọn {} để biến thành named parameter khớp với main.dart
  AuthRepository({required HttpService httpService}) : _http = httpService;

  final HttpService _http;

  Future<AuthResponse> login({
    required String email, // Đây là username hoặc email người dùng nhập
    required String password,
  }) async {
    // Gọi API login.php (Đã cấu hình trong ApiEndpoints)
    final json = await _http.post(
      ApiEndpoints.authLogin,
      body: {
        'username': email, // Backend PHP nhận khóa 'username'
        'password': password,
      },
    );

    // Kiểm tra phản hồi từ Backend PHP
    if (json['status'] == 'success' && json['user'] is Map<String, dynamic>) {
      return AuthResponse.fromJson(json['user'] as Map<String, dynamic>);
    }

    // Nếu thất bại, lấy thông báo lỗi từ PHP
    final msg = json['message']?.toString() ?? 'Đăng nhập thất bại';
    throw ServerException(msg);
  }

  Future<bool> register({
    required String username,
    required String email,
    required String password,
  }) async {
    // SỬA TẠI ĐÂY: Thay "register.php" bằng cấu hình chuẩn từ ApiEndpoints
    final json = await _http.post(
      ApiEndpoints.authRegister, 
      body: {
        'username': username,
        'email': email,
        'password': password,
      },
    );

    if (json['status'] == 'success') {
      return true;
    }

    final msg = json['message']?.toString() ?? 'Đăng ký thất bại';
    throw ServerException(msg);
  }
}
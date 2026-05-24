abstract final class ApiEndpoints {
  ApiEndpoints._();

  // 1. Link API chính thức sử dụng tên miền đã cấu hình tại TenTen
  // Lưu ý: Nếu bạn đã cài SSL trên Host thì đổi http thành https
  static const String baseUrl = "http://nhjob.online"; 
  
  // 2. Đường dẫn đến thư mục chứa các file PHP xử lý auth
  static const String _auth = '$baseUrl/api/auth';

  // --- CÁC ĐƯỜNG DẪN CỤ THỂ ---

  // Đăng ký: http://nhjob.online/api/auth/register.php
  static const String authRegister = '$_auth/register.php';

  // Đăng nhập: http://nhjob.online/api/auth/login.php
  static const String authLogin = '$_auth/login.php';

  // Các đường dẫn dự phòng và mở rộng sau này
  static const String authRefresh = '$_auth/refresh.php';
  static const String authForgotPassword = '$_auth/forgot-password.php';
  static const String authMe = '$_auth/me.php';
  
  // Link cho chức năng đổi mật khẩu (nếu bạn có file này)
  static const String changePassword = '$_auth/change_password.php';
}
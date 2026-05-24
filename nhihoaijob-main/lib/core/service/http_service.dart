import 'dart:convert';
import 'package:http/http.dart' as http;

class HttpService {
  // Thay bằng link hosting của bạn
  static const String baseUrl = "https://xkrj1hxc6a.tenten.vn";

  // Hàm post dùng để gọi API
  Future<Map<String, dynamic>> post(String endpoint, {Map<String, dynamic>? body}) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/$endpoint"),
        body: body,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          "status": "error",
          "message": "Lỗi kết nối: ${response.statusCode}"
        };
      }
    } catch (e) {
      return {
        "status": "error",
        "message": "Có lỗi xảy ra: $e"
      };
    }
  }

  // Thêm hàm này để các file cũ không báo lỗi 'postRequest'
  Future<Map<String, dynamic>> postRequest(String endpoint, Map<String, dynamic> body) async {
    return await post(endpoint, body: body);
  }
}
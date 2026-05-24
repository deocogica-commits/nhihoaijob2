import 'dart:convert';
import 'package:flutter/foundation.dart'; 
import 'package:http/http.dart' as http;

class AvatarService {
  // ĐƯỜNG DẪN ĐÃ SỬA: Trỏ đúng vào thư mục uploads nơi chứa file PHP của bạn
  final String uploadUrl = 'https://nhjob.online/uploads/upload_avatar.php';

  Future<String?> uploadAvatar(dynamic imageFile, String userId) async {
    try {
      debugPrint("Đang gửi yêu cầu tới: $uploadUrl");
      
      var request = http.MultipartRequest('POST', Uri.parse(uploadUrl));
      request.fields['user_id'] = userId;

      if (kIsWeb) {
        final bytes = await imageFile.readAsBytes();
        request.files.add(http.MultipartFile.fromBytes(
          'avatar', 
          bytes,
          filename: 'avatar.jpg',
        ));
      } else {
        request.files.add(await http.MultipartFile.fromPath('avatar', imageFile.path));
      }

      var response = await request.send();

      // Đọc phản hồi từ server
      final responseData = await response.stream.bytesToString();
      debugPrint("Server phản hồi (status ${response.statusCode}): $responseData");

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(responseData);
        
        // Kiểm tra backend trả về thành công
        if (jsonResponse['status'] == 'success') {
          return jsonResponse['url'];
        } else {
          debugPrint("Backend trả về lỗi: ${jsonResponse['message']}");
        }
      } else {
        debugPrint("Lỗi kết nối server, mã lỗi: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Lỗi exception khi upload: $e");
    }
    return null;
  }
}
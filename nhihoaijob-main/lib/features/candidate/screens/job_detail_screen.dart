import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class JobDetailScreen extends StatelessWidget {
  final Map<dynamic, dynamic> job;
  const JobDetailScreen({Key? key, required this.job}) : super(key: key);

  Future<void> _confirmDelete(BuildContext context) async {
    // Nhận kết quả từ Dialog xác nhận
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận'),
        content: const Text('Bạn có chắc chắn muốn xóa bài đăng này không?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy')),
          TextButton(
            onPressed: () => Navigator.pop(context, true), 
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      if (!context.mounted) return;
      await _deleteJob(context);
    }
  }

  Future<void> _deleteJob(BuildContext context) async {
    final url = Uri.parse('https://nhjob.online/api/posts/delete_job.php');
    
    // Hiển thị loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator(color: Colors.white)),
    );

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"id": job['id'].toString()}),
      ).timeout(const Duration(seconds: 10));

      if (!context.mounted) return;
      Navigator.pop(context); // Tắt loading

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200 && data['status'] == 'success') {
        // Thông báo thành công
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã xóa thành công!'), backgroundColor: Colors.green)
        );
        
        // QUAN TRỌNG: Trả về 'true' để màn hình trước biết cần gọi lại API
        Navigator.pop(context, true); 
      } else {
        _showErrorDialog(context, data['message'] ?? 'Lỗi server');
      }
    } catch (e) {
      if (!context.mounted) return;
      Navigator.pop(context); 
      _showErrorDialog(context, 'Không thể kết nối: $e');
    }
  }

  void _showErrorDialog(BuildContext context, String msg) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thông báo'),
        content: Text(msg),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Đóng Dialog thông báo
              // Nếu bạn muốn quay lại màn hình trước khi có lỗi, hãy thêm:
              // Navigator.pop(context, false); 
            }, 
            child: const Text('Đóng')
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(job['title'] ?? 'Chi tiết', style: const TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFFE24C33),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever, color: Colors.white, size: 28),
            onPressed: () => _confirmDelete(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(job['title'] ?? 'Không có tiêu đề', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
            const SizedBox(height: 20),
            _buildDetailRow(Icons.category, 'Danh mục', job['category']),
            _buildDetailRow(Icons.location_on, 'Khu vực', job['region']),
            _buildDetailRow(Icons.attach_money, 'Mức lương', job['salary']),
            _buildDetailRow(Icons.business, 'Công ty', job['company_name']),
            _buildDetailRow(Icons.phone, 'Liên hệ', job['contact_phone']),
            const SizedBox(height: 20),
            const Text('Mô tả chi tiết:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            Text(job['description'] ?? 'Không có mô tả.'),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: 8),
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value ?? 'Chưa cập nhật')),
        ],
      ),
    );
  }
}
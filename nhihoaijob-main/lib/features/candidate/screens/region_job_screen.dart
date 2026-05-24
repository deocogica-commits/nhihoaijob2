import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'job_detail_screen.dart'; // Đảm bảo đường dẫn này khớp chính xác với cấu trúc thư mục của bạn

class RegionJobScreen extends StatefulWidget {
  final String regionName; // Tên khu vực truyền từ Trang Chủ (Ví dụ: 'Đài Bắc', 'Đài Trung', 'Đài Nam')

  const RegionJobScreen({Key? key, required this.regionName}) : super(key: key);

  @override
  State<RegionJobScreen> createState() => _RegionJobScreenState();
}

class _RegionJobScreenState extends State<RegionJobScreen> {
  List<dynamic> _allJobs = [];
  List<dynamic> _filteredJobs = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchJobsByRegion();
  }

  // 🔥 HÀM CHUẨN HÓA SIÊU CẤP: Xóa dấu tiếng Việt, loại bỏ sạch các ký tự nhiễu (gạch ngang ngắn/dài, dấu chấm, khoảng trắng)
  String _normalizeString(String str) {
    const String vietnameseChars = 'àáạảãâầấậẩẫăằắặẳẵèéẹẻẽêềếệểễìíịỉĩòóọỏõôồốộổỗơờớợởỡùúụủũưừứựửữỳýỵỷỹđÀÁẠẢÃÂẦẤẬẨẪĂẰẮẶẲẴÈÉẸẺẼÊỀẾỆỂỄÌÍỊỈĨÒÓỌỎÕÔỒỐỘỔỖƠỜỚỢỞỠÙÚỤỦŨƯỪỨỰỬỮỲÝỴỶỸĐ';
    const String latinChars      = 'aaaaaaaaaaaaaaaaaeeeeeeeeeeeiiiiiooooooooooooooooouuuuuuuuuuuyyyyydAAAAAAAAAAAAAAAAAEEEEEEEEEEEIIIIIOOOOOOOOOOOOOOOOOUUUUUUUUUUUYYYYYD';
    
    String result = str.toLowerCase();
    
    // 1. Thay thế ký tự có dấu thành không dấu
    for (int i = 0; i < vietnameseChars.length; i++) {
      result = result.replaceAll(vietnameseChars[i], latinChars[i]);
    }
    
    // 2. Dọn sạch tất cả các loại dấu gạch ngang (ngắn, trung, dài), dấu chấm và khoảng trắng nhiễu
    result = result
        .replaceAll('-', '')  // Gạch ngang ngắn
        .replaceAll('–', '')  // Gạch ngang dài (En dash)
        .replaceAll('—', '')  // Gạch ngang rất dài (Em dash)
        .replaceAll('•', '')  // Dấu chấm tròn ngăn cách
        .replaceAll(' ', '')  // Khoảng trắng thường
        .trim();
        
    return result;
  }

  // Gọi API lấy danh sách việc làm
  Future<void> _fetchJobsByRegion() async {
    final url = Uri.parse('https://nhjob.online/api/posts/get_jobs.php');
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final responseBodyString = utf8.decode(response.bodyBytes);
        final data = jsonDecode(responseBodyString);

        if (data is List) {
          if (!mounted) return;
          setState(() {
            _allJobs = data;
            
            // 🔥 THUẬT TOÁN LỌC THEO TỪ KHÓA VÙNG MIỀN CỐT LÕI
            _filteredJobs = _allJobs.where((job) {
              if (job['region'] == null) return false;

              // Chuẩn hóa chuỗi thô từ cơ sở dữ liệu trả về
              final String cleanJobRegion = _normalizeString(job['region'].toString());
              
              // Chuẩn hóa tên vùng miền mục tiêu truyền từ nút bấm Trang chủ sang
              final String cleanTarget = _normalizeString(widget.regionName);

              // Tách từ khóa cốt lõi để đối chiếu (Phòng trường hợp chuỗi chứa nhiều thông tin phụ)
              String coreKeyword = '';
              if (cleanTarget.contains('bac')) {
                coreKeyword = 'bac';
              } else if (cleanTarget.contains('trung')) {
                coreKeyword = 'trung';
              } else if (cleanTarget.contains('nam')) {
                coreKeyword = 'nam';
              } else if (cleanTarget.contains('hung')) {
                coreKeyword = 'hung';
              } else {
                coreKeyword = cleanTarget;
              }

              // Kiểm tra sự tồn tại của từ khóa vùng miền trong chuỗi dữ liệu gốc
              return cleanJobRegion.contains(coreKeyword);
            }).toList();
            
            _isLoading = false;
          });
        } else {
          if (!mounted) return;
          setState(() {
            _errorMessage = "Định dạng dữ liệu nhận về từ Server không hợp lệ.";
            _isLoading = false;
          });
        }
      } else {
        if (!mounted) return;
        setState(() {
          _errorMessage = "Không thể tải dữ liệu từ API. Mã lỗi: ${response.statusCode}";
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = "Lỗi kết nối mạng hoặc hệ thống máy chủ.";
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String displayTitle = widget.regionName.toUpperCase();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FA),
      appBar: AppBar(
        title: Text(
          'Việc làm tại $displayTitle',
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18),
        ),
        backgroundColor: const Color(0xFFE24C33),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFE24C33)))
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!, style: const TextStyle(color: Colors.redAccent)))
              : _filteredJobs.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.work_off_outlined, size: 60, color: Colors.grey.shade400),
                          const SizedBox(height: 12),
                          Text(
                            'Chưa có bài tuyển dụng nào tại $displayTitle.',
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 15),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      itemCount: _filteredJobs.length,
                      itemBuilder: (context, index) {
                        final job = _filteredJobs[index];
                        return _buildJobCard(job);
                      },
                    ),
    );
  }

  Widget _buildJobCard(Map<String, dynamic> job) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => JobDetailScreen(job: job),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4F7FA),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.business_center_outlined, color: Color(0xFFE24C33), size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        job['title'] ?? 'Không có tiêu đề',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Khu vực: ${job['region'] ?? 'Chưa rõ'} • Lương: ${job['salary'] ?? 'Thỏa thuận'}',
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart'; // ĐÃ SỬA: Thêm 'package:'
import 'dangtin.dart';
import 'job_detail_screen.dart';

class LaborJobScreen extends StatefulWidget {
  const LaborJobScreen({super.key});
  @override
  State<LaborJobScreen> createState() => _LaborJobScreenState();
}

class _LaborJobScreenState extends State<LaborJobScreen> {
  List<dynamic> _jobs = [];
  String _selectedRegion = 'Tất cả';
  bool _isLoading = true;
  String _role = 'user';

  @override
  void initState() {
    super.initState();
    _checkRole();
    _fetchJobs();
  }

  Future<void> _checkRole() async {
    final prefs = await SharedPreferences.getInstance();
    // Đảm bảo role của bạn khớp với dữ liệu lưu trong DB (admin, boss, v.v.)
    setState(() => _role = prefs.getString('role') ?? 'user');
  }

  Future<void> _fetchJobs() async {
    setState(() => _isLoading = true);
    // Lưu ý: Nếu chọn "Tất cả", bạn có thể cần truyền giá trị rỗng hoặc 'Tất cả' tùy vào API PHP của bạn
    final regionParam = _selectedRegion == 'Tất cả' ? '' : _selectedRegion;
    final url = Uri.parse('https://nhjob.online/api/posts/get_jobs.php?category=lao_dong&region=$regionParam');
    
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          _jobs = jsonDecode(utf8.decode(response.bodyBytes));
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Đơn hàng lao động")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButton<String>(
              value: _selectedRegion,
              isExpanded: true,
              items: ['Tất cả', 'Đài Bắc', 'Đài Trung', 'Đài Nam', 'Cao Hùng']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (val) {
                setState(() => _selectedRegion = val!);
                _fetchJobs();
              },
            ),
          ),
          Expanded(
            child: _isLoading 
                ? const Center(child: CircularProgressIndicator()) 
                : _jobs.isEmpty 
                    ? const Center(child: Text("Không có đơn hàng nào"))
                    : ListView.builder(
                        itemCount: _jobs.length,
                        itemBuilder: (ctx, i) => ListTile(
                          title: Text(_jobs[i]['title'] ?? 'Không tiêu đề'),
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (ctx) => JobDetailScreen(job: _jobs[i]))),
                        ),
                      ),
          )
        ],
      ),
      floatingActionButton: (_role == 'admin') 
          ? FloatingActionButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (ctx) => const FormDangTinScreen(title: 'Đăng tin lao động', category: 'lao_dong')))
                  .then((_) => _fetchJobs()), // Load lại list sau khi đăng xong
              child: const Icon(Icons.add),
            ) 
          : null,
    );
  }
}
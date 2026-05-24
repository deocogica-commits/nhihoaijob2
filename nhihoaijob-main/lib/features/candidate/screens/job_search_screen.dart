import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dangtin.dart';
import 'job_detail_screen.dart';

class JobSearchScreen extends StatefulWidget {
  const JobSearchScreen({super.key});

  @override
  State<JobSearchScreen> createState() => _JobSearchScreenState();
}

class _JobSearchScreenState extends State<JobSearchScreen> {
  String _currentRole = 'user';
  String _selectedCategory = 'Tất cả'; 
  String _selectedRegion = 'Tất cả';   
  List<dynamic> _jobs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserRole();
    _fetchJobs();
  }

  Future<void> _loadUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _currentRole = prefs.getString('role') ?? 'user');
  }

  // Sửa lại hàm này để xử lý query string chính xác
  Future<void> _fetchJobs() async {
    setState(() => _isLoading = true);
    
    // Nếu chọn 'Tất cả' thì gửi chuỗi rỗng hoặc 'Tất cả' để PHP xử lý
    final url = Uri.parse(
        'https://nhjob.online/api/posts/get_jobs.php?category=$_selectedCategory&region=$_selectedRegion'
    );
    
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          _jobs = jsonDecode(utf8.decode(response.bodyBytes));
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _showLocationPicker(String title, String categoryKey) {
    final List<String> locations = ['Tất cả', 'Đài Bắc', 'Đài Trung', 'Đài Nam', 'Cao Hùng'];
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Chọn khu vực: $title', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ...locations.map((loc) => ListTile(
              title: Text(loc),
              onTap: () {
                setState(() {
                  _selectedCategory = categoryKey; 
                  _selectedRegion = loc;
                });
                _fetchJobs();
                Navigator.pop(context);
              },
            )),
          ],
        ),
      ),
    );
  }

  void _showPostOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(30),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('Đăng tin', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            _buildOptionItem(Remix.ship_2_line, 'Lao động', 'lao_dong'),
            _buildOptionItem(Remix.exchange_line, 'Chuyển chủ', 'chuyen_chu'),
          ])
        ]),
      ),
    );
  }

  Widget _buildOptionItem(IconData icon, String title, String category) => GestureDetector(
    onTap: () {
      Navigator.pop(context);
      Navigator.push(context, MaterialPageRoute(builder: (context) => FormDangTinScreen(title: 'Đăng tin $title', category: category))).then((_) => _fetchJobs());
    },
    child: Column(children: [
      CircleAvatar(radius: 28, backgroundColor: const Color(0xFFF4F7FA), child: Icon(icon, color: const Color(0xFFE24C33))), 
      const SizedBox(height: 8), 
      Text(title)
    ]),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FA),
      body: SafeArea(
        child: Column(
          children: [
            const Padding(padding: EdgeInsets.all(24), child: Text('Tìm kiếm việc làm', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold))),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(children: [
                _buildCategoryCard('Tìm đơn hàng', 'lao_dong', const Color(0xFFE24C33)),
                const SizedBox(width: 16),
                _buildCategoryCard('Chuyển chủ', 'chuyen_chu', Colors.blueAccent),
              ]),
            ),

            if (_currentRole != 'worker')
              Padding(padding: const EdgeInsets.only(top: 20), child: ElevatedButton(onPressed: _showPostOptions, child: const Text("Đăng tin mới"))),

            // Hiển thị bộ lọc đang chọn
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text("Đang lọc: $_selectedCategory | $_selectedRegion", style: const TextStyle(color: Colors.grey)),
            ),

            Expanded(
              child: _isLoading 
                ? const Center(child: CircularProgressIndicator()) 
                : _jobs.isEmpty 
                  ? const Center(child: Text("Không có tin nào phù hợp"))
                  : ListView.builder(
                      itemCount: _jobs.length,
                      itemBuilder: (context, index) => ListTile(
                        title: Text(_jobs[index]['title'] ?? 'Không tiêu đề'),
                        subtitle: Text("${_jobs[index]['region'] ?? 'Chưa rõ'} - ${_jobs[index]['category'] ?? ''}"),
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => JobDetailScreen(job: _jobs[index]))),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(String title, String categoryKey, Color color) => Expanded(
    child: GestureDetector(
      onTap: () => _showLocationPicker(title, categoryKey),
      child: Container(
        height: 100, 
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(20)), 
        child: Center(child: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))
      ),
    ),
  );
}
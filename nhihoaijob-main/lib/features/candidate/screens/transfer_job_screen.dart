import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy_localization/easy_localization.dart';
import 'dangtin.dart';
import 'job_detail_screen.dart';

class TransferJobScreen extends StatefulWidget {
  const TransferJobScreen({super.key});
  @override
  State<TransferJobScreen> createState() => _TransferJobScreenState();
}

class _TransferJobScreenState extends State<TransferJobScreen> {
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
    setState(() => _role = prefs.getString('role') ?? 'user');
  }

  Future<void> _fetchJobs() async {
    setState(() => _isLoading = true);
    final regionParam = _selectedRegion == 'Tất cả' ? '' : _selectedRegion;
    final url = Uri.parse('https://nhjob.online/api/posts/get_jobs.php?category=chuyen_chu&region=$regionParam');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200 && mounted) {
        setState(() {
          _jobs = jsonDecode(utf8.decode(response.bodyBytes));
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<String> regions = ['Tất cả', 'Đài Bắc', 'Đài Trung', 'Đài Nam', 'Cao Hùng'];

    return Scaffold(
      appBar: AppBar(title: Text("transfer_job.title".tr())),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButton<String>(
              value: _selectedRegion,
              isExpanded: true,
              items: regions.map((e) => DropdownMenuItem(
                value: e,
                child: Text(e == 'Tất cả' ? 'transfer_job.all'.tr() : 'transfer_job.region_${_mapRegionKey(e)}'.tr()),
              )).toList(),
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
                    ? Center(child: Text("transfer_job.no_jobs".tr()))
                    : ListView.builder(
                        itemCount: _jobs.length,
                        itemBuilder: (ctx, i) => ListTile(
                          title: Text(_jobs[i]['title'] ?? 'transfer_job.no_title'.tr()),
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (ctx) => JobDetailScreen(job: _jobs[i]))),
                        ),
                      ),
          )
        ],
      ),
      floatingActionButton: (_role == 'admin')
          ? FloatingActionButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (ctx) => FormDangTinScreen(title: 'transfer_job.btn_post_title'.tr(), category: 'chuyen_chu')))
                  .then((_) => _fetchJobs()),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  String _mapRegionKey(String region) {
    switch (region) {
      case 'Đài Bắc': return 'tai_bac';
      case 'Đài Trung': return 'tai_trung';
      case 'Đài Nam': return 'tai_nam';
      case 'Cao Hùng': return 'cao_hung';
      default: return 'all';
    }
  }
}
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';
import 'job_detail_screen.dart';

class RegionJobScreen extends StatefulWidget {
  final String regionName;
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

  String _normalizeString(String str) {
    const String v = 'àáạảãâầấậẩẫăằắặẳẵèéẹẻẽêềếệểễìíịỉĩòóọỏõôồốộổỗơờớợởỡùúụủũưừứựửữỳýỵỷỹđ';
    const String l = 'aaaaaaaaaaaaaaaaaeeeeeeeeeeeiiiiiooooooooooooooooouuuuuuuuuuuyyyyyd';
    String result = str.toLowerCase();
    for (int i = 0; i < v.length; i++) result = result.replaceAll(v[i], l[i]);
    return result.replaceAll(RegExp(r'[-–—• ]'), '').trim();
  }

  Future<void> _fetchJobsByRegion() async {
    final url = Uri.parse('https://nhjob.online/api/posts/get_jobs.php');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        if (data is List && mounted) {
          setState(() {
            _allJobs = data;
            _filteredJobs = _allJobs.where((job) {
              if (job['region'] == null) return false;
              final cleanJobRegion = _normalizeString(job['region'].toString());
              final cleanTarget = _normalizeString(widget.regionName);
              String core = ['bac', 'trung', 'nam', 'hung'].firstWhere((k) => cleanTarget.contains(k), orElse: () => cleanTarget);
              return cleanJobRegion.contains(core);
            }).toList();
            _isLoading = false;
          });
        }
      } else {
        if (mounted) setState(() { _errorMessage = 'region_job.error_api'.tr(namedArgs: {'v': response.statusCode.toString()}); _isLoading = false; });
      }
    } catch (e) {
      if (mounted) setState(() { _errorMessage = 'region_job.error_net'.tr(); _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FA),
      appBar: AppBar(
        title: Text('region_job.title'.tr(namedArgs: {'v': widget.regionName}), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18)),
        backgroundColor: const Color(0xFFE24C33),
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20), onPressed: () => Navigator.pop(context)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFE24C33)))
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!, style: const TextStyle(color: Colors.redAccent)))
              : _filteredJobs.isEmpty
                  ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(Icons.work_off_outlined, size: 60, color: Colors.grey.shade400),
                      Text('region_job.empty_msg'.tr(namedArgs: {'v': widget.regionName}), style: TextStyle(color: Colors.grey.shade600, fontSize: 15)),
                    ]))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      itemCount: _filteredJobs.length,
                      itemBuilder: (context, index) => _buildJobCard(_filteredJobs[index]),
                    ),
    );
  }

  Widget _buildJobCard(Map<String, dynamic> job) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 2))]),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => JobDetailScreen(job: job))),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFFF4F7FA), borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.business_center_outlined, color: Color(0xFFE24C33), size: 24)),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(job['title'] ?? 'region_job.no_title'.tr(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15), overflow: TextOverflow.ellipsis),
              const SizedBox(height: 6),
              Text(
                '${'region_job.region'.tr(namedArgs: {'v': job['region'] ?? ''})} • ${'region_job.salary'.tr(namedArgs: {'v': job['salary'] ?? ''})}', 
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13), 
                overflow: TextOverflow.ellipsis
              ),
            ])),
          ]),
        ),
      ),
    );
  }
} 
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';
import 'dangtin.dart';

class JobDetailScreen extends StatelessWidget {
  final Map<dynamic, dynamic> job;
  const JobDetailScreen({Key? key, required this.job}) : super(key: key);

  Future<bool> _canDeleteJob() async {
    final prefs = await SharedPreferences.getInstance();
    final currentUserId = prefs.getString('user_id') ?? prefs.getString('id') ?? '';
    final jobUserId = job['user_id']?.toString() ?? '';
    final role = prefs.getString('role') ?? 'worker';

    if (role == 'admin') return true;
    if (role == 'hr' || role == 'boss' || role == 'employer') {
      return currentUserId.isNotEmpty && currentUserId == jobUserId;
    }
    return false;
  }

  Future<void> _openEditScreen(BuildContext context) async {
    final refresh = await Navigator.push(context, MaterialPageRoute(builder: (context) => FormDangTinScreen(title: 'Cập nhật bài đăng', category: job['category']?.toString() ?? '', existingJob: job)));
    if (refresh == true && context.mounted) Navigator.pop(context, true);
  }

  Future<void> _confirmDelete(BuildContext context) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('job_detail.confirm_title'.tr()),
        content: Text('job_detail.confirm_msg'.tr()),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text('job_detail.btn_cancel'.tr())),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text('job_detail.btn_delete'.tr(), style: const TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm == true && context.mounted) await _deleteJob(context);
  }

  Future<void> _deleteJob(BuildContext context) async {
    final url = Uri.parse('https://nhjob.online/api/posts/delete_job.php');
    final prefs = await SharedPreferences.getInstance();
    final role = prefs.getString('role') ?? 'worker';
    final currentUserId = prefs.getString('user_id') ?? prefs.getString('id') ?? '';
    showDialog(context: context, barrierDismissible: false, builder: (_) => const Center(child: CircularProgressIndicator(color: Colors.white)));
    try {
      final response = await http.post(url, headers: {"Content-Type": "application/json"}, body: jsonEncode({"id": job['id'].toString(), "user_id": currentUserId, "role": role})).timeout(const Duration(seconds: 10));
      if (!context.mounted) return;
      Navigator.pop(context);
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('job_detail.success_delete'.tr()), backgroundColor: Colors.green));
        Navigator.pop(context, true);
      } else {
        _showErrorDialog(context, data['message'] ?? 'job_detail.err_server'.tr());
      }
    } catch (e) {
      if (!context.mounted) return;
      Navigator.pop(context);
      _showErrorDialog(context, '${'job_detail.err_connect'.tr()}: $e');
    }
  }

  void _showErrorDialog(BuildContext context, String msg) {
    showDialog(context: context, builder: (context) => AlertDialog(title: Text('job_detail.notify'.tr()), content: Text(msg), actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text('job_detail.btn_close'.tr()))]));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(job['title'] ?? 'job_detail.title_default'.tr(), style: const TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFFE24C33), iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          FutureBuilder<bool>(
            future: _canDeleteJob(),
            builder: (context, snapshot) {
              if (snapshot.data != true) return const SizedBox.shrink();
              return Row(mainAxisSize: MainAxisSize.min, children: [
                IconButton(icon: const Icon(Icons.edit, color: Colors.white), onPressed: () => _openEditScreen(context)),
                IconButton(icon: const Icon(Icons.delete_forever, color: Colors.white, size: 28), onPressed: () => _confirmDelete(context)),
              ]);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(job['title'] ?? 'job_detail.no_title'.tr(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
            const SizedBox(height: 20),
            _buildDetailRow(Icons.category, 'job_detail.category'.tr(), job['category']),
            _buildDetailRow(Icons.location_on, 'job_detail.region'.tr(), job['region']),
            _buildDetailRow(Icons.attach_money, 'job_detail.salary'.tr(), job['salary']),
            _buildDetailRow(Icons.business, 'job_detail.company'.tr(), job['company_name']),
            _buildDetailRow(Icons.phone, 'job_detail.contact'.tr(), job['contact_phone']),
            const SizedBox(height: 20),
            Text('job_detail.desc_label'.tr(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            Text(job['description'] ?? 'job_detail.no_desc'.tr()),
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
          Expanded(child: Text(value ?? 'job_detail.not_updated'.tr())),
        ],
      ),
    );
  }
} 
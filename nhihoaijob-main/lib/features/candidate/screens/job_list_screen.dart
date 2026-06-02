import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:easy_localization/easy_localization.dart'; // Đã thêm
import 'job_detail_screen.dart';

class JobsListScreen extends StatefulWidget {
  final String category;
  final String region;

  const JobsListScreen({super.key, required this.category, this.region = ''});

  @override
  State<JobsListScreen> createState() => _JobsListScreenState();
}

class _JobsListScreenState extends State<JobsListScreen> {
  late Future<List<dynamic>> _jobsFuture;

  @override
  void initState() {
    super.initState();
    _jobsFuture = _fetchJobs();
  }

  Future<List<dynamic>> _fetchJobs() async {
    final url = Uri.parse('https://nhjob.online/api/posts/get_filtered_jobs.php?category=${widget.category}&region=${widget.region}');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } else {
      throw Exception('Failed to load data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${'jobs_list.title'.tr()}${widget.category.toUpperCase()}"),
        backgroundColor: const Color(0xFFE24C33),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _jobsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFFE24C33)));
          } else if (snapshot.hasError) {
            return Center(child: Text("${'jobs_list.error'.tr()}${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("jobs_list.empty".tr()));
          }

          final jobs = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: jobs.length,
            itemBuilder: (context, index) {
              final job = jobs[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: const Icon(Icons.work_outline, color: Color(0xFFE24C33)),
                  title: Text(job['title'] ?? 'jobs_list.no_title'.tr(), style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text("${job['region']} • ${job['salary']}"),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => JobDetailScreen(job: job)));
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
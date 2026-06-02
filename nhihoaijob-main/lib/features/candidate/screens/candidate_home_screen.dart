import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:easy_localization/easy_localization.dart'; // Đã thêm
import 'dangtin.dart';
import 'job_detail_screen.dart'; 
import 'job_search_screen.dart';
import 'region_job_screen.dart'; 
import 'candidate_profile_screen.dart';

class CandidateHomeScreen extends StatefulWidget {
  const CandidateHomeScreen({super.key});

  @override
  State<CandidateHomeScreen> createState() => _CandidateHomeScreenState();
}

class _CandidateHomeScreenState extends State<CandidateHomeScreen> {
  late PageController _bannerController;
  final TextEditingController _searchController = TextEditingController();
  String _currentRole = 'user'; 
  String _userName = 'Người dùng'; 
  List<dynamic> _recentJobs = [];    
  String _searchKeyword = '';
  bool _isLoadingJobs = true;
  String? _avatarUrl;

  final List<String> _bannerImages = [
    'assets/images/banner1.png',  
    'assets/images/banner2.png',
  ];

  final List<Map<String, String>> _regions = [
    {'name': 'ĐÀI BẮC', 'image': 'assets/images/taipei.png'},
    {'name': 'ĐÀI TRUNG', 'image': 'assets/images/taichung.png'},
    {'name': 'ĐÀI NAM', 'image': 'assets/images/tainan.png'},
    {'name': 'CAO HÙNG', 'image': 'assets/images/kaoshong.png'},
  ];

  @override
  void initState() {
    super.initState();
    _bannerController = PageController();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    
    if (mounted) {
      setState(() {
        _currentRole = prefs.getString('role') ?? 'user';
        _avatarUrl = prefs.getString('avatar_url');
        _userName = prefs.getString('user_name') ?? 'Người dùng';
      });
    }
    await _fetchRecentJobs();
  }

  Future<void> _loadAvatar() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload(); 
    final String? newUrl = prefs.getString('avatar_url');
    final String? newName = prefs.getString('user_name');
    
    if (mounted) {
      setState(() {
        _avatarUrl = newUrl;
        if (newName != null) _userName = newName;
      });
    }
  }

  Future<void> _fetchRecentJobs() async {
    final url = Uri.parse('https://nhjob.online/api/posts/get_jobs.php?category=sinh_vien');
    try {
      final response = await http.get(url);
      if (!mounted) return;
      if (response.statusCode == 200) {
        final responseBodyString = utf8.decode(response.bodyBytes);
        final responseData = jsonDecode(responseBodyString);
        if (responseData is List) {
          setState(() {
            _recentJobs = responseData;
            _isLoadingJobs = false;
          });
        }
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingJobs = false);
    }
  }

  Future<void> _handleRefresh() async {
    setState(() => _isLoadingJobs = true);
    await _loadAvatar();
    await _fetchRecentJobs();
  }

  List<dynamic> get _filteredRecentJobs {
    final keyword = _searchKeyword.trim().toLowerCase();
    if (keyword.isEmpty) return _recentJobs;

    return _recentJobs.where((job) {
      if (job is! Map) return false;
      final searchableText = [
        job['title'],
        job['region'],
        job['salary'],
        job['company_name'],
        job['description'],
      ].whereType<Object>().map((value) => value.toString().toLowerCase()).join(' ');

      return searchableText.contains(keyword);
    }).toList();
  }

  @override
  void dispose() {
    _bannerController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color mainColor = Color(0xFFE24C33);
    final filteredRecentJobs = _filteredRecentJobs;
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FA),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _handleRefresh,
          color: mainColor,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                const SizedBox(height: 20),
                _buildHeader(),
                const SizedBox(height: 24),
                _buildHomeSearchBar(mainColor),
                const SizedBox(height: 24),
                _buildBannerSlider(),
                const SizedBox(height: 30),
                _buildSectionTitle('home.regions_title'.tr()),
                const SizedBox(height: 16),
                SizedBox(
                  height: 150,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    itemCount: _regions.length,
                    itemBuilder: (context, index) => _buildRegionCard(context, _regions[index]['name']!, _regions[index]['image']!),
                  ),
                ),
                const SizedBox(height: 30),
                if (_currentRole != 'worker') ...[_buildPostJobButton(context, mainColor), const SizedBox(height: 30)],
                _buildSectionTitle('home.recent_jobs'.tr()),
                const SizedBox(height: 16),
                _isLoadingJobs
                    ? const Center(child: CircularProgressIndicator(color: mainColor))
                    : filteredRecentJobs.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                            child: Text(
                              _searchKeyword.trim().isEmpty
                                  ? 'home.no_jobs'.tr()
                                  : 'home.not_found'.tr(),
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                          )
                        : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        itemCount: filteredRecentJobs.length,
                        itemBuilder: (context, index) => _buildRecentJobCard(mainColor, filteredRecentJobs[index]),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() => Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0), 
      child: Row(children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('home.hello'.tr()), 
          Text('$_userName 👋', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold))
        ]), 
        const Spacer(), 
        GestureDetector(
          onTap: () async {
            final shouldRefresh = await Navigator.push(context, MaterialPageRoute(builder: (context) => const CandidateProfileScreen()));
            if (shouldRefresh == true) {
              await _loadAvatar();
            }
          },
          child: CircleAvatar(
            radius: 20,
            backgroundColor: const Color(0xFFE24C33),
            backgroundImage: (_avatarUrl != null && _avatarUrl!.isNotEmpty) 
                ? NetworkImage(_avatarUrl!) 
                : null,
            child: (_avatarUrl == null || _avatarUrl!.isEmpty) 
                ? Text(_userName.isNotEmpty ? _userName[0].toUpperCase() : 'U', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)) 
                : null,
          ),
        )
      ])
  );

  Widget _buildHomeSearchBar(Color themeColor) => Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(26),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
        ),
        child: TextField(
          controller: _searchController,
          textInputAction: TextInputAction.search,
          onChanged: (value) => setState(() => _searchKeyword = value),
          decoration: InputDecoration(
            hintText: 'home.search_hint'.tr(),
            border: InputBorder.none,
            prefixIcon: const Icon(Remix.search_2_line),
            suffixIcon: _searchKeyword.isEmpty
                ? Icon(Remix.equalizer_line, color: themeColor)
                : IconButton(
                    icon: const Icon(Remix.close_line),
                    color: Colors.grey,
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _searchKeyword = '');
                    },
                  ),
            contentPadding: const EdgeInsets.symmetric(vertical: 15),
          ),
        ),
      ),
  );

  Widget _buildBannerSlider() => SizedBox(height: 160, child: PageView.builder(controller: _bannerController, itemCount: _bannerImages.length, itemBuilder: (context, index) => Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: ClipRRect(borderRadius: BorderRadius.circular(20), child: Image.asset(_bannerImages[index], fit: BoxFit.cover)))));
  Widget _buildSectionTitle(String title) => Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))]));
  Widget _buildRecentJobCard(Color themeColor, Map<String, dynamic> job) => Container(margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)), child: ListTile(leading: CircleAvatar(backgroundColor: const Color(0xFFF4F7FA), child: Icon(Remix.briefcase_line, color: themeColor)), title: Text(job['title'] ?? '', maxLines: 1, overflow: TextOverflow.ellipsis), subtitle: Text('${job['region'] ?? ''} • ${job['salary'] ?? ''}'), trailing: const Icon(Remix.arrow_right_s_line), onTap: () async { final refresh = await Navigator.push(context, MaterialPageRoute(builder: (context) => JobDetailScreen(job: job))); if (refresh == true) _handleRefresh(); }));
  Widget _buildRegionCard(BuildContext context, String name, String imagePath) => GestureDetector(onTap: () async { await Navigator.push(context, MaterialPageRoute(builder: (context) => RegionJobScreen(regionName: name))); _handleRefresh(); }, child: Container(width: 140, margin: const EdgeInsets.only(right: 12), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)), child: Stack(children: [ClipRRect(borderRadius: BorderRadius.circular(20), child: Image.asset(imagePath, fit: BoxFit.cover, width: 140, height: 150)), Center(child: Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))])));
  Widget _buildPostJobButton(BuildContext context, Color themeColor) => Padding(padding: const EdgeInsets.symmetric(horizontal: 24.0), child: InkWell(onTap: () => _showPostOptions(context), child: Container(padding: const EdgeInsets.symmetric(vertical: 14), decoration: BoxDecoration(color: themeColor, borderRadius: BorderRadius.circular(16)), child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Remix.add_circle_line, color: Colors.white), const SizedBox(width: 8), Text('home.post_job'.tr(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))]))));
  
  void _navigateToPostForm(BuildContext context, String title, String category) { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (context) => FormDangTinScreen(title: title, category: category),),).then((_) => _handleRefresh()); }
  
  void _showPostOptions(BuildContext context) { showModalBottomSheet(context: context, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))), builder: (context) => Padding(padding: const EdgeInsets.all(30), child: Column(mainAxisSize: MainAxisSize.min, children: [Text('home.post_options_title'.tr(), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), const SizedBox(height: 30), Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [ _buildOptionItem(context, Remix.user_search_line, 'home.option_student'.tr(), 'sinh_vien'), _buildOptionItem(context, Remix.ship_2_line, 'home.option_worker'.tr(), 'lao_dong'), _buildOptionItem(context, Remix.exchange_line, 'home.option_transfer'.tr(), 'chuyen_chu') ]) ] ))); }
  
  Widget _buildOptionItem(BuildContext context, IconData icon, String title, String category) => Expanded(child: GestureDetector(onTap: () => _navigateToPostForm(context, 'Đăng tin $title', category), child: Column(children: [CircleAvatar(radius: 28, backgroundColor: const Color(0xFFF4F7FA), child: Icon(icon, color: const Color(0xFFE24C33))), const SizedBox(height: 12), Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)) ] )));
}
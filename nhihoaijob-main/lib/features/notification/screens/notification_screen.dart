

import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color zaloBlue = Color(0xFF0068FF);
    const Color backgroundColor = Color(0xFFF4F7FA);

    // Fake data cho danh sách thông báo
    final List<Map<String, dynamic>> notifications = [
      {
        'title': 'Lịch phỏng vấn mới',
        'message': 'TechCorp VN đã gửi cho bạn một lời mời phỏng vấn vào lúc 09:00 sáng mai.',
        'time': '10 phút trước',
        'icon': Remix.calendar_check_line,
        'iconColor': Colors.green,
        'isRead': false,
      },
      {
        'title': 'Hồ sơ của bạn đã được xem',
        'message': 'Nhà tuyển dụng VNG Corporation vừa xem CV của bạn cho vị trí Mobile Developer.',
        'time': '2 giờ trước',
        'icon': Remix.eye_line,
        'iconColor': zaloBlue,
        'isRead': false,
      },
      {
        'title': 'Việc làm mới phù hợp với bạn',
        'message': 'Có 5 việc làm Flutter Developer mới tại TP.HCM vừa được cập nhật.',
        'time': '1 ngày trước',
        'icon': Remix.briefcase_line,
        'iconColor': Colors.orange,
        'isRead': true,
      },
      {
        'title': 'Cập nhật hệ thống',
        'message': 'Job App vừa ra mắt tính năng tạo CV tự động bằng AI. Khám phá ngay!',
        'time': '2 ngày trước',
        'icon': Remix.sparkling_line,
        'iconColor': Colors.purple,
        'isRead': true,
      },
    ];

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            // --- HEADER ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Thông báo',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  TextButton(
                    onPressed: () {
                      // TODO: Đánh dấu tất cả đã đọc
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      'Đánh dấu đã đọc',
                      style: TextStyle(fontSize: 14, color: zaloBlue, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // --- DANH SÁCH THÔNG BÁO ---
            Expanded(
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  final item = notifications[index];
                  final bool isRead = item['isRead'];

                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isRead ? Colors.white : zaloBlue.withOpacity(0.05), // Thông báo chưa đọc nền hơi xanh
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isRead ? Colors.transparent : zaloBlue.withOpacity(0.2), // Viền xanh nhẹ nếu chưa đọc
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Icon thông báo
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: item['iconColor'].withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(item['icon'], color: item['iconColor'], size: 24),
                        ),
                        const SizedBox(width: 16),

                        // Nội dung thông báo
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['title'],
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: isRead ? FontWeight.w600 : FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                item['message'],
                                style: TextStyle(fontSize: 14, color: Colors.grey.shade600, height: 1.4),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                item['time'],
                                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                              ),
                            ],
                          ),
                        ),

                        // Chấm đỏ/xanh báo chưa đọc
                        if (!isRead)
                          Container(
                            margin: const EdgeInsets.only(top: 6),
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(
                              color: zaloBlue,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
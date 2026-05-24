import 'package:equatable/equatable.dart';

class UserSummary extends Equatable {
  const UserSummary({
    required this.id,
    required this.email,
    this.fullName,
    this.role,
    this.emailVerified,
  });

  final int id;
  final String email;
  final String? fullName;
  final String? role;
  final bool? emailVerified;

  // SỬA LẠI HÀM NÀY ĐỂ KHỚP VỚI LOGIN.PHP
  factory UserSummary.fromJson(Map<String, dynamic> json) {
    return UserSummary(
      id: (json['id'] as num).toInt(),
      email: json['email'] as String,
      fullName: json['username'] as String?, // Map từ 'username' của PHP sang fullName
      role: json['role'] as String? ?? 'user', // Lấy role từ PHP, nếu null thì mặc định là 'user'
      emailVerified: true, 
    );
  }

  @override
  List<Object?> get props => [id, email, fullName, role, emailVerified];
}
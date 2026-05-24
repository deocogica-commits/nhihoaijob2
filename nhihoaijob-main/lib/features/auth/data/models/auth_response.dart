import 'package:equatable/equatable.dart';
import 'user_summary.dart';

class AuthResponse extends Equatable {
  const AuthResponse({
    required this.accessToken,
    required this.refreshToken,
    this.tokenType,
    this.expiresInMs,
    this.user,
  });

  final String accessToken;
  final String refreshToken;
  final String? tokenType;
  final int? expiresInMs;
  final UserSummary? user;

  // SỬA LẠI HÀM NÀY ĐỂ PHÒNG TRỪ LỖI KHÔNG CÓ TOKEN TỪ PHP
  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      accessToken: (json['accessToken'] as String?) ?? '', // Thêm ?? '' để không bị lỗi khi PHP không trả về
      refreshToken: (json['refreshToken'] as String?) ?? '', // Thêm ?? '' để không bị lỗi
      tokenType: json['tokenType'] as String?,
      expiresInMs: (json['expiresInMs'] as num?)?.toInt(),
      user: json['user'] != null
          ? UserSummary.fromJson(json['user'] as Map<String, dynamic>)
          : null,
    );
  }

  @override
  List<Object?> get props =>
      [accessToken, refreshToken, tokenType, expiresInMs, user];
}
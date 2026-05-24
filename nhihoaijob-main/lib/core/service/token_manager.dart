import 'package:shared_preferences/shared_preferences.dart';

/// Lưu access/refresh token và thời điểm hết hạn (tính từ `expiresInMs` khi đăng nhập/refresh).
class TokenManager {
  static const _kAccess = 'auth_access_token';
  static const _kRefresh = 'auth_refresh_token';
  static const _kExpiresAt = 'auth_access_expires_at_epoch_ms';

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  String? getAccessToken() => _prefs?.getString(_kAccess);

  String? getRefreshToken() => _prefs?.getString(_kRefresh);

  /// Gợi ý làm mới token trước khi hết hạn (buffer 5 phút).
  bool shouldRefreshToken() {
    final expiresAt = _prefs?.getInt(_kExpiresAt);
    if (expiresAt == null) return false;
    final now = DateTime.now().millisecondsSinceEpoch;
    const bufferMs = 5 * 60 * 1000;
    return now >= (expiresAt - bufferMs);
  }

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    int? expiresInMs,
  }) async {
    final p = _prefs;
    if (p == null) {
      throw StateError('TokenManager chưa init — gọi init() trước.');
    }
    await p.setString(_kAccess, accessToken);
    await p.setString(_kRefresh, refreshToken);
    if (expiresInMs != null) {
      final expiresAt = DateTime.now().millisecondsSinceEpoch + expiresInMs;
      await p.setInt(_kExpiresAt, expiresAt);
    } else {
      await p.remove(_kExpiresAt);
    }
  }

  Future<void> clear() async {
    await _prefs?.remove(_kAccess);
    await _prefs?.remove(_kRefresh);
    await _prefs?.remove(_kExpiresAt);
  }
}

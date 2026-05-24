/// Lỗi do server trả về (4xx/5xx có body lỗi).
class ServerException implements Exception {
  ServerException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

/// 401/403 sau khi refresh thất bại hoặc phiên không hợp lệ.
class UnauthorizedException implements Exception {
  UnauthorizedException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Lỗi mạng, timeout, parse JSON...
class NetworkException implements Exception {
  NetworkException(this.message);

  final String message;

  @override
  String toString() => message;
}

# NH.Job (tuanhoai01)

Ứng dụng Flutter tuyển dụng việc làm.

## Kiến trúc và luồng dữ liệu

Luồng chuẩn trong dự án:

**UI (Widget / Screen) → Bloc → Service → Repository → HttpService**

| Tầng            | Trách nhiệm                                                                                                                                        |
| --------------- | -------------------------------------------------------------------------------------------------------------------------------------------------- |
| **UI**          | Hiển thị, nhận input, gửi `Event` cho Bloc; lắng nghe `State` (BlocBuilder / BlocListener). Không gọi API trực tiếp.                               |
| **Bloc**        | Quản lý trạng thái màn hình, xử lý sự kiện, gọi **Service** (không gọi Repository từ UI).                                                          |
| **Service**     | Logic nghiệp vụ (ví dụ sau đăng nhập: lưu token qua `TokenManager`), điều phối một hoặc nhiều repository.                                          |
| **Repository**  | Gọi API cụ thể qua `HttpService`, map JSON → model. Không lưu token (trừ khi có quy ước riêng — hiện tại token do `AuthService` + `TokenManager`). |
| **HttpService** | HTTP (base URL, header, refresh token, xử lý 401).                                                                                                 |

### Auth & token

- Đăng nhập: `POST /api/auth/login` (xem `AUTH_API_README.md`).
- Token lưu bằng **SharedPreferences** qua `TokenManager` (access, refresh, thời điểm hết hạn từ `expiresInMs`).
- Làm mới token: `POST /api/auth/refresh` với body `{ "refreshToken": "..." }` — logic nằm trong `HttpService._refreshTokenIfNeeded`.

### Cấu trúc thư mục gợi ý (`lib/`)

- `core/` — `constants/` (`api_endpoints`), `error/`, `service/` (`http_service`, `token_manager`).
- `features/<feature>/` — `data/` (models, repositories), `services/`, `bloc/`, `screens/`.

## Quy tắc dự án (rules)

1. **Không** gọi `HttpService` từ widget; chỉ qua Repository (và Service khi cần logic thêm).
2. **Không** gọi Repository từ UI; UI chỉ tương tác Bloc (hoặc callback được inject từ trên xuống trong trường hợp đặc biệt).
3. **Models** đặt trong `features/.../data/models/`, parse JSON rõ ràng (`fromJson`).
4. **Lỗi API**: dùng các exception trong `core/error/exceptions.dart` (`ServerException`, `UnauthorizedException`, `NetworkException`); Bloc map sang message thân thiện cho người dùng.
5. **Base URL & path**: `HttpService.baseUrl` cho host; mọi path API khai báo tập trung trong `lib/core/constants/api_endpoints.dart` (`ApiEndpoints`), repository chỉ dùng hằng số đó (không chuỗi path rải rác).
6. **Đăng xuất**: gọi `AuthService.logout()` (xóa token) trước khi điều hướng về màn đăng nhập.
7. **Dependency injection**: `AuthService` cung cấp qua `RepositoryProvider` ở `main.dart`; `LoginScreen` tự bọc `BlocProvider<LoginBloc>` ở đầu file màn hình.

## Chạy dự án

```bash
flutter pub get
flutter run
```

## Tài liệu API

Chi tiết endpoint auth: [AUTH_API_README.md](AUTH_API_README.md).

## Tài nguyên Flutter

- [Flutter documentation](https://docs.flutter.dev/)

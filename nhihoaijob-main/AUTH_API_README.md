# API Authentication — Tài liệu cho Frontend

Base URL mặc định (dev): `http://localhost:8080`  
Prefix tất cả endpoint auth: **`/api/auth`**

---

## Định dạng response chung

Mọi API trả về JSON theo cấu trúc:

| Trường      | Kiểu    | Mô tả                  |
| ----------- | ------- | ---------------------- |
| `success`   | boolean | `true` khi thành công  |
| `message`   | string  | Thông báo              |
| `data`      | any     | Dữ liệu (tuỳ endpoint) |
| `timestamp` | string  | Thời điểm server       |

Lỗi validation (400) có thể trả `data` là object map `field → message`.

---

## Header bảo vệ (JWT)

Các endpoint **cần đăng nhập** gửi kèm:

```http
Authorization: Bearer <accessToken>
Content-Type: application/json
```

---

## Vai trò (`role`)

Giá trị trong `user.role` (enum):

| Giá trị         | Mô tả                           |
| --------------- | ------------------------------- |
| `ROLE_ADMIN`    | Quản trị                        |
| `ROLE_HR`       | Nhà tuyển dụng                  |
| `ROLE_CUSTOMER` | Ứng viên (mặc định khi đăng ký) |

---

## 1. Đăng ký

**Endpoint:** `POST /api/auth/register`  
**Auth:** không cần

**Body (JSON):**

| Trường     | Bắt buộc | Kiểu   | Ghi chú           |
| ---------- | -------- | ------ | ----------------- |
| `email`    | Có       | string | Email hợp lệ      |
| `password` | Có       | string | Tối thiểu 8 ký tự |
| `fullName` | Không    | string | Tối đa 150 ký tự  |

**Ví dụ:**

```json
{
  "email": "user@example.com",
  "password": "password123",
  "fullName": "Nguyen Van A"
}
```

**Response `data`:** string (thông báo đăng ký thành công, cần kiểm tra email).

---

## 2. Đăng nhập

**Endpoint:** `POST /api/auth/login`  
**Auth:** không cần

**Body:**

| Trường     | Bắt buộc | Kiểu   |
| ---------- | -------- | ------ |
| `email`    | Có       | string |
| `password` | Có       | string |

**Ví dụ:**

```json
{
  "email": "user@example.com",
  "password": "password123"
}
```

**Response `data` — `AuthResponse`:**

| Trường         | Kiểu   | Mô tả                                          |
| -------------- | ------ | ---------------------------------------------- |
| `accessToken`  | string | JWT gọi API được bảo vệ                        |
| `refreshToken` | string | Dùng để lấy access token mới                   |
| `tokenType`    | string | Thường là `"Bearer"`                           |
| `expiresInMs`  | number | Thời gian sống access token (ms)               |
| `user`         | object | Thông tin user (xem `UserSummaryDto` bên dưới) |

**`UserSummaryDto`:**

| Trường          | Kiểu    |
| --------------- | ------- | -------------------------------------------- |
| `id`            | number  |
| `email`         | string  |
| `fullName`      | string  |
| `role`          | string  | `ROLE_ADMIN` \| `ROLE_HR` \| `ROLE_CUSTOMER` |
| `emailVerified` | boolean |

---

## 3. Làm mới token (refresh)

**Endpoint:** `POST /api/auth/refresh`  
**Auth:** không cần (dùng refresh token trong body)

**Body:**

| Trường         | Bắt buộc | Kiểu   |
| -------------- | -------- | ------ |
| `refreshToken` | Có       | string |

**Ví dụ:**

```json
{
  "refreshToken": "<refresh_token_tu_login>"
}
```

**Response `data`:** cùng cấu trúc `AuthResponse` như đăng nhập (token mới, refresh token có thể được xoay).

---

## 4. Xác thực email

**Endpoint:** `GET /api/auth/verify-email`  
**Auth:** không cần

**Query:**

| Tham số | Bắt buộc | Mô tả                     |
| ------- | -------- | ------------------------- |
| `token` | Có       | Token trong email đăng ký |

**Ví dụ URL (FE có thể redirect hoặc gọi fetch):**

```
GET /api/auth/verify-email?token=<token>
```

**Response `data`:** string (thông báo xác thực thành công).

---

## 5. Quên mật khẩu

**Endpoint:** `POST /api/auth/forgot-password`  
**Auth:** không cần

**Body:**

| Trường  | Bắt buộc | Kiểu   |
| ------- | -------- | ------ |
| `email` | Có       | string |

**Ví dụ:**

```json
{
  "email": "user@example.com"
}
```

**Response `data`:** string (thông báo chung; không tiết lộ email có tồn tại hay không).

**Gợi ý FE:** Link trong email trỏ về trang frontend (ví dụ `/reset-password?token=...`), sau đó FE gọi API **Đặt lại mật khẩu** bên dưới.

---

## 6. Đặt lại mật khẩu (sau email quên mật khẩu)

**Endpoint:** `POST /api/auth/reset-password`  
**Auth:** không cần

**Body:**

| Trường        | Bắt buộc | Kiểu   | Ghi chú           |
| ------------- | -------- | ------ | ----------------- |
| `token`       | Có       | string | Token trong email |
| `newPassword` | Có       | string | Tối thiểu 8 ký tự |

**Ví dụ:**

```json
{
  "token": "<token_tu_query_string>",
  "newPassword": "newSecurePass123"
}
```

**Response `data`:** string (thông báo đặt lại thành công).

---

## 7. Đổi mật khẩu (đã đăng nhập)

**Endpoint:** `POST /api/auth/change-password`  
**Auth:** **Bearer access token**

**Body:**

| Trường            | Bắt buộc | Kiểu   | Ghi chú           |
| ----------------- | -------- | ------ | ----------------- |
| `currentPassword` | Có       | string | Mật khẩu hiện tại |
| `newPassword`     | Có       | string | Tối thiểu 8 ký tự |

**Ví dụ:**

```json
{
  "currentPassword": "oldPass123",
  "newPassword": "newPass456789"
}
```

**Lưu ý:** Sau khi đổi mật khẩu, server thu hồi refresh token cũ — FE nên bắt user đăng nhập lại hoặc chỉ giữ access token đến khi hết hạn.

---

## 8. Đăng xuất

**Endpoint:** `POST /api/auth/logout`  
**Auth:** **Bearer access token**

**Body (tùy chọn):**

| Trường         | Bắt buộc | Kiểu   | Mô tả                                                                                                                          |
| -------------- | -------- | ------ | ------------------------------------------------------------------------------------------------------------------------------ |
| `refreshToken` | Không    | string | Nếu gửi: chỉ thu hồi session tương ứng refresh token đó. Nếu không gửi / body rỗng: thu hồi **tất cả** refresh token của user. |

**Ví dụ chỉ đăng xuất một thiết bị:**

```json
{
  "refreshToken": "<refresh_token_hien_tai>"
}
```

**Ví dụ đăng xuất mọi thiết bị:** gửi `{}` hoặc không gửi body.

---

## 9. Thông tin user hiện tại

**Endpoint:** `GET /api/auth/me`  
**Auth:** **Bearer access token**

**Body:** không có.

**Response `data`:** `UserSummaryDto` (giống phần trong `AuthResponse.user`).

---

## Gợi ý tích hợp FE

1. Sau **login** / **refresh**: lưu `accessToken` (memory hoặc secure storage tuỳ chính sách), lưu `refreshToken` nếu cần “nhớ đăng nhập”.
2. Mọi request protected: header `Authorization: Bearer <accessToken>`.
3. Khi `401`: thử `POST /api/auth/refresh` với `refreshToken`; thành công thì cập nhật token và gọi lại request; thất bại thì đưa user về màn đăng nhập.
4. **Đăng ký:** sau khi gọi register, hướng dẫn user mở email và bấm link (hoặc FE gọi `verify-email` với `token` nếu luồng của bạn truyền token qua URL).

---

## Swagger (tham khảo)

- UI: `/swagger-ui.html`
- OpenAPI JSON: `/v3/api-docs`

Trên Swagger có thể bấm **Authorize** và nhập: `Bearer <accessToken>` để thử các API cần JWT.

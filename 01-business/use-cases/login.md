# UC-AUTH-001 — Đăng nhập

## Metadata

| Thuộc tính | Giá trị |
|---|---|
| ID | `UC-AUTH-001` |
| Tác nhân | Khách hàng, Quản lý cửa hàng |
| Mức nguồn | **FORMAL** |
| Nguồn | Chương 3.2.2, tr. 46 |

> **Mức nguồn:** Có biểu đồ/bảng đặc tả use case trực tiếp trong Chương 3.2.2.

## Mục tiêu

Đăng nhập theo phạm vi nghiệp vụ được report mô tả.

## Điều kiện trước

Người dùng đã có tài khoản.

## Điều kiện sau

Người dùng đăng nhập thành công và có thể truy cập chức năng phù hợp vai trò.

## Luồng chính

1. Người dùng mở trang đăng nhập.
2. Nhập email hoặc số điện thoại và mật khẩu.
3. Hệ thống kiểm tra thông tin đăng nhập.
4. Nếu hợp lệ, hệ thống xác thực thành công và chuyển vào hệ thống.

### Luồng thay thế: Google Login

1. Người dùng chọn tiếp tục với Google.
2. Google Identity Services trả về ID token cho browser.
3. Backend verify chữ ký, issuer, audience và `email_verified` của token.
4. Backend tìm account đã liên kết theo Google `sub`; với lần đầu, email đã
   verify chỉ được dùng để liên kết vào một account local đang tồn tại.
5. Nếu account hợp lệ, hệ thống phát hành cùng cặp JWT như đăng nhập mật khẩu.

MVP không tự provision account từ Google vì account local vẫn yêu cầu phone,
password và địa chỉ. Google account chưa liên kết phải hoàn tất đăng ký local
trước.

## Luồng thay thế / ngoại lệ

- Thông tin đăng nhập không hợp lệ → yêu cầu nhập lại.
- Người dùng chọn quên mật khẩu.
- Người dùng hủy đăng nhập.
- ID token Google không hợp lệ, chưa verify email, chưa cấu hình client ID hoặc
  chưa liên kết account local.

## Ghi chú phạm vi

Tài liệu này chỉ tái cấu trúc nội dung có căn cứ từ report. Các rule chưa được nguồn xác định (ví dụ quy tắc tồn kho chi tiết, số lần review, discount stacking, AI clarification bắt buộc) không được tự bổ sung.

# UC-AUTH-005 — Đổi mật khẩu

## Metadata

| Thuộc tính | Giá trị |
|---|---|
| ID | `UC-AUTH-005` |
| Tác nhân | Khách hàng, Quản lý cửa hàng |
| Mức nguồn | **REQUIREMENT** |
| Nguồn | Chương 3.1.2, tr. 39–41 |

> **Mức nguồn:** Có trong yêu cầu chức năng/biểu đồ tổng quát nhưng không có bảng đặc tả riêng.

## Mục tiêu

Đổi mật khẩu theo phạm vi nghiệp vụ được report mô tả.

## Điều kiện trước

Người dùng đang có tài khoản hợp lệ.

## Điều kiện sau

Mật khẩu được đổi sau khi xác minh OTP.

## Luồng chính

1. Người dùng nhập mật khẩu cũ và mật khẩu mới.
2. Hệ thống gửi OTP đến email đăng ký.
3. Người dùng nhập OTP.
4. Hệ thống xác minh OTP và cập nhật mật khẩu.

## Luồng thay thế / ngoại lệ

- Mật khẩu cũ sai.
- OTP sai/hết hiệu lực.
- Mật khẩu mới không thỏa ràng buộc.

## Ghi chú phạm vi

Tài liệu này chỉ tái cấu trúc nội dung có căn cứ từ report. Các rule chưa được nguồn xác định (ví dụ quy tắc tồn kho chi tiết, số lần review, discount stacking, AI clarification bắt buộc) không được tự bổ sung.

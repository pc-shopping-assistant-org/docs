# UC-AUTH-002 — Đăng ký tài khoản

## Metadata

| Thuộc tính | Giá trị |
|---|---|
| ID | `UC-AUTH-002` |
| Tác nhân | Khách hàng |
| Mức nguồn | **FORMAL** |
| Nguồn | Chương 3.2.2, tr. 47–48 |

> **Mức nguồn:** Có biểu đồ/bảng đặc tả use case trực tiếp trong Chương 3.2.2.

## Mục tiêu

Đăng ký tài khoản theo phạm vi nghiệp vụ được report mô tả.

## Điều kiện trước

Khách hàng chưa có tài khoản.

## Điều kiện sau

Tài khoản khách hàng mới được tạo thành công.

## Luồng chính

1. Mở trang đăng ký.
2. Nhập thông tin tài khoản, email, số điện thoại, họ tên, ngày sinh, địa chỉ, mật khẩu.
3. Hệ thống kiểm tra dữ liệu và gửi OTP đến email.
4. Khách hàng nhập OTP.
5. Hệ thống xác minh OTP.
6. Hệ thống tạo tài khoản và chuyển tới đăng nhập.

## Luồng thay thế / ngoại lệ

- Email đã tồn tại.
- Số điện thoại đã tồn tại.
- OTP không hợp lệ.
- Dữ liệu không thỏa ràng buộc.
- Người dùng hủy đăng ký.

## Ghi chú phạm vi

Tài liệu này chỉ tái cấu trúc nội dung có căn cứ từ report. Các rule chưa được nguồn xác định (ví dụ quy tắc tồn kho chi tiết, số lần review, discount stacking, AI clarification bắt buộc) không được tự bổ sung.

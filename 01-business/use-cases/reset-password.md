# UC-AUTH-003 — Khôi phục/đặt lại mật khẩu

## Metadata

| Thuộc tính | Giá trị |
|---|---|
| ID | `UC-AUTH-003` |
| Tác nhân | Khách hàng, Quản lý cửa hàng |
| Mức nguồn | **FORMAL** |
| Nguồn | Chương 3.2.2, tr. 48 |

> **Mức nguồn:** Có biểu đồ/bảng đặc tả use case trực tiếp trong Chương 3.2.2.

## Mục tiêu

Khôi phục/đặt lại mật khẩu theo phạm vi nghiệp vụ được report mô tả.

## Điều kiện trước

Tài khoản đã tồn tại.

## Điều kiện sau

Mật khẩu mới được thiết lập thành công.

## Luồng chính

1. Chọn quên mật khẩu.
2. Nhập email hoặc số điện thoại.
3. Hệ thống kiểm tra và gửi OTP.
4. Người dùng nhập OTP.
5. Hệ thống xác minh OTP.
6. Người dùng nhập mật khẩu mới.
7. Hệ thống cập nhật mật khẩu.

## Luồng thay thế / ngoại lệ

- Thông tin tài khoản không hợp lệ.
- OTP không hợp lệ.
- Người dùng hủy thao tác.

## Ghi chú phạm vi

Tài liệu này chỉ tái cấu trúc nội dung có căn cứ từ report. Các rule chưa được nguồn xác định (ví dụ quy tắc tồn kho chi tiết, số lần review, discount stacking, AI clarification bắt buộc) không được tự bổ sung.

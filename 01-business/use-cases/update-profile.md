# UC-AUTH-006 — Cập nhật thông tin cá nhân

## Metadata

| Thuộc tính | Giá trị |
|---|---|
| ID | `UC-AUTH-006` |
| Tác nhân | Khách hàng |
| Mức nguồn | **REQUIREMENT** |
| Nguồn | Chương 3.1.2, tr. 40 |

> **Mức nguồn:** Có trong yêu cầu chức năng/biểu đồ tổng quát nhưng không có bảng đặc tả riêng.

## Mục tiêu

Cập nhật thông tin cá nhân theo phạm vi nghiệp vụ được report mô tả.

## Điều kiện trước

Khách hàng đã đăng nhập.

## Điều kiện sau

Thông tin cá nhân được cập nhật.

## Luồng chính

1. Mở thông tin cá nhân.
2. Chỉnh sửa thông tin profile như họ tên, giới tính và ngày sinh.
3. Người dùng có thể tải ảnh đại diện mới.
4. Hệ thống lưu file vào media registry và gán `customers.avatar_file_id`.
5. Nếu đổi email hoặc số điện thoại, hệ thống cập nhật `accounts` sau khi kiểm tra uniqueness và xác minh theo policy.
6. Địa chỉ giao hàng được quản lý riêng qua `customer_addresses`, không lưu trực tiếp trên customer profile.
7. Hệ thống lưu thay đổi.

## Luồng thay thế / ngoại lệ

- Email/số điện thoại trùng hoặc dữ liệu không hợp lệ.
- File ảnh không đúng loại hoặc upload thất bại → không thay đổi avatar hiện tại.

## Ghi chú phạm vi

Tài liệu này chỉ tái cấu trúc nội dung có căn cứ từ report. Các rule chưa được nguồn xác định (ví dụ quy tắc tồn kho chi tiết, số lần review, discount stacking, AI clarification bắt buộc) không được tự bổ sung.

# UC-ADM-EMP-005 — Chỉnh sửa tài khoản nhân viên

## Metadata

| Thuộc tính | Giá trị |
|---|---|
| ID | `UC-ADM-EMP-005` |
| Tác nhân | Quản lý cửa hàng |
| Mức nguồn | **FORMAL** |
| Nguồn | Chương 3.2.2, tr. 53 |

> **Mức nguồn:** Có biểu đồ/bảng đặc tả use case trực tiếp trong Chương 3.2.2.

## Mục tiêu

Chỉnh sửa tài khoản nhân viên theo phạm vi nghiệp vụ được report mô tả.

## Điều kiện trước

Quản lý đã đăng nhập; nhân viên tồn tại.

## Điều kiện sau

Thông tin nhân viên được cập nhật.

## Luồng chính

1. Chọn chỉnh sửa.
2. Hệ thống hiển thị form.
3. Nhập thay đổi account/profile, bao gồm thông tin liên hệ, role, lương hoặc ngày vào làm nếu được phân quyền.
4. Có thể tải ảnh đại diện mới; hệ thống lưu file và cập nhật `employees.avatar_file_id`.
5. Hệ thống kiểm tra.
6. Lưu dữ liệu.

## Luồng thay thế / ngoại lệ

- Hủy thao tác.
- Thông tin không hợp lệ.
- Email hoặc phone trùng account khác; lương âm.
- File ảnh không hợp lệ hoặc upload thất bại.

## Ghi chú phạm vi

Tài liệu này chỉ tái cấu trúc nội dung có căn cứ từ report. Các rule chưa được nguồn xác định (ví dụ quy tắc tồn kho chi tiết, số lần review, discount stacking, AI clarification bắt buộc) không được tự bổ sung.

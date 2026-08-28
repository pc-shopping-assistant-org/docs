# UC-ADM-EMP-004 — Thêm tài khoản nhân viên

## Metadata

| Thuộc tính | Giá trị |
|---|---|
| ID | `UC-ADM-EMP-004` |
| Tác nhân | Quản trị viên/Quản lý cửa hàng |
| Mức nguồn | **FORMAL** |
| Nguồn | Chương 3.2.2, tr. 52 |

> **Mức nguồn:** Có biểu đồ/bảng đặc tả use case trực tiếp trong Chương 3.2.2.

## Mục tiêu

Thêm tài khoản nhân viên theo phạm vi nghiệp vụ được report mô tả.

## Điều kiện trước

Tác nhân đã đăng nhập với quyền quản lý.

## Điều kiện sau

Tài khoản nhân viên được tạo.

## Luồng chính

1. Chọn thêm tài khoản nhân viên.
2. Hệ thống hiển thị form.
3. Nhập email, phone, mật khẩu ban đầu, role và employee profile gồm họ tên, ngày vào làm, lương cùng thông tin cá nhân cần thiết.
4. Có thể tải ảnh đại diện; hệ thống lưu file và gán `employees.avatar_file_id`.
5. Hệ thống kiểm tra.
6. Lưu account/profile và cập nhật danh sách.

## Luồng thay thế / ngoại lệ

- Người dùng hủy.
- Thông tin không hợp lệ; rollback theo đặc tả report.
- Email hoặc phone đã tồn tại; lương âm hoặc ngày vào làm không hợp lệ.
- File ảnh không hợp lệ hoặc upload thất bại.

## Ghi chú phạm vi

Tài liệu này chỉ tái cấu trúc nội dung có căn cứ từ report. Các rule chưa được nguồn xác định (ví dụ quy tắc tồn kho chi tiết, số lần review, discount stacking, AI clarification bắt buộc) không được tự bổ sung.

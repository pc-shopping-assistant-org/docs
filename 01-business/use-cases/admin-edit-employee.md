# UC-ADM-EMP-005 — Chỉnh sửa tài khoản nhân viên

## Metadata

| Thuộc tính | Giá trị |
|---|---|
| ID | `UC-ADM-EMP-005` |
| Tác nhân | Quản trị viên |
| Mức nguồn | **FORMAL** |
| Nguồn | Chương 3.2.2, tr. 53 |

> **Mức nguồn:** Có biểu đồ/bảng đặc tả use case trực tiếp trong Chương 3.2.2.

## Mục tiêu

Chỉnh sửa tài khoản nhân viên theo phạm vi nghiệp vụ được report mô tả.

## Điều kiện trước

Tác nhân đã đăng nhập với vai trò quản trị viên (`ROLE_ADMIN`). Nhân viên tồn tại.

## Điều kiện sau

Thông tin nhân viên được cập nhật.

## Luồng chính

1. Chọn chỉnh sửa.
2. Hệ thống hiển thị form.
3. Nhập thay đổi tài khoản/hồ sơ: email, số điện thoại, họ, tên, giới tính, ngày sinh, địa chỉ. Vai trò không đổi được qua use case này. Trường bỏ trống giữ nguyên giá trị hiện tại.
4. Có thể tải ảnh đại diện mới lên Media Service; ảnh phải tồn tại ở đó.
5. Hệ thống kiểm tra.
6. Lưu dữ liệu. Nhân viên đang bị khóa vẫn sửa được.

## Luồng thay thế / ngoại lệ

- Hủy thao tác → không đổi gì.
- Thông tin không hợp lệ → từ chối.
- Email hoặc số điện thoại trùng tài khoản khác → từ chối.
- File ảnh không hợp lệ, upload thất bại hoặc không tồn tại ở Media Service → từ chối.

## Ghi chú phạm vi

Tài liệu này chỉ tái cấu trúc nội dung có căn cứ từ report. Các rule chưa được nguồn xác định (ví dụ quy tắc tồn kho chi tiết, số lần review, discount stacking, AI clarification bắt buộc) không được tự bổ sung.

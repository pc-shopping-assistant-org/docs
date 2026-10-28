# UC-ADM-EMP-004 — Thêm tài khoản nhân viên

## Metadata

| Thuộc tính | Giá trị |
|---|---|
| ID | `UC-ADM-EMP-004` |
| Tác nhân | Quản trị viên |
| Mức nguồn | **FORMAL** |
| Nguồn | Chương 3.2.2, tr. 52 |

> **Mức nguồn:** Có biểu đồ/bảng đặc tả use case trực tiếp trong Chương 3.2.2.

## Mục tiêu

Thêm tài khoản nhân viên theo phạm vi nghiệp vụ được report mô tả.

## Điều kiện trước

Tác nhân đã đăng nhập với vai trò quản trị viên (`ROLE_ADMIN`).

## Điều kiện sau

Tài khoản nhân viên được tạo.

## Luồng chính

1. Chọn thêm tài khoản nhân viên.
2. Hệ thống hiển thị form.
3. Nhập email, số điện thoại, mật khẩu ban đầu (cùng ràng buộc như đăng ký) và hồ sơ nhân viên gồm họ, tên, giới tính (bắt buộc), ngày sinh, địa chỉ (tối đa 255 ký tự).
4. Có thể tải ảnh đại diện lên Media Service trước; hệ thống kiểm tra file tồn tại rồi gán ảnh cho hồ sơ.
5. Hệ thống kiểm tra, chuẩn hóa email về chữ thường, cắt khoảng trắng đầu cuối của tên.
6. Hệ thống tạo tài khoản chỉ với vai trò `ROLE_EMPLOYEE` (vai trò do hệ thống gán cố định, người dùng không chọn; không tạo được tài khoản quản trị qua use case này) cùng hồ sơ, rồi cập nhật danh sách.

## Luồng thay thế / ngoại lệ

- Người dùng hủy → không tạo gì.
- Thông tin không hợp lệ → từ chối, không tạo tài khoản dở dang.
- Email hoặc số điện thoại đã tồn tại → từ chối.
- File ảnh không hợp lệ, upload thất bại hoặc không tồn tại ở Media Service → từ chối.

## Ghi chú phạm vi

Tài liệu này chỉ tái cấu trúc nội dung có căn cứ từ report. Các rule chưa được nguồn xác định (ví dụ quy tắc tồn kho chi tiết, số lần review, discount stacking, AI clarification bắt buộc) không được tự bổ sung.

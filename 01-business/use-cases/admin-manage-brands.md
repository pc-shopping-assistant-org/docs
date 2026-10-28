# UC-ADM-BRAND-001 — Quản lý thương hiệu

## Metadata

| Thuộc tính | Giá trị |
|---|---|
| ID | `UC-ADM-BRAND-001` |
| Tác nhân | Nhân viên |
| Mức nguồn | **IMPLEMENTATION** |
| Nguồn | Chương 5.2.11, tr. 91 |

> **Mức nguồn:** Có bằng chứng giao diện/triển khai ở Chương 5 nhưng Chương 3 không đặc tả đầy đủ.

## Mục tiêu

Quản lý thương hiệu theo phạm vi nghiệp vụ được report mô tả.

## Điều kiện trước

Tác nhân đã đăng nhập với vai trò nhân viên (`ROLE_EMPLOYEE`).

## Điều kiện sau

Dữ liệu thương hiệu được quản lý qua giao diện triển khai.

## Luồng chính

1. Mở quản lý thương hiệu. Hệ thống liệt kê mọi thương hiệu chưa xóa, `ACTIVE` lẫn `INACTIVE`, kèm ảnh.
2. Thêm hoặc chỉnh sửa thông tin thương hiệu: tên (bắt buộc, tối đa 255 ký tự), tên SEO (bỏ trống thì tạo từ tên), mô tả.
3. Có thể tải ảnh thương hiệu lên Media Service trước rồi gán cho thương hiệu. Khi sửa, ảnh gửi lên ghi đè ảnh cũ (bỏ trống nghĩa là xóa ảnh).
4. Hệ thống kiểm tra tên (không phân biệt hoa thường) và tên SEO chưa thuộc thương hiệu chưa xóa nào rồi lưu; thương hiệu mới ở trạng thái `ACTIVE`.
5. Ẩn/hiện thương hiệu (`ACTIVE`/`INACTIVE`); thương hiệu `INACTIVE` không còn trong danh sách công khai và không gán được cho sản phẩm mới.
6. Xóa mềm thương hiệu, chỉ khi không có sản phẩm chưa xóa nào dùng thương hiệu đó.

## Luồng thay thế / ngoại lệ

- File ảnh không hợp lệ hoặc upload thất bại → từ chối.
- Tên hoặc tên SEO trùng thương hiệu chưa xóa khác → từ chối.
- Thương hiệu không tồn tại hoặc đã xóa → từ chối; đặt trạng thái `DELETED` khi đổi trạng thái cũng bị từ chối.
- Thương hiệu còn sản phẩm → không xóa được; nên ẩn thay vì xóa.

## Ghi chú phạm vi

Tài liệu này chỉ tái cấu trúc nội dung có căn cứ từ report. Các rule chưa được nguồn xác định (ví dụ quy tắc tồn kho chi tiết, số lần review, discount stacking, AI clarification bắt buộc) không được tự bổ sung.

# UC-ADM-CAT-001 — Xem danh mục sản phẩm

## Metadata

| Thuộc tính | Giá trị |
|---|---|
| ID | `UC-ADM-CAT-001` |
| Tác nhân | Nhân viên |
| Mức nguồn | **REQUIREMENT** |
| Nguồn | Chương 3.1.2, tr. 42 |

> **Mức nguồn:** Có trong yêu cầu chức năng/biểu đồ tổng quát nhưng không có bảng đặc tả riêng.

## Mục tiêu

Xem danh mục sản phẩm theo phạm vi nghiệp vụ được report mô tả.

## Điều kiện trước

Tác nhân đã đăng nhập với vai trò nhân viên (`ROLE_EMPLOYEE`).

## Điều kiện sau

Danh sách danh mục được hiển thị.

## Luồng chính

1. Mở quản lý danh mục.
2. Hệ thống hiển thị danh sách phẳng mọi danh mục chưa xóa, gồm cả `ACTIVE` và `INACTIVE`, mỗi danh mục có tên, tên SEO, mô tả, danh mục cha, thứ tự hiển thị, loại phần cứng và trạng thái.
3. Trang công khai chỉ gồm danh mục `ACTIVE` (dạng cây hoặc phẳng), sắp theo thứ tự hiển thị rồi theo tên, mỗi danh mục kèm số sản phẩm đang hiển thị trong danh mục và mọi danh mục con.
4. Danh sách loại phần cứng để chọn trong form là dữ liệu công khai, có tên tiếng Việt và tiếng Anh, sắp theo thứ tự.

## Luồng thay thế / ngoại lệ

- Tài khoản không có vai trò nhân viên → từ chối truy cập phần quản trị.

## Ghi chú phạm vi

Tài liệu này chỉ tái cấu trúc nội dung có căn cứ từ report. Các rule chưa được nguồn xác định (ví dụ quy tắc tồn kho chi tiết, số lần review, discount stacking, AI clarification bắt buộc) không được tự bổ sung.

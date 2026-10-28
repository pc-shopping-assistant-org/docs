# UC-ADM-CAT-004 — Xóa danh mục

## Metadata

| Thuộc tính | Giá trị |
|---|---|
| ID | `UC-ADM-CAT-004` |
| Tác nhân | Nhân viên |
| Mức nguồn | **REQUIREMENT** |
| Nguồn | Chương 3.1.2, tr. 42 |

> **Mức nguồn:** Có trong yêu cầu chức năng/biểu đồ tổng quát nhưng không có bảng đặc tả riêng.

## Mục tiêu

Xóa danh mục theo phạm vi nghiệp vụ được report mô tả.

## Điều kiện trước

Tác nhân đã đăng nhập với vai trò nhân viên (`ROLE_EMPLOYEE`). Danh mục chưa có sản phẩm theo rule report.

## Điều kiện sau

Danh mục được xóa.

## Luồng chính

1. Chọn danh mục.
2. Chọn xóa.
3. Hệ thống kiểm tra điều kiện: danh mục không có danh mục con chưa xóa và không có sản phẩm chưa xóa (đang hiển thị hay đang ẩn đều tính).
4. Nếu hợp lệ, hệ thống xóa mềm danh mục (trạng thái `DELETED`) để tên dùng lại được.

## Luồng thay thế / ngoại lệ

- Danh mục đang có sản phẩm, hoặc còn danh mục con → không cho xóa. Muốn ngừng dùng danh mục đang có sản phẩm thì ẩn nó (UC-ADM-CAT-003) thay vì xóa.
- Danh mục không tồn tại hoặc đã xóa → từ chối.

## Ghi chú phạm vi

Tài liệu này chỉ tái cấu trúc nội dung có căn cứ từ report. Các rule chưa được nguồn xác định (ví dụ quy tắc tồn kho chi tiết, số lần review, discount stacking, AI clarification bắt buộc) không được tự bổ sung.

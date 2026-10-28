# UC-ADM-PROD-004 — Chỉnh sửa sản phẩm

## Metadata

| Thuộc tính | Giá trị |
|---|---|
| ID | `UC-ADM-PROD-004` |
| Tác nhân | Nhân viên |
| Mức nguồn | **FORMAL** |
| Nguồn | Chương 3.2.2, tr. 50 |

> **Mức nguồn:** Có biểu đồ/bảng đặc tả use case trực tiếp trong Chương 3.2.2.

## Mục tiêu

Chỉnh sửa sản phẩm theo phạm vi nghiệp vụ được report mô tả.

## Điều kiện trước

Tác nhân đã đăng nhập với vai trò nhân viên (`ROLE_EMPLOYEE`). Sản phẩm tồn tại.

## Điều kiện sau

Thông tin sản phẩm được cập nhật.

## Luồng chính

1. Chọn chỉnh sửa.
2. Hệ thống hiển thị form.
3. Chỉnh sửa thông tin product, category, brand, specifications hoặc mô tả.
4. Có thể thêm ảnh mới, xóa ảnh khỏi gallery hoặc đổi ảnh chính (tối đa một ảnh chính).
5. Xác nhận.
6. Hệ thống kiểm tra specifications theo mẫu thuộc tính của category (kể cả khi đổi category), rồi cập nhật product và gallery trong một transaction, ghi thời điểm và nhân viên thực hiện. Đây là cập nhật toàn bộ (tên, category, brand, specifications, mô tả được ghi đè bằng giá trị gửi lên); trạng thái hiển thị không đổi ở đây (xem UC-ADM-PROD-006). Nếu gửi danh sách ảnh (kể cả rỗng) thì danh sách đó thay toàn bộ gallery cũ; không gửi thì giữ nguyên gallery.
7. Use case này chỉ sửa gallery cấp product. Ảnh riêng của variant được sửa trong use case biến thể.

## Luồng thay thế / ngoại lệ

- Thông tin không hợp lệ → từ chối.
- Sản phẩm không tồn tại hoặc đã xóa → từ chối; sản phẩm đang ẩn vẫn sửa được.
- Category không tồn tại hoặc không `ACTIVE`; brand được chọn không tồn tại hoặc không `ACTIVE` → từ chối.
- Tên SEO trùng với một product chưa bị xóa khác → từ chối.
- Specifications không khớp mẫu thuộc tính của category → từ chối.
- File ảnh không hợp lệ hoặc upload thất bại → từ chối.
- Có nhiều hơn một ảnh được đánh dấu ảnh chính hoặc một file lặp lại → từ chối.

## Ghi chú phạm vi

Tài liệu này chỉ tái cấu trúc nội dung có căn cứ từ report. Các rule chưa được nguồn xác định (ví dụ quy tắc tồn kho chi tiết, số lần review, discount stacking, AI clarification bắt buộc) không được tự bổ sung.

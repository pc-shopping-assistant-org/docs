# UC-ADM-PROD-003 — Thêm sản phẩm

## Metadata

| Thuộc tính | Giá trị |
|---|---|
| ID | `UC-ADM-PROD-003` |
| Tác nhân | Nhân viên |
| Mức nguồn | **FORMAL** |
| Nguồn | Chương 3.2.2, tr. 49 |

> **Mức nguồn:** Có biểu đồ/bảng đặc tả use case trực tiếp trong Chương 3.2.2.

## Mục tiêu

Thêm sản phẩm theo phạm vi nghiệp vụ được report mô tả.

## Điều kiện trước

Tác nhân đã đăng nhập với vai trò nhân viên (`ROLE_EMPLOYEE`).

## Điều kiện sau

Sản phẩm mới được lưu.

## Luồng chính

1. Chọn thêm sản phẩm.
2. Hệ thống hiển thị form.
3. Nhập thông tin product (tên, tên SEO), chọn đúng một category chính và brand nếu có. Tên SEO có thể bỏ trống; khi đó hệ thống tạo từ tên (bỏ dấu tiếng Việt, chữ thường, nối bằng dấu gạch ngang).
4. Nhập specifications và mô tả nếu có. Specifications phải khớp mẫu thuộc tính của category (xem UC-ADM-CAT-003): thuộc tính bắt buộc phải có, giá trị đúng kiểu (số, đúng/sai, chuỗi, một giá trị trong danh sách cho phép, danh sách chuỗi), không được có khóa ngoài mẫu.
5. Có thể tải nhiều ảnh cho product lên Media Service; hệ thống lưu thành gallery của sản phẩm.
6. Chọn tối đa một ảnh làm ảnh chính (thumbnail) của product.
7. Xác nhận.
8. Hệ thống lưu product và gallery ảnh trong một transaction, ghi nhân viên thực hiện, rồi thông báo thành công. Product mới có trạng thái `ACTIVE`.
9. Product chưa có variant nào nên chưa hiển thị ở trang công khai (chỉ liệt kê sản phẩm có ít nhất một variant `ACTIVE`); nhân viên thêm variant bằng UC-ADM-PROD-007. Thay đổi được đồng bộ sang chỉ mục tìm kiếm (xem UC-CAT-003).

## Luồng thay thế / ngoại lệ

- Thông tin không hợp lệ → yêu cầu chỉnh sửa.
- Category không tồn tại hoặc không `ACTIVE` → từ chối lưu.
- Brand được chọn không tồn tại hoặc không `ACTIVE` → từ chối lưu.
- Tên SEO trùng với một product chưa bị xóa → từ chối lưu (product đã xóa mềm không tính, được dùng lại tên SEO).
- Specifications thiếu thuộc tính bắt buộc, sai kiểu hoặc có khóa lạ → từ chối, thông báo liệt kê từng lỗi.
- File ảnh không hợp lệ hoặc upload thất bại, hoặc file không có ở Media Service → từ chối lưu.
- Có nhiều hơn một ảnh được đánh dấu ảnh chính, hoặc một file xuất hiện hai lần trong gallery → từ chối lưu.
- Gallery và ảnh chính thuộc cấp product; mỗi variant có thể có thêm một ảnh riêng, quản lý trong use case thêm biến thể.

## Ghi chú phạm vi

Tài liệu này chỉ tái cấu trúc nội dung có căn cứ từ report. Các rule chưa được nguồn xác định (ví dụ quy tắc tồn kho chi tiết, số lần review, discount stacking, AI clarification bắt buộc) không được tự bổ sung.

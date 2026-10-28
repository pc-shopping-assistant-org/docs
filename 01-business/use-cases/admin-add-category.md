# UC-ADM-CAT-002 — Thêm danh mục

## Metadata

| Thuộc tính | Giá trị |
|---|---|
| ID | `UC-ADM-CAT-002` |
| Tác nhân | Nhân viên |
| Mức nguồn | **REQUIREMENT** |
| Nguồn | Chương 3.1.2, tr. 42 |

> **Mức nguồn:** Có trong yêu cầu chức năng/biểu đồ tổng quát nhưng không có bảng đặc tả riêng.

## Mục tiêu

Thêm danh mục theo phạm vi nghiệp vụ được report mô tả.

## Điều kiện trước

Tác nhân đã đăng nhập với vai trò nhân viên (`ROLE_EMPLOYEE`).

## Điều kiện sau

Danh mục mới được tạo.

## Luồng chính

1. Chọn thêm danh mục.
2. Nhập tên (bắt buộc, tối đa 255 ký tự), tên SEO (có thể bỏ trống để hệ thống tạo từ tên), mô tả, danh mục cha (nếu là danh mục con), thứ tự hiển thị (số không âm, mặc định 0) và loại phần cứng (mặc định `OTHER`).
3. Hệ thống kiểm tra tên (không phân biệt hoa thường) và tên SEO chưa thuộc danh mục nào chưa xóa, danh mục cha phải `ACTIVE`, loại phần cứng phải tồn tại và `ACTIVE`; rồi lưu danh mục mới ở trạng thái `ACTIVE`.

## Luồng thay thế / ngoại lệ

- Thông tin không hợp lệ → yêu cầu chỉnh sửa.
- Tên hoặc tên SEO trùng danh mục chưa xóa → từ chối; danh mục đã xóa mềm không tính nên dùng lại được tên.
- Danh mục cha không tồn tại hoặc không `ACTIVE` → từ chối.
- Loại phần cứng không tồn tại hoặc không `ACTIVE` → từ chối.

## Ghi chú phạm vi

Tài liệu này chỉ tái cấu trúc nội dung có căn cứ từ report. Các rule chưa được nguồn xác định (ví dụ quy tắc tồn kho chi tiết, số lần review, discount stacking, AI clarification bắt buộc) không được tự bổ sung.

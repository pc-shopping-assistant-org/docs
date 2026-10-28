# UC-ADM-PROD-001 — Xem danh sách sản phẩm

## Metadata

| Thuộc tính | Giá trị |
|---|---|
| ID | `UC-ADM-PROD-001` |
| Tác nhân | Nhân viên |
| Mức nguồn | **REQUIREMENT** |
| Nguồn | Chương 3.1.2, tr. 41 |

> **Mức nguồn:** Có trong yêu cầu chức năng/biểu đồ tổng quát nhưng không có bảng đặc tả riêng.

## Mục tiêu

Xem danh sách sản phẩm theo phạm vi nghiệp vụ được report mô tả.

## Điều kiện trước

Tác nhân đã đăng nhập với vai trò nhân viên (`ROLE_EMPLOYEE`).

## Điều kiện sau

Danh sách sản phẩm được hiển thị.

## Luồng chính

1. Mở quản lý sản phẩm.
2. Hệ thống tải danh sách. Khác trang công khai, danh sách quản trị gồm cả sản phẩm `ACTIVE` lẫn `INACTIVE` (đang ẩn), kể cả sản phẩm chưa có variant nào; sản phẩm đã xóa không hiện. Mới nhất trước.
3. Hiển thị thông tin quản trị: tên, thương hiệu, danh mục, ảnh chính, khoảng giá, số variant, tổng tồn kho, trạng thái, ngày tạo. Phân trang theo số trang (kèm tổng số sản phẩm và tổng số trang), mặc định 20 mỗi trang, tối đa 100.
4. Xem chi tiết một sản phẩm (kể cả đang ẩn), gồm mọi variant `ACTIVE` và `INACTIVE`.

## Luồng thay thế / ngoại lệ

- Tài khoản không có vai trò nhân viên (kể cả khách hàng và quản trị viên thuần) → từ chối truy cập.
- Sản phẩm không tồn tại hoặc đã xóa ở trang chi tiết → thông báo không tìm thấy.

## Ghi chú phạm vi

Tài liệu này chỉ tái cấu trúc nội dung có căn cứ từ report. Các rule chưa được nguồn xác định (ví dụ quy tắc tồn kho chi tiết, số lần review, discount stacking, AI clarification bắt buộc) không được tự bổ sung.

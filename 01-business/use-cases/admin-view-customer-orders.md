# UC-ADM-CUS-004 — Xem đơn hàng của khách hàng

## Metadata

| Thuộc tính | Giá trị |
|---|---|
| ID | `UC-ADM-CUS-004` |
| Tác nhân | Nhân viên |
| Mức nguồn | **REQUIREMENT** |
| Nguồn | Chương 3.1.2, tr. 42; Hình 19 |

> **Mức nguồn:** Có trong yêu cầu chức năng/biểu đồ tổng quát nhưng không có bảng đặc tả riêng.

## Mục tiêu

Xem đơn hàng của khách hàng theo phạm vi nghiệp vụ được report mô tả.

## Điều kiện trước

Tác nhân đã đăng nhập với vai trò nhân viên (`ROLE_EMPLOYEE`). Khách hàng tồn tại.

## Điều kiện sau

Danh sách đơn của khách được hiển thị.

## Luồng chính

1. Mở chi tiết khách hàng.
2. Chọn danh sách đơn hàng.
3. Hệ thống tải các đơn của khách (dùng chung danh sách đơn của nhân viên, lọc theo khách; có thể thêm lọc trạng thái, khoảng ngày, từ khóa), phân trang. Chọn một đơn để xem chi tiết.

## Luồng thay thế / ngoại lệ

- Khách chưa có đơn → danh sách rỗng. Màn hình chi tiết khách đã xác nhận khách tồn tại từ hồ sơ.

## Ghi chú phạm vi

Tài liệu này chỉ tái cấu trúc nội dung có căn cứ từ report. Các rule chưa được nguồn xác định (ví dụ quy tắc tồn kho chi tiết, số lần review, discount stacking, AI clarification bắt buộc) không được tự bổ sung.

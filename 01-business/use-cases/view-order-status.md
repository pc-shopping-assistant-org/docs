# UC-ORD-002 — Xem trạng thái đơn hàng

## Metadata

| Thuộc tính | Giá trị |
|---|---|
| ID | `UC-ORD-002` |
| Tác nhân | Khách hàng |
| Mức nguồn | **REQUIREMENT** |
| Nguồn | Chương 3.1.2, tr. 40 |

> **Mức nguồn:** Có trong yêu cầu chức năng/biểu đồ tổng quát nhưng không có bảng đặc tả riêng.

## Mục tiêu

Xem trạng thái đơn hàng theo phạm vi nghiệp vụ được report mô tả.

## Điều kiện trước

Tác nhân đã đăng nhập với vai trò khách hàng (`ROLE_CUSTOMER`). Khách hàng có đơn hàng.

## Điều kiện sau

Trạng thái hiện tại của đơn được hiển thị.

## Luồng chính

1. Mở danh sách/lịch sử đơn hàng.
2. Chọn đơn hàng.
3. Hệ thống kiểm tra đơn thuộc khách đang đăng nhập rồi hiển thị trạng thái hiện tại: số hóa đơn, trạng thái, thời điểm tạo và cập nhật cuối, kèm lý do hủy nếu đơn `CANCELLED` và có ghi lý do.
4. Các trạng thái của đơn: `PENDING_PAYMENT` (chờ thanh toán online), `PENDING_CONFIRMATION` (chờ cửa hàng xác nhận), `CONFIRMED`, `SHIPPING`, `COMPLETED`, `CANCELLED`. Đơn có thể tự chuyển `PENDING_CONFIRMATION` sau khi thanh toán thành công hoặc tự `CANCELLED` khi thanh toán thất bại hay không giữ được tồn kho, nên trạng thái đổi mà khách không thao tác gì.

## Luồng thay thế / ngoại lệ

- Đơn không tồn tại hoặc không thuộc khách hiện tại → thông báo không tìm thấy, không lộ sự tồn tại của đơn người khác.

## Ghi chú phạm vi

Tài liệu này chỉ tái cấu trúc nội dung có căn cứ từ report. Các rule chưa được nguồn xác định (ví dụ quy tắc tồn kho chi tiết, số lần review, discount stacking, AI clarification bắt buộc) không được tự bổ sung.

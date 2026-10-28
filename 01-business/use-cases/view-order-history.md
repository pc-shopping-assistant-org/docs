# UC-ORD-004 — Xem lịch sử mua hàng

## Metadata

| Thuộc tính | Giá trị |
|---|---|
| ID | `UC-ORD-004` |
| Tác nhân | Khách hàng |
| Mức nguồn | **REQUIREMENT** |
| Nguồn | Chương 3.1.2, tr. 40 |

> **Mức nguồn:** Có trong yêu cầu chức năng/biểu đồ tổng quát nhưng không có bảng đặc tả riêng.

## Mục tiêu

Xem lịch sử mua hàng theo phạm vi nghiệp vụ được report mô tả.

## Điều kiện trước

Tác nhân đã đăng nhập với vai trò khách hàng (`ROLE_CUSTOMER`). Khách hàng có thể có lịch sử đơn.

## Điều kiện sau

Danh sách đơn hàng trước đây được hiển thị.

## Luồng chính

1. Mở lịch sử mua hàng.
2. Hệ thống tải các đơn gắn với tài khoản đăng nhập, mới nhất trước, có thể lọc theo trạng thái.
3. Hiển thị danh sách; mỗi dòng gồm số hóa đơn, trạng thái, tổng tiền, số dòng hàng, tên sản phẩm đầu tiên và ngày đặt.
4. Danh sách phân trang theo số trang (kèm tổng số đơn và tổng số trang), mặc định 20 đơn mỗi trang, tối đa 100.

## Luồng thay thế / ngoại lệ

- Khách chưa có đơn nào → danh sách rỗng.
- Số trang âm → từ chối.

## Ghi chú phạm vi

Tài liệu này chỉ tái cấu trúc nội dung có căn cứ từ report. Các rule chưa được nguồn xác định (ví dụ quy tắc tồn kho chi tiết, số lần review, discount stacking, AI clarification bắt buộc) không được tự bổ sung.

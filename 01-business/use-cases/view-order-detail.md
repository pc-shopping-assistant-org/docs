# UC-ORD-006 — Xem chi tiết đơn hàng

## Metadata

| Thuộc tính | Giá trị |
|---|---|
| ID | `UC-ORD-006` |
| Tác nhân | Khách hàng |
| Mức nguồn | **REQUIREMENT** |
| Nguồn | Chương 3.1.2, tr. 40 |

> **Mức nguồn:** Có trong yêu cầu chức năng/biểu đồ tổng quát nhưng không có bảng đặc tả riêng.

## Mục tiêu

Xem chi tiết đơn hàng theo phạm vi nghiệp vụ được report mô tả.

## Điều kiện trước

Khách hàng có quyền xem đơn.

## Điều kiện sau

Chi tiết sản phẩm, giá và số lượng của đơn được hiển thị.

## Luồng chính

1. Chọn một đơn hàng.
2. Hệ thống xác minh order thuộc customer hiện tại.
3. Hệ thống tải snapshot người nhận, địa chỉ, shipping method/fee, các dòng hàng, payment attempts và trạng thái order.
4. Hiển thị `unit_price`, item discount, subtotal, order discount và total đúng theo snapshot lúc đặt hàng.

## Luồng thay thế / ngoại lệ

- Order không tồn tại hoặc không thuộc customer hiện tại: không trả dữ liệu đơn.

## Ghi chú phạm vi

Tài liệu này chỉ tái cấu trúc nội dung có căn cứ từ report. Các rule chưa được nguồn xác định (ví dụ quy tắc tồn kho chi tiết, số lần review, discount stacking, AI clarification bắt buộc) không được tự bổ sung.

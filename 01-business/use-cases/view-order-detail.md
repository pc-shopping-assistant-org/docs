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

Tác nhân đã đăng nhập với vai trò khách hàng (`ROLE_CUSTOMER`). Khách hàng là chủ đơn.

## Điều kiện sau

Chi tiết sản phẩm, giá và số lượng của đơn được hiển thị.

## Luồng chính

1. Chọn một đơn hàng.
2. Hệ thống xác minh order thuộc customer hiện tại.
3. Hệ thống tải snapshot người nhận, địa chỉ, ghi chú, phương thức và phí giao hàng, các dòng hàng, trạng thái order (kèm lý do hủy nếu có) và ngày giao; các lần thanh toán được lấy từ Payment Service, chỉ gồm payment của chính khách.
4. Hiển thị đơn giá, giảm giá theo dòng, tạm tính, giảm giá cấp đơn và tổng tiền đúng theo snapshot lúc đặt hàng.

## Luồng thay thế / ngoại lệ

- Order không tồn tại hoặc không thuộc customer hiện tại → xử lý như đơn không tồn tại, không trả dữ liệu.
- Payment Service không trả lời → báo lỗi, không hiển thị chi tiết thiếu thông tin thanh toán.

## Ghi chú phạm vi

Tài liệu này chỉ tái cấu trúc nội dung có căn cứ từ report. Các rule chưa được nguồn xác định (ví dụ quy tắc tồn kho chi tiết, số lần review, discount stacking, AI clarification bắt buộc) không được tự bổ sung.

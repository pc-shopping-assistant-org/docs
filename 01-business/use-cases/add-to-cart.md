# UC-CART-001 — Thêm sản phẩm vào giỏ hàng

## Metadata

| Thuộc tính | Giá trị |
|---|---|
| ID | `UC-CART-001` |
| Tác nhân | Khách hàng |
| Mức nguồn | **REQUIREMENT** |
| Nguồn | Chương 3.1.2, tr. 40 |

> **Mức nguồn:** Có trong yêu cầu chức năng/biểu đồ tổng quát nhưng không có bảng đặc tả riêng.

## Mục tiêu

Thêm sản phẩm vào giỏ hàng theo phạm vi nghiệp vụ được report mô tả.

## Điều kiện trước

Variant tồn tại và đang có thể bán. Request xác định customer đã đăng nhập hoặc một guest session hợp lệ.

## Điều kiện sau

Sản phẩm được thêm vào giỏ.

## Luồng chính

1. Khách hàng chọn sản phẩm/biến thể.
2. Chọn thêm vào giỏ.
3. Hệ thống tìm cart `ACTIVE` duy nhất của customer hoặc guest session; nếu chưa có thì tạo cart với đúng một owner.
4. Nếu variant đã có trong cart, hệ thống tăng/cập nhật quantity; nếu chưa có thì tạo `cart_item`.
5. Hệ thống kiểm tra quantity dương và không vượt tồn kho hiện có.
6. Giỏ hàng được cập nhật.

## Luồng thay thế / ngoại lệ

- Sản phẩm/variant không hợp lệ, không thể bán hoặc không đủ tồn kho.
- Customer/session có dữ liệu cart active xung đột: hệ thống từ chối và không tạo thêm cart.

## Ghi chú phạm vi

Tài liệu này chỉ tái cấu trúc nội dung có căn cứ từ report. Các rule chưa được nguồn xác định (ví dụ quy tắc tồn kho chi tiết, số lần review, discount stacking, AI clarification bắt buộc) không được tự bổ sung.

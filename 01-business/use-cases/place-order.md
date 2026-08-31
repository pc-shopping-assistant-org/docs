# UC-ORD-001 — Đặt hàng

## Metadata

| Thuộc tính | Giá trị |
|---|---|
| ID | `UC-ORD-001` |
| Tác nhân | Khách hàng |
| Mức nguồn | **FORMAL** |
| Nguồn | Chương 3.2.2, tr. 57 |

> **Mức nguồn:** Có biểu đồ/bảng đặc tả use case trực tiếp trong Chương 3.2.2.

## Mục tiêu

Đặt hàng theo phạm vi nghiệp vụ được report mô tả.

## Điều kiện trước

Khách hàng đã đăng nhập hoặc xác thực thành công; giỏ hàng có sản phẩm.

## Điều kiện sau

Đơn hàng được tạo thành công.

## Luồng chính

1. Mở giỏ hàng.
2. Chọn đặt hàng.
3. Hệ thống mở trang đặt hàng.
4. Khách hàng nhập/chọn tên người nhận, số điện thoại và địa chỉ giao hàng, hoặc
   chọn một `customerAddressId` đã lưu.
5. Chọn phương thức giao hàng; hệ thống lấy phí hiện hành.
6. Hệ thống áp dụng tối đa một item promotion cho mỗi dòng.
7. Khách hàng nhập tối đa một order voucher nếu có.
8. Chọn phương thức thanh toán.
9. Hệ thống kiểm tra tồn kho, discount và tính tổng tiền theo công thức chuẩn.
10. Hệ thống snapshot thông tin giao hàng, giá từng dòng, discount, phí giao hàng và tổng tiền vào order.
11. Hệ thống tạo order và payment attempt trong một transaction; cart chuyển sang `CONVERTED`.
12. Order online bắt đầu ở `PENDING_PAYMENT`; order COD bắt đầu ở `PENDING_CONFIRMATION`.

## Discount calculation

Đơn hàng có thể áp dụng đồng thời một item promotion cho mỗi dòng và một order voucher cho toàn đơn. Không cho phép nhiều voucher trên cùng order.

```text
item_gross = unit_price * quantity
item_net   = item_gross - item_discount
subtotal   = sum(item_net)
total      = subtotal - order_discount + shipping_fee
```

## Luồng thay thế / ngoại lệ

- Thông tin người nhận hoặc địa chỉ không hợp lệ → yêu cầu nhập lại.
- Cart không thuộc customer/session hiện tại, không còn `ACTIVE` hoặc trống → từ chối checkout.
- Tồn kho không đủ → từ chối checkout và trả về các dòng cần cập nhật.
- Voucher không hợp lệ, hết hạn hoặc không đạt `min_order_amount` → không tạo order.
- Tổng tiền snapshot không khớp công thức chuẩn → rollback transaction.

## Quy tắc snapshot

Order lưu `recipient_name`, `recipient_phone`, `delivery_address`, `subtotal_amount`, `discount_amount`, `shipping_fee` và `total_amount`. Việc customer sửa địa chỉ, catalog đổi `list_price`, discount hết hạn hoặc phí vận chuyển thay đổi về sau không làm thay đổi order cũ.

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

Tác nhân đã đăng nhập với vai trò khách hàng (`ROLE_CUSTOMER`). Giỏ hàng của tài khoản có sản phẩm (không có tính năng guest).

## Điều kiện sau

Đơn hàng được tạo thành công.

## Luồng chính

1. Mở giỏ hàng.
2. Chọn đặt hàng.
3. Hệ thống mở trang đặt hàng.
4. Khách hàng nhập/chọn tên người nhận, số điện thoại và địa chỉ giao hàng, hoặc
   chọn một địa chỉ đã lưu; chỉ được dùng một trong hai cách, không trộn.
   Mỗi lần đặt mang một khóa chống đặt trùng (bắt buộc, tối đa 100 ký tự) do client sinh.
5. Chọn phương thức giao hàng (phải đang `ACTIVE`); hệ thống lấy `shipping_methods.fee` hiện hành.
6. Hệ thống áp dụng tối đa một item promotion cho mỗi dòng (discount `ALL_ITEMS` hoặc `CATEGORY` đang hiệu lực có mức giảm lớn nhất), tự động, không cần khách nhập.
7. Khách hàng nhập tối đa một order voucher nếu có. Không nhập mã thì hệ thống tự chọn discount cấp đơn không mã có mức giảm lớn nhất (nếu có và đạt giá trị đơn tối thiểu).
8. Chọn phương thức thanh toán.
9. Hệ thống kiểm tra từng dòng giỏ còn bán được (variant và sản phẩm `ACTIVE`) và tồn kho hiện tại của Catalog đủ cho số lượng đặt, áp discount, rồi tính tổng tiền theo công thức chuẩn. Đây chỉ là kiểm tra trước; việc giữ tồn kho thật diễn ra bất đồng bộ ở bước 11.
10. Hệ thống snapshot thông tin giao hàng, giá từng dòng, discount, phí giao hàng và tổng tiền vào order.
11. Hệ thống sinh `invoice_number`, tạo order cùng các order item và lệnh giữ tồn kho (outbox) trong một transaction của Order Service, rồi xóa cart. Payment attempt được Payment Service tạo sau đó qua saga (Order Service gọi tạo payment khi tồn kho đã được giữ), nên không chung transaction với order.
12. Order online bắt đầu ở `PENDING_PAYMENT`; order COD bắt đầu ở `PENDING_CONFIRMATION`. Hệ thống trả ngay chi tiết đơn vừa tạo, trước khi tồn kho được giữ xong.
13. Catalog Service nhận lệnh giữ tồn kho, trừ `product_variants.quantity` của tất cả các dòng trong một transaction (đủ hết hoặc không dòng nào), và trả kết quả bằng sự kiện:
    - Giữ được → Order Service gọi Payment Service tạo payment `PENDING` cho đơn (khóa idempotency là id đơn, nhận lại sự kiện không tạo payment thứ hai). Đơn đã bị hủy trong lúc chờ thì không tạo payment.
    - Không giữ được (hết hàng ở thời điểm giữ) → đơn tự chuyển `CANCELLED` kèm lý do, không có tồn kho nào cần trả lại.

## Discount calculation

Đơn hàng có thể áp dụng đồng thời một item promotion cho mỗi dòng và một order voucher cho toàn đơn. Không cho phép nhiều voucher trên cùng order.

```text
item_gross = unit_price * quantity
item_net   = item_gross - item_discount
subtotal   = sum(item_net)
total      = subtotal - order_discount + shipping_fee
```

Ánh xạ sang cột: `item_discount` là `order_items.discount_amount` (tổng giảm của cả dòng, không phải mỗi đơn vị, không vượt `item_gross`); `subtotal` là `orders.subtotal_amount` (đã trừ giảm theo dòng); `order_discount` là `orders.discount_amount` (chỉ voucher cấp đơn); `total` là `orders.total_amount`.

## Luồng thay thế / ngoại lệ

- Thông tin người nhận hoặc địa chỉ không hợp lệ (thiếu tên/số điện thoại/địa chỉ, số điện thoại sai định dạng, trộn địa chỉ đã lưu với thông tin nhập tay, địa chỉ đã lưu không thuộc khách) → yêu cầu nhập lại.
- Phương thức giao hàng không tồn tại hoặc không `ACTIVE`; phương thức thanh toán không có trong danh sách đang dùng → từ chối.
- Cart của customer hiện tại trống hoặc chưa có (cart lấy từ tài khoản đăng nhập, không nhận từ client) → từ chối đặt hàng.
- Có dòng không còn bán, hoặc tồn kho không đủ → từ chối và thông báo các SKU cần cập nhật. Giỏ vẫn giữ nguyên.
- Gửi lại cùng khóa chống đặt trùng (do timeout, bấm hai lần) → trả lại đơn đã tạo lần đầu, không tạo đơn mới; khóa đã thuộc khách khác thì từ chối.
- Voucher không hợp lệ, hết hạn hoặc không đạt giá trị đơn tối thiểu → Promotion Service từ chối và không tạo order. Kết quả giảm giá sai lệch (dòng giảm quá giá dòng, tổng không khớp) bị coi là lỗi dịch vụ ngoài, không tạo order.
- Tổng tiền snapshot không khớp công thức chuẩn → rollback transaction.

## Quy tắc snapshot

Order lưu `recipient_name`, `recipient_phone`, `delivery_address`, `subtotal_amount`, `discount_amount`, `shipping_fee` và `total_amount`. Mỗi order item lưu `unit_price`, `discount_amount` cùng thông tin variant tại thời điểm đặt (`product_name`, `sku`, `variant_label` là các options đã ghép sẵn, ví dụ "Dung lượng: 256GB, Màu sắc: Xanh"). Việc customer sửa địa chỉ, catalog đổi `price` hoặc tên sản phẩm, discount hết hạn hoặc phí vận chuyển thay đổi về sau không làm thay đổi order cũ.

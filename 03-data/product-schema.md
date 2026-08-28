# Product Pricing Schema

## Product hierarchy

```text
Product
└── Product Variant / SKU
```

- `products.category_id` là category chính duy nhất của product.
- `categories.parent_id` tạo taxonomy phân cấp.
- `product_variants` chứa các SKU bán được và thông tin thay đổi theo variant như SKU, tồn kho tổng `quantity` và giá.
- `product_images` chứa gallery theo variant; mỗi variant có tối đa một ảnh main đang `ACTIVE`.
- `product_suppliers` biểu diễn quan hệ nhiều-nhiều giữa product và supplier.
- MVP không có reservation, backorder hoặc stock movement.
- Collection/tag là lớp phân loại merchandising riêng trong tương lai, không dùng `categories` để thay thế.

## Product variant

`product_variants.list_price` là giá niêm yết của một variant. Đây là source of truth duy nhất cho giá trước khuyến mãi.

Không lưu `price_sale`. Giá bán hiệu lực là dữ liệu được tính tại thời điểm đọc/checkout:

```text
effective_price = apply_discount(list_price, active_discount)
```

Khi tạo order, giá hiệu lực được copy vào `order_items.unit_price` để bảo toàn lịch sử giao dịch.

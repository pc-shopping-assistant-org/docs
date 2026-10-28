# Product Pricing Schema

## Product hierarchy

```text
Product
└── Product Variant / SKU
```

- `products.category_id` là category chính duy nhất của product.
- `categories.parent_id` tạo taxonomy phân cấp; mỗi category có một loại phần cứng (`hardware_types`).
- `product_variants` chứa các SKU bán được và thông tin thay đổi theo variant như SKU, tồn kho tổng `quantity` và giá.
- `product_images` là gallery cấp product; mỗi product có tối đa một ảnh chính. Variant có thể có thêm một ảnh riêng ở `product_variants.image_file_id`.
- Specifications của product là `jsonb`, phải khớp mẫu thuộc tính của category (`category_attributes`, kế thừa từ category cha).
- Không có reservation, backorder hay stock movement riêng; chỉ một số tồn kho tổng.
- Collection/tag là lớp phân loại merchandising riêng trong tương lai, không dùng `categories` để thay thế.

## Product variant

`product_variants.price` là giá bán hiện hành của một variant. Đây là source of truth duy nhất cho giá trước khuyến mãi.

Không lưu `price_sale`. Giá bán hiệu lực là dữ liệu được tính tại thời điểm đọc/checkout:

```text
effective_price = apply_discount(price, active_discount)
```

Khi tạo order, giá và số tiền giảm của từng dòng được copy vào `order_items.unit_price` và `order_items.discount_amount` để bảo toàn lịch sử giao dịch.

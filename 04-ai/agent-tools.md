# Agent tools

Các tool hiện tại đều giữ backend làm nguồn dữ liệu:

- `tools.product.search_products(query, limit)` gọi catalog search của backend.
- `tools.comparison.get_product(product_id)` lấy product detail theo ID.
- `tools.knowledge.explain_scope()` mô tả policy grounded của MVP.

Tool result không chứa thông tin thanh toán hay dữ liệu customer. Product card
giữ `id` và `listPrice` canonical để frontend có thể mở product detail hoặc
compare tiếp. Tool/model layer không được tự tạo giá, tồn kho hay trạng thái
không có trong context.

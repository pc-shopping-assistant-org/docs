# Order Flow

Nguồn: Chương 3.4 — Hình 30, tr. 61 và UC đặt hàng tr. 57.

```mermaid
flowchart TD
    A[Đăng nhập/đăng ký hoặc xác thực] --> B[Chọn sản phẩm]
    B --> C[Thêm vào giỏ]
    C --> D[Xem giỏ hàng]
    D --> E{Mua thêm?}
    E -- Có --> B
    E -- Không --> F[Nhập/chọn thông tin giao hàng]
    F --> G[Chọn phương thức thanh toán]
    G --> H[Nhập mã giảm giá nếu có]
    H --> I[Xác nhận]
    I --> J[Tạo đơn hàng]
```

Sau bước tạo đơn:

- Online: order `PENDING_PAYMENT` → payment `PAID` → order `PENDING_CONFIRMATION`.
- COD: order `PENDING_CONFIRMATION` → admin confirm → `CONFIRMED`.
- Cả hai nhánh tiếp tục `SHIPPING` → giao thành công → `COMPLETED`.
